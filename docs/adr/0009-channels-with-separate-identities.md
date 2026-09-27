# Run a dev channel beside production with its own identity

**Updated 2026-09-28:** the dev menu bar glyph shipped as the fuming key, so the two channels no longer look alike.

AngryKeyboard is both the app Zac uses every day and the app he develops, and those two roles conflict. Installing a build over the copy in use destroys its Input Monitoring grant and its preferences, and it makes a bug impossible to bisect because the running app is whatever was last built.

So the codebase produces two apps. Production carries `com.zzacong.AngryKeyboard`, the display name "Angry Keyboard", the `AngryKeyboard Production` certificate, and the `AppIcon` icon. Dev carries `com.zzacong.AngryKeyboard.dev`, "Angry Keyboard Dev", `AngryKeyboard Dev`, and `AppIconDev`. The channel is the Xcode build configuration, Debug for dev and Release for production, so there is one app target and no duplicated settings. See ADR 0007 for the certificates and ADR 0008 for the version.

Separate bundle ids give the two apps separate preferences, separate Input Monitoring entries, and separate Login Items, with no code written for any of it. This is the point. macOS keys all of those to the bundle id, so a difference there is enough to let both apps run at once without either one disturbing the other.

Considered and rejected: one app with a debug flag. It cannot run beside itself, and both copies would fight over the same bundle id, preferences, and permission grant. Considered and rejected: two Xcode targets that share sources. It allows independent targets but duplicates every build setting twice and needs them kept in step by hand. Considered and rejected: a `.dev` bundle id with the same display name. The two Input Monitoring entries would then read identically and be impossible to tell apart.

One consequence is that the dev menu bar glyph differs from production by shape, not color, because the status item image is a template that macOS recolors for light and dark menu bars.
