import 'dart:io';

void main(List<String> arguments) {
  final base = arguments.isEmpty ? 'origin/main' : arguments.first;
  final changed = Process.runSync('git', [
    'diff',
    '--name-only',
    '$base...HEAD',
  ]);
  if (changed.exitCode != 0) {
    stderr.write(changed.stderr);
    exitCode = changed.exitCode;
    return;
  }
  final files = (changed.stdout as String)
      .split('\n')
      .where((line) => line.isNotEmpty)
      .toSet();
  if (files.isEmpty) return;
  if (!files.contains('CHANGELOG.md')) {
    stderr.writeln(
      'CHANGELOG.md must be updated for every task or pull request.',
    );
    exitCode = 1;
    return;
  }
  final added = Process.runSync('git', [
    'diff',
    '--unified=0',
    '$base...HEAD',
    '--',
    'CHANGELOG.md',
  ]);
  final addedText = added.stdout as String;
  final entryPattern = RegExp(r'^\+## \[[A-Z]+-\d+\] .+$', multiLine: true);
  if (!entryPattern.hasMatch(addedText)) {
    stderr.writeln(
      'CHANGELOG.md must append a heading such as ## [LAU-123] Title.',
    );
    exitCode = 1;
  }
}
