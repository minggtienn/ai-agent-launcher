# Local update feed

This directory is a development-only update feed. Large build artifacts and
the generated `latest.json` are ignored by Git.

1. Build the new launcher with `ALLOW_UNSIGNED_UPDATES=true`.
2. ZIP the contents of the Windows `Release` directory into
   `artifacts/launcher-<version>.zip`.
3. Copy `latest.example.json` to `latest.json`, set `mandatory` to `false`, and
   replace `size` and `sha256` with values from the ZIP.
4. Run `fvm dart run server.dart` in this directory.
5. Start the old development launcher and press
   `KIỂM TRA CẬP NHẬT LAUNCHER`, then `CẬP NHẬT NGAY`.

The `SỬA DỮ LIỆU CẬP NHẬT` action removes interrupted `.zip.part` downloads and
stale staging directories before checking the feed again. It does not delete
verified ZIP files or launcher backups.
