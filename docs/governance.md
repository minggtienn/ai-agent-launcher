# Project Governance

## Owner authorization

Read-only inspection is the default. Creating, editing, moving or deleting a
file requires explicit owner authorization for the current task. Authorization
does not carry to another task. Unexpected scope must be approved before work
continues.

Commit authorization is separate from edit authorization. Never commit, amend,
rebase, merge, push, tag, release, stash or discard changes without the exact
permission required for that action.

## Change workflow

1. Inspect without changing tracked files.
2. Present the goal, approach, files and writing commands.
3. Obtain owner authorization for the task.
4. Change only the approved scope and append one `CHANGELOG.md` entry.
5. Run checks and present the diff and results.
6. Request separate authorization before creating a commit.

## Ownership

| Area | Owner | Required review |
| --- | --- | --- |
| Presentation/UI | Flutter/UI team | Feature owner |
| Domain | Feature owner | Code leader |
| Data/API/database | Developer/Senior | Feature owner |
| Authentication/security | Security owner | Security + code leader |
| Download/updater | Windows/Release owner | Two approvals |
| Windows/installer | Windows/DevOps | Code leader + release |
| Dependencies/FVM/lints | Code leader | Code leader |
| CI/CD/signing | DevOps | Release + security |
| `CHANGELOG.md` | Assigned contributor | Code leader |

Ownership never overrides the project owner's authorization requirement.
