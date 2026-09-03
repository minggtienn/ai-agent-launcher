import 'package:ai_agent_launcher/core/result/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    test('Success carries its value', () {
      const result = Success(42);
      expect(result.value, 42);
    });

    test('FailureResult carries its error', () {
      final error = StateError('failed');
      final result = FailureResult<int>(error);
      expect(result.error, same(error));
    });
  });
}
