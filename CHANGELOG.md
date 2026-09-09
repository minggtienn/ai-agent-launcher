# Engineering Change Log

This append-only log records one entry per task or pull request.

## [LAU-009] Fix updater helper exit and runtime version footer

- Date: 2026-09-08
- Author: Codex (requested by project owner)
- Type: Added, Changed, Fixed, Test, Documentation
- Module: launcher updater, authentication presentation, Windows runner
- Environments: all, Windows
- Breaking change: No
- Migration/configuration: No

### Purpose

Resolve issues found by Windows launcher update testing: the temporary updater
helper remained alive after a healthy restart, and the login footer displayed
a hard-coded version.

### Changes

- Added a native completion marker so the Windows runner exits the temporary
  helper message loop after apply or rollback finishes.
- Replaced the hard-coded login footer version with runtime package metadata,
  including the build number when present.
- Added a development-only manual update entry point and repair action for
  interrupted downloads or stale staging directories.
- Added a repository-local update feed template whose generated manifests and
  large artifacts remain ignored.
- Kept Flutter binding initialization and `runApp` in the same guarded zone to
  avoid desktop bootstrap zone mismatch warnings.
- Reduced the startup updater window, applied a darker background and anchored
  highlighted window controls to the top-right across updater, login and
  catalog screens.
- Removed the native resize frame so the dark content reaches every window
  edge without an outer black border.
- Disabled the native window shadow so frameless launcher edges render without
  the remaining black halo.
- Changed startup to show only an animated logo for at least 1.5 seconds, enter
  the launcher silently when current, and show progress only while an available
  update is downloaded and applied automatically.
- Reworked the splash so the brand travels horizontally across a transparent
  window, then the dark background appears for two seconds before login or
  update progress is shown.
- Centered the startup brand as two lines (`VTC GAME` and `GAME IS LIFE`) and
  reveal both lines together from left to right.
- Removed the Windows resize border through `window_manager` while retaining
  the standard host window, so custom minimize/close controls keep working.
- Added widget coverage for the runtime version footer.

### Before and after

- Before: A successful update left the temporary helper running, the footer
  continued to show version `1.0.0`, and local recovery was manual.
- After: The native helper exits after completion, the footer reflects the
  installed executable version, and development builds expose update and
  repair controls.

### Verification

- Flutter analyzer passed with no issues.
- All 9 automated tests passed.
- Windows release builds for versions 1.0.0+1 and 1.1.0+2 passed.
- Repository-local Windows E2E passed for download, backup, health check,
  runtime version display and native helper shutdown.

### Risks and rollback

- Rollback fault injection still requires a deliberately unhealthy local
  artifact; the healthy update path is verified on Windows.
- Rollback by reverting this task after explicit owner approval.

### References

- Ticket: LAU-009
- Pull request: Not created
- API/schema/design: `docs/windows-local-launcher-update-test.md`

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

## [LAU-008] Complete portable context after compression baseline

- Date: 2026-09-08
- Author: Codex (requested by project owner)
- Type: Changed, Documentation
- Module: project communication, governance
- Environments: all
- Breaking change: No
- Migration/configuration: No

### Purpose

Reconcile the portable snapshot with all discussion and repository state since
the previous compression baseline.

### Changes

- Added snapshot `CTX-20260908-003` and archived `CTX-20260907-002`.
- Recorded the committed Windows local updater guide and the limitations of
  transferring project context through a shared chat link.
- Advanced the next compression point to `BASELINE-20260908-002`.
- Updated the recorded HEAD and Git synchronization state.

### Before and after

- Before: Current context still identified commit `6e02978` and did not include
  the post-baseline chat-sharing clarification.
- After: Current context identifies commit `2bd2bb0` and covers all discussion
  through the new baseline.

### Verification

- Compared the snapshot with Git status/log, the Windows test guide and recent
  conversation decisions.
- Documentation-only change; no Flutter build or test was run.

### Risks and rollback

- Repository state remains the source of truth if this snapshot becomes stale.
- Rollback by reverting this task after explicit owner approval.

### References

- Ticket: LAU-008
- Pull request: Not created
- API/schema/design: `CHAT_CONTEXT.md`

## [LAU-006] Refresh portable chat context after launcher updater

- Date: 2026-09-07
- Author: Codex (requested by project owner)
- Type: Changed, Documentation
- Module: project communication, governance
- Environments: all
- Breaking change: No
- Migration/configuration: No

### Purpose

Transfer the latest launcher updater decisions, implementation state and game
updater roadmap to another machine or chat platform.

### Changes

- Replaced the current portable snapshot with `CTX-20260907-002`.
- Archived the previous `CTX-20260903-001` snapshot.
- Added the implemented self-update flow, local Windows test recipe, game patch
  decisions, current limitations and next tasks.

### Before and after

- Before: Portable context stopped before launcher updater implementation.
- After: Portable context matches commit `6e02978` and the latest discussion.

### Verification

- Compared the snapshot with Git status/log, `CHANGELOG.md` and the latest
  recorded analyzer/test results.

### Risks and rollback

- Repository state remains the source of truth if the snapshot becomes stale.
- Rollback by reverting this task after explicit owner approval.

### References

- Ticket: LAU-006
- Pull request: Not created
- API/schema/design: `CHAT_CONTEXT.md`

## [LAU-007] Document Windows local launcher update test

- Date: 2026-09-07
- Author: Codex (requested by project owner)
- Type: Added, Changed, Documentation
- Module: launcher updater, project communication
- Environments: development, Windows local
- Breaking change: No
- Migration/configuration: No

### Purpose

Provide a reproducible, step-by-step Windows procedure for validating the
launcher self-update flow locally and mark where future chat compression starts.

### Changes

- Added a Windows local test guide covering two-version builds, ZIP packaging,
  manifest generation, local HTTP hosting, apply verification and failure cases.
- Documented the current limitation around rollback fault injection and HTTP
  Range support in local static servers.
- Added `BASELINE-20260907-001` so the next requested chat snapshot starts with
  discussion after this point.

### Before and after

- Before: Local updater testing existed only as a short recipe in chat context.
- After: Windows testers have an executable checklist and future snapshots have
  an explicit conversation baseline.

### Verification

- Cross-checked commands, manifest fields and expected folders against the
  current updater implementation.
- Documentation-only change; no Flutter build or test was run.

### Risks and rollback

- Exact Windows behavior still requires execution on a Windows machine.
- Rollback by reverting this task after explicit owner approval.

### References

- Ticket: LAU-007
- Pull request: Not created
- API/schema/design: `docs/windows-local-launcher-update-test.md`,
  `CHAT_CONTEXT.md`

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
