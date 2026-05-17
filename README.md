# otel_aws_sns

Dartastic OpenTelemetry bridge for AWS SNS (managed pub/sub).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_aws_sns/otel_aws_sns.dart';

await tracedAwsSNS<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return AwsSNSCallResult(value: r, result: AwsSNSResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutAwsSNSInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
