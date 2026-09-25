import AVFoundation

/// The decoded PCM for one sound: one array per channel, all the same length.
private nonisolated struct SoundSamples {
    let channels: [[Float]]
    let frameCount: Int
}

private nonisolated extension SoundSamples {
    /// Copies a decoded buffer into channel arrays and fades both ends, so a
    /// voice can start or stop on any frame without a step.
    init(buffer: AVAudioPCMBuffer) throws {
        guard let channelData = buffer.floatChannelData else {
            throw CocoaError(.fileReadCorruptFile)
        }
        let frameCount = Int(buffer.frameLength)
        guard frameCount > 0 else { throw CocoaError(.fileReadCorruptFile) }

        var channels: [[Float]] = []
        channels.reserveCapacity(Int(buffer.format.channelCount))
        for channel in 0..<Int(buffer.format.channelCount) {
            channels.append(Array(UnsafeBufferPointer(start: channelData[channel], count: frameCount)))
        }

        let sampleRate = buffer.format.sampleRate
        let fadeIn = min(Int(0.003 * sampleRate), frameCount / 2)
        let fadeOut = min(Int(0.008 * sampleRate), frameCount / 2)
        for channel in channels.indices {
            for frame in 0..<fadeIn {
                channels[channel][frame] *= Float(frame) / Float(fadeIn)
            }
            for frame in 0..<fadeOut {
                let index = channels[channel].count - 1 - frame
                channels[channel][index] *= Float(frame) / Float(fadeOut)
            }
        }

        self.channels = channels
        self.frameCount = frameCount
    }
}

/// One playing copy of a sound: a cursor that reads through the samples at its
/// own pitch and gain.
private nonisolated struct Voice {
    let sound: Sound
    let samples: SoundSamples
    var position: Double
    let rate: Double
    let gain: Float
    var envelope: Float
    var releasing: Bool
    let attackStep: Float
    let releaseStep: Float

    /// Starts the short fade-out a stolen or retriggered voice needs.
    mutating func beginRelease() {
        releasing = true
    }
}

/// A feed-forward peak limiter on the mix, so overlapping voices can never sum
/// past full scale. The attack is fast enough to catch a gunshot's transient on
/// the sample it arrives; the release is slow, so the level does not pump
/// between hits.
private nonisolated struct Limiter {
    private var gain: Float = 1
    private let threshold: Float = 0.9
    private let attack: Float = 0.5
    private let release: Float = 0.0004

    mutating func process(_ left: inout Float, _ right: inout Float) {
        let peak = max(abs(left), abs(right))
        let target: Float = peak > threshold ? threshold / peak : 1
        gain += (target - gain) * (target < gain ? attack : release)
        let applied = min(gain, target)
        left *= applied
        right *= applied
    }
}

/// Plays the app's bundled sounds through a small software mixer.
///
/// One `AVAudioEngine` starts at launch and stays running. Every sound is
/// decoded once into memory, so playback never touches the disk and never
/// depends on the Desktop copies. A single `AVAudioSourceNode` renders the mix:
/// each keystroke starts a voice, a cursor that reads through a decoded buffer
/// at its own pitch and gain. Voices fade in and out over a few milliseconds,
/// so retriggering a sound or stealing a voice never steps the waveform, which
/// is what keeps fast typing free of clicks and pops. A limiter on the mix
/// catches the peaks when voices overlap, so it cannot clip.
///
/// Playback is serialized on a private queue, which keeps the event-tap
/// callback fast. The queue and the render thread share the voice list under a
/// lock.
final nonisolated class AudioOutput: @unchecked Sendable {
    /// How long a voice takes to fade in at its start and out when it is
    /// stolen. Short enough not to soften a gunshot, long enough to remove the
    /// step a hard cut would leave.
    private static let attackSeconds: Double = 0.002
    private static let releaseSeconds: Double = 0.006

    /// The level one hit plays at. The limiter catches overlapping voices, so
    /// this leaves headroom for a few at once.
    private static let hitGain: Float = 0.7

    /// The spread of the per-hit pitch and gain change. Small enough to read as
    /// the same sound, wide enough that repeats are not identical.
    private static let pitchSpread: Double = 0.025
    private static let gainSpread: Float = 0.1

    private let engine = AVAudioEngine()
    private let queue = DispatchQueue(label: "com.zzacong.AngryKeyboard.audio")
    private let lock = NSLock()
    private let outputRate: Double
    private var voices: [Voice] = []
    private var limiter = Limiter()
    private var samples: [Sound: SoundSamples] = [:]

    /// Decodes every bundled sound into memory and starts the engine. A sound
    /// that fails to load is logged and skipped rather than crashing the app.
    init() {
        outputRate = Self.outputSampleRate(for: engine)
        guard let format = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: outputRate,
            channels: 2,
            interleaved: false
        ) else {
            NSLog("AngryKeyboard: could not build the output format")
            return
        }

        for sound in Sound.allCases {
            do {
                samples[sound] = try Self.load(sound, as: format)
            } catch {
                NSLog("AngryKeyboard: could not load sound \(sound.rawValue): \(error)")
            }
        }

        let source = AVAudioSourceNode(format: format) { [weak self] isSilence, _, frameCount, audioBufferList in
            isSilence.pointee = false
            self?.render(frames: Int(frameCount), into: audioBufferList)
            return noErr
        }
        engine.attach(source)
        engine.connect(source, to: engine.mainMixerNode, format: format)
        observeConfigurationChanges()
        startEngine()
    }

    /// Plays `sound`, allowing up to `maxVoices` copies at once.
    ///
    /// A limit of one retriggers: the copy already playing fades out as the new
    /// one fades in. A higher limit overlaps copies, stealing the oldest once
    /// the limit is reached, so overlap can never run away and clip.
    func play(_ sound: Sound, maxVoices: Int) {
        queue.async { [self] in
            guard let samples = samples[sound] else { return }
            if !engine.isRunning { startEngine() }

            let limit = max(1, maxVoices)
            let voice = Voice(
                sound: sound,
                samples: samples,
                position: 0,
                rate: 1 + Double.random(in: -Self.pitchSpread...Self.pitchSpread),
                gain: Self.hitGain * Float.random(in: (1 - Self.gainSpread)...1),
                envelope: 0,
                releasing: false,
                attackStep: Float(1 / (Self.attackSeconds * outputRate)),
                releaseStep: Float(1 / (Self.releaseSeconds * outputRate))
            )

            lock.lock()
            defer { lock.unlock() }
            let held = voices.filter { $0.sound == sound && !$0.releasing }
            if held.count >= limit,
               let oldest = voices.firstIndex(where: { $0.sound == sound && !$0.releasing }) {
                voices[oldest].beginRelease()
            }
            voices.append(voice)
        }
    }

    /// Mixes every active voice into the output buffer. Called on the audio
    /// thread by the source node, once per buffer.
    private func render(frames: Int, into audioBufferList: UnsafeMutablePointer<AudioBufferList>) {
        let buffers = UnsafeMutableAudioBufferListPointer(audioBufferList)
        guard frames > 0, let first = buffers.first,
              let leftData = first.mData?.assumingMemoryBound(to: Float.self) else { return }
        let rightData = buffers.count > 1
            ? buffers[1].mData?.assumingMemoryBound(to: Float.self)
            : leftData

        lock.lock()
        defer { lock.unlock() }

        for frame in 0..<frames {
            var left: Float = 0
            var right: Float = 0
            var index = 0
            while index < voices.count {
                if mix(&voices[index], left: &left, right: &right) {
                    voices.remove(at: index)
                } else {
                    index += 1
                }
            }
            limiter.process(&left, &right)
            leftData[frame] = left
            rightData?[frame] = right
        }
    }

    /// Reads one frame from `voice`, applies its envelope, and adds it to
    /// `left`/`right`. Returns whether the voice has finished and should be
    /// dropped.
    private func mix(_ voice: inout Voice, left: inout Float, right: inout Float) -> Bool {
        let frameCount = voice.samples.frameCount
        guard voice.position < Double(frameCount) else { return true }

        let index = Int(voice.position)
        let next = min(index + 1, frameCount - 1)
        let fraction = Float(voice.position - Double(index))
        let channels = voice.samples.channels
        let sampleLeft = interpolate(channels[0], index, next, fraction)
        let sampleRight = channels.count > 1
            ? interpolate(channels[1], index, next, fraction)
            : sampleLeft

        if voice.releasing {
            voice.envelope -= voice.releaseStep
            if voice.envelope <= 0 { return true }
        } else if voice.envelope < 1 {
            voice.envelope = min(1, voice.envelope + voice.attackStep)
        }

        let amplitude = voice.gain * voice.envelope
        left += sampleLeft * amplitude
        right += sampleRight * amplitude
        voice.position += voice.rate
        return false
    }

    /// Linear interpolation between two frames, so a voice can play at a
    /// slightly different rate than it was recorded without a hard step.
    private func interpolate(_ channel: [Float], _ index: Int, _ next: Int, _ fraction: Float) -> Float {
        let a = channel[index]
        let b = channel[next]
        return a + (b - a) * fraction
    }

    /// Keeps audio alive across sleep/wake and output-device changes, which can
    /// stop the engine while the app keeps running. Restarting here means the
    /// next keystroke still makes a sound, with no manual restart.
    private func observeConfigurationChanges() {
        NotificationCenter.default.addObserver(
            forName: .AVAudioEngineConfigurationChange,
            object: engine,
            queue: nil
        ) { [weak self] _ in
            self?.queue.async { self?.startEngine() }
        }
    }

    private func startEngine() {
        guard !engine.isRunning else { return }
        engine.prepare()
        do {
            try engine.start()
        } catch {
            NSLog("AngryKeyboard: could not start audio engine: \(error)")
        }
    }

    /// The rate the source node renders at: the output device's own rate when
    /// the system reports one, so the decoded sounds resample at most once.
    private static func outputSampleRate(for engine: AVAudioEngine) -> Double {
        let rate = engine.outputNode.outputFormat(forBus: 0).sampleRate
        return rate > 0 ? rate : 44100
    }

    /// Reads a bundled MP3, converts it to the render format, and returns its
    /// samples. The conversion happens once, at launch.
    private static func load(_ sound: Sound, as format: AVAudioFormat) throws -> SoundSamples {
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else {
            throw CocoaError(.fileNoSuchFile)
        }
        let file = try AVAudioFile(forReading: url)
        guard let input = AVAudioPCMBuffer(
            pcmFormat: file.processingFormat,
            frameCapacity: AVAudioFrameCount(file.length)
        ) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        try file.read(into: input)

        guard let converter = AVAudioConverter(from: file.processingFormat, to: format) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        let ratio = format.sampleRate / file.processingFormat.sampleRate
        let capacity = AVAudioFrameCount((Double(file.length) * ratio).rounded(.up)) + 1024
        guard let output = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: capacity) else {
            throw CocoaError(.fileReadCorruptFile)
        }

        var providedInput = false
        var conversionError: NSError?
        converter.convert(to: output, error: &conversionError) { _, status in
            if providedInput {
                status.pointee = .endOfStream
                return nil
            }
            providedInput = true
            status.pointee = .haveData
            return input
        }
        if let conversionError { throw conversionError }

        return try SoundSamples(buffer: output)
    }
}
