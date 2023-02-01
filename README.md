<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

## Getting started

A small library for handle retry with max attempts or exponential backoff

## Usage


view `/example` folder for examples

```dart
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
```