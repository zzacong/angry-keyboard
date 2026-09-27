## Agent skills

### Issue tracker

Issues and specs live as markdown files under `.scratch/<feature>/` in this repo. See `docs/agents/issue-tracker.md`.

### Triage labels

Five canonical triage roles plus a resolved state, the label string equal to the role name. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.

## Commits

Use Conventional Commit subjects in `type(scope): description` format. Use
`app` for macOS app changes and `site` for changes under `site/`. When neither
area fits, choose a scope that names the work, such as `ci`, `build`, or another
relevant area.

Keep app and site changes in separate commits.

## Reaching outside this repo

This is a macOS/Xcode project, so tooling routinely touches paths outside the working directory: the SDK, `~/Library`, `~/Documents`, Xcode DerivedData, keychains, launch agents, user defaults. Whenever a change or command touches anything outside this repo, post a short summary in the thread first: the path, read or write, and why.

## Browser work

For browser interaction, website testing, or visual QA, load the `agent-browser`
skill and use its CLI workflow. Do not use OpenCode's built-in `browser.*` tools
in the TUI. They attach to the desktop app and are unavailable there.
