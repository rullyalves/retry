import 'package:retry/retry.dart';

void main() async {
  await withRetry(
    () => Future.error('error'),
    maxAttempts: 10,
    fallback: () => 1,
    backOffType: BackOffType.exponential,
    backOffDelay: Duration(seconds: 1),
    onRetry: () {},
    maxDelayBeetwenAttempts: Duration(seconds: 4),
  );

  await withRetryWhen(
    () => Future.error('error'),
    shouldRetryWhile: (exception) => exception is String,
    backOffType: BackOffType.fixed,
  );
}
