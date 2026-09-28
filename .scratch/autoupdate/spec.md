# In-app updates

Status: ready-for-agent

## Problem Statement

Someone running the production app has no way to learn that a new release exists
short of browsing GitHub. Updating means finding the release, downloading the
DMG, quitting, dragging the app over the old copy, and clearing the Gatekeeper
prompt a second time. Most people either never notice a release or sit on a
stale one, and the maintainer has no path to a fix on a machine that is already
running.

## Solution

The production app checks the release update feed once a day and, when a newer
build exists, offers it from the status menu and installs it on a click. The
update is signed with the same self-signed certificate as the running app, so
the Input Monitoring grant survives and the sound keeps working after the
relaunch. Gatekeeper still only interrupts the first, manual install. The dev
channel never checks, and nothing installs without the user clicking.

## User Stories

1. As someone running the production app, I want it to check for updates on its
   own, so that I don't have to watch GitHub for releases.
2. As someone running the production app, I want a "Check for Updates…" item in
   the status menu, so that I can check on demand instead of waiting.
3. As someone running the production app, I want my daily check to be quiet when
   there is nothing new, so that it never interrupts me.
4. As someone running the production app, I want to be told when an update is
   available, so that I can decide whether to take it.
5. As someone running the production app, I want the status menu to show that an
   update is waiting, so that I notice it even though the app has no Dock icon
   and sits behind other windows.
6. As someone running the production app, I want to install the update with one
   click, so that updating is not a reinstall.
7. As someone running the production app, I want the updated app to keep my
   Input Monitoring grant, so that my sound keeps working without re-approving
   macOS.
8. As someone running the production app, I want the app to relaunch into the
   new version, so that I don't have to start it again myself.
9. As someone running the production app, I want to read what changed before I
   install, so that I can decide whether the update is worth it.
10. As someone running the production app, I never want an update installed
    without my click, so that the app can't change under me.
11. As someone running the production app, I want the update to be verified
    before it installs, so that a tampered download can't replace my app.
12. As someone running the production app, I want the update to be rejected if it
    isn't properly signed, so that a broken publish can't brick my install.
13. As someone running the production app, I want a failed check to be harmless,
    so that being offline or a feed hiccup never blocks the app.
14. As someone running the production app, I want to be told when the check
    failed, so that I know to retry rather than assume I'm current.
15. As someone running the production app, I want the update to work without a
    paid Apple Developer account, so that the app stays free and self-signed.
16. As someone running the production app, I want my preferences, sound pack
    choice, and volume to survive the update, so that the new version feels like
    the same app.
17. As someone running the production app, I want my Login Item to survive the
    update, so that it still starts at login without me re-adding it.
18. As someone running the production app, I don't want to be asked whether I
    want automatic checks, so that the app just works out of the box.
19. As someone running the production app, I want "About" to keep reporting the
    version and build, so that I can tell which build I'm on after an update.
20. As someone running the production app, I want to find the update item in a
    predictable place in the menu, so that I don't hunt for it.
21. As someone who is both the maintainer and the daily dev user, I want the dev
    channel to never check for updates, so that my workspace is never replaced by
    a released build.
22. As someone running the dev channel, I want the app to behave exactly as
    before, so that development is unaffected by this feature.
23. As the maintainer, I want to publish the update feed as part of the release,
    so that shipping an update is no extra manual step.
24. As the maintainer, I want the feed and the archive signed from a secret in
    CI, so that my private key never lives in the repo.
25. As the maintainer, I want the signing key backed up like the certificate, so
    that a lost key doesn't strand every installed app.
26. As the maintainer, I want a rehearsal path that produces a signed feed
    without cutting a release, so that I can test the whole flow safely.
27. As the maintainer, I want the release to keep publishing the DMG and its
    checksum exactly as before, so that the existing download page keeps
    working.
28. As the maintainer, I want the update feature to add no dependency to the dev
    build, so that the dev channel stays light.
29. As a new user, I want the first install to still be the manual, documented
    DMG flow, so that nothing changes about how I get the app.
30. As a privacy-conscious user, I never want the update check to send anything
    about me or what I type, so that the app stays private.
31. As someone who uninstalls the app, I want the documented cleanup steps to
    still remove everything the app leaves behind, so that the README doesn't
    lie about it.

## Implementation Decisions

- **Mechanism is Sparkle 2** (see ADR 0010), added as the repo's first
  third-party dependency through a Swift Package Manager binary target. It is
  linked and embedded in the production app; the dev build does not start it.
- **Update policy seam.** A pure type in `AngryKeyboardCore`, `UpdatePolicy`,
  answers one question: should this bundle check for updates? It reads the
  channel-substituted Info.plist key `AKEnableUpdates` from an injected
  `[String: Any]`, exactly as `ChannelAssets` reads the glyph keys. The
  production default is **off** — a bundle checks only when it explicitly opts
  in — so a missing key fails safe and the dev channel needs no special value to
  stay quiet.
- **Channel gating.** `AKEnableUpdates` is substituted from each channel's
  xcconfig into the shared Info.plist, `YES` for production and `NO` for dev.
  `AppDelegate` consults `UpdatePolicy` once at launch and starts the updater
  only when it says yes.
- **Updater wiring.** Because the app has no `MainMenu.xib`, the standard updater
  controller is created programmatically and the manual menu item drives its
  check action.
- **Info.plist contract** (all in the shared plist; inert on dev):
  `SUFeedURL` = the release feed URL; `SUPublicEDKey` = the base64 EdDSA public
  key; `SUEnableAutomaticChecks` = `YES`; `SUScheduledCheckInterval` = `86400`;
  `SUAutomaticallyUpdate` = `NO`; `SUAllowsAutomaticUpdates` = `NO`.
- **Feed URL.** `SUFeedURL` points at the update feed published as a release
  asset at the repo's stable `releases/latest/download` path. This accepts the
  same transient window the site's DMG download button already lives with: for
  the minutes between the release being published and its assets uploading, the
  feed 404s and a background check retries later.
- **Menu.** A permanent "Check for Updates…" item sits above About. A scheduled
  check that finds an update annotates that item with the available version
  rather than opening a window behind other apps; clicking it opens the normal
  update flow.
- **Consent posture.** No silent install, no phased rollout, no critical-update
  flag, no binary deltas. These are deliberate no-s recorded in ADR 0010.
- **Version comparison** is Sparkle's, on `CFBundleVersion`, which is the
  monotonic Actions run number from ADR 0008; the marketing version comes from
  the git tag and is what the user sees.
- **Publishing.** The release build job generates the feed from the packaged
  archives and signs it with the EdDSA key, then uploads the feed alongside the
  DMG. The key is stored as a CI secret and piped to the signing tool over
  stdin, never written to disk. The same signing tools can build a feed in the
  rehearsal workflow.
- **Key custody.** The EdDSA private key joins the production certificate as a
  release-critical secret: generated once, backed up, and documented alongside
  the signing certificate.
- **Bootstrapping.** The currently released build predates the updater, so it can
  never auto-update. The first build that carries Sparkle must be installed by
  hand; from then on updates flow.
- **Docs.** The README's claim that the app has no updater, and its uninstall
  steps, are updated to match what Sparkle actually leaves behind. Credits gain
  Sparkle's MIT attribution.

## Testing Decisions

- A good test here exercises external behavior through a seam, not Sparkle's
  internals. The only logic we own is the channel gate, so that is the only unit
  seam.
- **`UpdatePolicy` unit tests**, in the style of `ChannelAssetsTests`: an
  injected dictionary with `AKEnableUpdates` true opts in; false opts out; a
  missing key opts out. No test touches the real bundle or starts Sparkle.
- **No new seam for Sparkle.** Version comparison, download, EdDSA verification,
  quarantine stripping, and installation are the framework's own tested
  behavior; wrapping them would test the wrapper, not the feature.
- **Integration is verified end-to-end.** The rehearsal workflow produces a real
  signed feed and archive so the flow can be exercised without publishing. One
  manual pass on a real Mac installs an older build, points it at the rehearsal
  feed, and confirms the update installs, relaunches, and preserves the Input
  Monitoring grant — the check that ADR 0010 records as the reason the update is
  signed at all. The release workflow continues to verify signatures on the
  packaged app and DMG.
- Existing tests must keep passing; the dev channel's behavior is unchanged.

## Out of Scope

- Updates on the dev channel, and any separate dev feed.
- Silent background installs, phased rollouts, and critical updates.
- Binary delta updates.
- Notarization and Developer ID, which ADR 0007 rules out.
- The Mac App Store and Homebrew.
- Custom update UI beyond Sparkle's standard prompts.
- A "what's new" view inside the app beyond the release notes the feed already
  links to.

## Further Notes

- `docs/adr/0010-in-app-updates-with-sparkle.md` records the decision and its
  rejected alternatives.
- The EdDSA private key and the signing certificate are the two release secrets
  whose loss is felt by every existing install. Losing the key alone still leaves
  the certificate identity as the fallback that lets clients update; losing both
  strands installs until users reinstall by hand.
- macOS 14.4's Gatekeeper pre-warm on a non-notarized app is undocumented, so the
  manual test in the Testing Decisions is the proof, not an assumption.
- Two of the steps only a human can do — generating the key and storing the
  secret, and running the real-Mac update test — are candidates for a guided
  wizard.
- The update check contacts GitHub and nothing else; it sends no identifying
  information and nothing about keystrokes.
