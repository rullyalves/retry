import 'package:retry/retry.dart';
import 'package:test/test.dart';

void main() {
  group('test with retry', () {
    test('with retry should retry action 10 times', () async {
      int attemptsCounter = 0;
      int maxAttempts = 10;

      await withRetry(
        () => Future.error('error'),
        maxAttempts: maxAttempts,
        fallback: () => 1,
        onRetry: () {
          ++attemptsCounter;
        },
        backOffType: BackOffType.fixed,
        backOffDelay: Duration(seconds: 1),
      );

      expect(attemptsCounter, maxAttempts);
    });
  });
}
