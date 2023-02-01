import 'dart:async';
import 'dart:developer';

typedef Test = FutureOr<bool> Function(dynamic exception);
typedef Action<T> = FutureOr<T> Function();
typedef VoidAction = FutureOr<void> Function();

enum BackOffType { exponential, fixed }

FutureOr<T> withRetryWhen<T>(
  Action<T> doAction, {
  Action<T>? fallback,
  VoidAction? onRetry,
  required Test shouldRetryWhile,
  Duration backOffDelay = const Duration(seconds: 1),
  Duration maxDelayBeetwenAttempts = const Duration(seconds: 30),
  BackOffType backOffType = BackOffType.fixed,
}) async {
  final result = await _doTask<T>(
    doAction,
    onRetry: () async => await onRetry?.call(),
    shouldRetryWhile: shouldRetryWhile,
    backOffType: backOffType,
    initialBackOffDelay: backOffDelay,
    maxDelayBeetwenAttempts: maxDelayBeetwenAttempts,
    fallback: fallback,
  );

  return result;
}

FutureOr<T> withRetry<T>(
  Action<T> doAction, {
  Action<T>? fallback,
  VoidAction? onRetry,
  int? maxAttempts,
  Duration backOffDelay = const Duration(seconds: 1),
  Duration maxDelayBeetwenAttempts = const Duration(seconds: 30),
  BackOffType backOffType = BackOffType.fixed,
}) async {
  int retryStep = 0;

  final result = await _doTask<T>(
    doAction,
    onRetry: () async {
      ++retryStep;
      await onRetry?.call();
    },
    shouldRetryWhile: (_) => retryStep != maxAttempts,
    backOffType: backOffType,
    initialBackOffDelay: backOffDelay,
    maxDelayBeetwenAttempts: maxDelayBeetwenAttempts,
    fallback: fallback,
  );
  return result;
}

Future<T> _doTask<T>(
  Action<T> doAction, {
  Action<T>? fallback,
  required Test shouldRetryWhile,
  required VoidAction onRetry,
  Duration? currentDelay,
  required Duration initialBackOffDelay,
  required Duration maxDelayBeetwenAttempts,
  required BackOffType backOffType,
}) async {
  try {
    final result = await doAction();
    return result;
  } catch (exception) {
    final shouldRetry = await shouldRetryWhile(exception);
    if (shouldRetry) {
      Duration? delay = currentDelay;
      if (delay != null) {
        if (backOffType == BackOffType.exponential && delay < maxDelayBeetwenAttempts) {
          delay = delay + delay;
        }
      } else {
        delay = initialBackOffDelay;
      }

      await onRetry();

      log('retrying with delay $delay');

      await Future.delayed(delay);
      return _doTask(
        doAction,
        fallback: fallback,
        backOffType: backOffType,
        initialBackOffDelay: initialBackOffDelay,
        currentDelay: delay,
        maxDelayBeetwenAttempts: maxDelayBeetwenAttempts,
        shouldRetryWhile: shouldRetryWhile,
        onRetry: onRetry,
      );
    } else {
      if (fallback != null) {
        return fallback();
      } else {
        rethrow;
      }
    }
  }
}
