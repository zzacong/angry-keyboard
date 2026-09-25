import AVFoundation

/// Plays the app's bundled sounds.
///
/// One `AVAudioEngine` starts at launch and stays running. Every sound is
/// decoded once into a PCM buffer held in memory, so playback never touches the
/// disk and never depends on the Desktop copies. Each sound owns one player
/// node; replaying a sound stops and restarts that node, so holding a key fires
/// the sound again on every repeat.
///
/// Playback is serialized on a private queue, which keeps the event-tap
/// callback fast and the player nodes free of concurrent access.
final nonisolated class AudioOutput: @unchecked Sendable {
    private let engine = AVAudioEngine()
    private let queue = DispatchQueue(label: "com.zzacong.AngryKeyboard.audio")
    private var players: [Sound: AVAudioPlayerNode] = [:]
    private var buffers: [Sound: AVAudioPCMBuffer] = [:]

    /// Decodes every bundled sound into memory, wires up a player node for
    /// each, and starts the engine. A sound that fails to load is logged and
    /// skipped rather than crashing the app.
    init() {
        for sound in Sound.allCases {
            do {
                let buffer = try Self.decode(sound)
                let player = AVAudioPlayerNode()
                engine.attach(player)
                engine.connect(player, to: engine.mainMixerNode, format: buffer.format)
                buffers[sound] = buffer
                players[sound] = player
            } catch {
                NSLog("AngryKeyboard: could not load sound \(sound.rawValue): \(error)")
            }
        }

        observeConfigurationChanges()
        startEngine()
    }

    /// Plays `sound`, retriggering it from the start if a copy is already
    /// sounding.
    func play(_ sound: Sound) {
        queue.async { [self] in
            guard let player = players[sound], let buffer = buffers[sound] else { return }
            if !engine.isRunning { startEngine() }
            player.stop()
            player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
            player.play()
        }
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

    /// Reads a bundled MP3 from disk into a PCM buffer. The buffer owns the
    /// decoded samples, so the file is only read once, at launch.
    private static func decode(_ sound: Sound) throws -> AVAudioPCMBuffer {
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else {
            throw CocoaError(.fileNoSuchFile)
        }
        let file = try AVAudioFile(forReading: url)
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: file.processingFormat,
            frameCapacity: AVAudioFrameCount(file.length)
        ) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        try file.read(into: buffer)
        return buffer
    }
}
