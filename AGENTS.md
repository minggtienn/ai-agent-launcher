# Agent Rules

These rules apply to every automated agent working in this repository.

1. Default to read-only inspection and planning.
2. Do not create, edit, move or delete files without explicit owner permission
   for the current task.
3. Before editing, state the intended scope and files. Stop for renewed approval
   if unexpected scope appears.
4. Every authorized task that changes the repository must append exactly one
   entry to `CHANGELOG.md`.
5. Edit permission never includes Git commit permission. Present the diff and
   verification results, then wait for separate commit approval.
6. Never amend, rebase, merge, push, tag, release, stash, discard or overwrite
   user changes without explicit authorization for that exact operation.
7. Never store passwords, access tokens, refresh tokens, signing keys or other
   secrets in the repository or logs.
