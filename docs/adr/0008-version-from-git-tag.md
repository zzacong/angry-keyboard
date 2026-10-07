# Derive the version from the git tag and inject it at build time

An app has two version numbers, the marketing version people see and a build number that must only ever increase. Writing either into `project.pbxproj` means every release edits the project file, and a missed edit ships the wrong number.

So the git tag is the only source of truth. Release Please creates the tag from the conventional commits, and the release workflow reads that tag and passes `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` to `xcodebuild` as build settings. The repository file is never edited for a release, and the committed values are placeholders that only appear in local builds; release CI overrides them. The build number comes from the Actions run number, which always increases.

Considered and rejected: committing the bump into `project.pbxproj` with a script. It works, but it puts release state in a file that is easy to edit by hand and easy to forget, and it makes every release commit touch the project file.
