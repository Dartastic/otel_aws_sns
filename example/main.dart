// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_aws_sns/otel_aws_sns.dart';

/// Traces Aws Sns calls with OpenTelemetry.
///
/// `otel_aws_sns` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Aws Sns call in
/// [tracedAwsSNS]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'aws-sns-example');

  // Traces a Aws Sns call.
  final awsSNSId = await tracedAwsSNS<String>(
    operation: 'create',
    invoke: () async {
      // Make the Aws Sns call here, then report what it returned.
      const id = 'aws_sns_8f3a2c';
      return const AwsSNSCallResult(
          value: id,
          result: AwsSNSResult(
              topicArn: 'orders',
              topicName: 'orders',
              messageId: 'message_8f3a2c',
              subject: 'example',
              subscriptionsConfirmed: 1,
              fifo: true,
              region: 'us-east-1',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedAwsSNS create returned $awsSNSId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutAwsSNSInstrumentationAsync.
  await runWithoutAwsSNSInstrumentationAsync(
    () => tracedAwsSNS<String>(
      operation: 'create',
      invoke: () async {
        const id = 'aws_sns_8f3a2c';
        return const AwsSNSCallResult(
            value: id,
            result: AwsSNSResult(
                topicArn: 'orders',
                topicName: 'orders',
                messageId: 'message_8f3a2c',
                subject: 'example',
                subscriptionsConfirmed: 1,
                fifo: true,
                region: 'us-east-1',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
