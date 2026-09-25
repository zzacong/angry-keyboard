## Agent skills

### Issue tracker

Issues and specs live as markdown files under `.scratch/<feature>/` in this repo. See `docs/agents/issue-tracker.md`.

### Triage labels

Five canonical triage roles, label string equal to role name. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.

## Reaching outside this repo

This is a macOS/Xcode project, so tooling routinely touches paths outside the working directory: the SDK, `~/Library`, `~/Documents`, Xcode DerivedData, keychains, launch agents, user defaults. Whenever a change or command touches anything outside this repo, post a short summary in the thread first: the path, read or write, and why.
