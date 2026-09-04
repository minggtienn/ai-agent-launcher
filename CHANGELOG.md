# Engineering Change Log

This append-only log records one entry per task or pull request.

## [LAU-001] Bootstrap Flutter Windows launcher architecture

- Date: 2026-09-03
- Author: Codex (requested by project owner)
- Type: Added, Changed, Dependency, Documentation
- Module: project foundation, application shell, governance
- Environments: all
- Breaking change: No
- Migration/configuration: Pin Flutter 3.44.4 with FVM

### Purpose

Create the initial Windows launcher foundation using feature-first Clean
Architecture, BLoC/Cubit, GetIt/Injectable and REST-oriented contracts.

### Changes

- Created the Flutter Windows project and pinned its SDK.
- Added the approved runtime, Windows and development dependency groups.
- Added application configuration, core contracts and feature boundaries.
- Replaced `protocol_handler` with `app_links` because its Windows registry
  dependency conflicts with `launch_at_startup`.
- Added architecture and governance documentation.

### Before and after

- Before: Empty workspace.
- After: Flutter Windows foundation ready for feature delivery.

### Verification

- `fvm flutter analyze`: passed with no issues.
- `fvm flutter test`: passed, 4 tests.
- Injectable code generation: completed successfully.
- Windows release build: pending a Windows runner; the current host is macOS.

### Risks and rollback

- Native Windows behavior still requires verification on a Windows runner.
- Rollback by reverting this task after explicit owner approval.

### References

- Ticket: LAU-001
- Pull request: Not created
- API/schema/design: `docs/architecture.md`

## [LAU-002] Initialize Git repository

- Date: 2026-09-03
- Author: Codex (requested by project owner)
- Type: Changed
- Module: repository configuration
- Environments: all
- Breaking change: No
- Migration/configuration: Added the GitHub repository as `origin`

### Purpose

Connect the local project to its approved GitHub repository.

### Changes

- Initialized an empty Git repository with `main` as the default branch.
- Added `https://github.com/minggtienn/ai-agent-launcher.git` as `origin`.

### Before and after

- Before: The project directory was not a Git repository.
- After: Local Git metadata and the `origin` remote are configured.

### Verification

- `git remote -v` reports the expected fetch and push URLs.
- `git status` reports an uncommitted `main` branch.

### Risks and rollback

- No source files were committed or pushed.
- Removing Git metadata requires separate explicit owner authorization.

### References

- Ticket: LAU-002
- Pull request: Not created
- API/schema/design: Not applicable

## [LAU-003] Implement desktop launcher login screen

- Date: 2026-09-03
- Author: Codex (requested by project owner)
- Type: Added, Changed
- Module: authentication presentation, desktop window
- Environments: all
- Breaking change: No
- Migration/configuration: No

### Purpose

Implement the first desktop screen based on the approved launcher reference.

### Changes

- Added a responsive campaign, news and login split layout.
- Added branded login controls, validation, password visibility and secondary actions.
- Added a hidden desktop title bar, drag area, window controls and initial size.
- Kept campaign artwork behind a replaceable widget until final image assets are supplied.

### Before and after

- Before: Generic centered Material login card.
- After: Desktop-first launcher login matching the reference composition.

### Verification

- `fvm flutter analyze`: passed with no issues.
- `fvm flutter test`: passed, including the 1280x720 login layout test.

### Risks and rollback

- Final visual fidelity depends on receiving the original banner, logo and news assets.
- Rollback by reverting this task after explicit owner approval.

### References

- Ticket: LAU-003
- Pull request: Not created
- API/schema/design: User-provided login screen reference

## [LAU-004] Add portable chat context

- Date: 2026-09-03
- Author: Codex (requested by project owner)
- Type: Added, Documentation
- Module: project communication, governance
- Environments: all
- Breaking change: No
- Migration/configuration: No

### Purpose

Allow project context to move safely between machines and chat platforms.

### Changes

- Added `CHAT_CONTEXT.md` with the current compressed project context.
- Defined the process for snapshots by day or requested point in time.
- Preserved authorization boundaries so a snapshot never grants edit or Git
  permissions to another agent.

### Before and after

- Before: Project context depended on the current conversation.
- After: A structured, portable context file can bootstrap another session.

### Verification

- Checked the snapshot against `AGENTS.md`, recent changelog entries and Git
  repository state.

### Risks and rollback

- Snapshots can become stale; repository state remains the source of truth.
- Rollback by reverting this task after explicit owner approval.

### References

- Ticket: LAU-004
- Pull request: Not created
- API/schema/design: `CHAT_CONTEXT.md`

## [LAU-005] Implement launcher self-update foundation

- Date: 2026-09-04
- Author: Codex (requested by project owner)
- Type: Added, Changed, Security
- Module: launcher updater, startup routing, Windows lifecycle
- Environments: all
- Breaking change: No
- Migration/configuration: Configure launcher manifest URL and Ed25519 public key

### Purpose

Update the launcher before login with a Discord-style progress experience while
avoiding a separately maintained updater application.

### Changes

- Added manifest checking, resumable ZIP download, size/SHA-256/signature checks
  and safe staging extraction.
- Added a startup update BLoC and compact updater screen before login.
- Added a self-copy apply mode that switches launcher directories, performs a
  startup health check and rolls back on failure.
- Added update configuration, tests and release documentation.
- Deferred game patching and game disk configuration to the next approved task.

### Before and after

- Before: Updater existed only as an empty domain interface.
- After: Launcher updates are checked and prepared before login, with a Windows
  self-apply path and rollback protection.

### Verification

- Injectable code generation completed successfully.
- `fvm flutter analyze`: passed with no issues.
- `fvm flutter test`: passed, 8 tests.
- `git diff --check`: passed.
- Final apply/rollback must also be tested using signed artifacts on Windows.

### Risks and rollback

- Installation directory must be writable and staging must remain on the same volume.
- Rollback by reverting this task after explicit owner approval.

### References

- Ticket: LAU-005
- Pull request: Not created
- API/schema/design: `docs/architecture.md`
