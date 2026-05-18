// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_aws_sns_suppression.dart';

class AwsSNSResult {
  const AwsSNSResult({
    this.topicArn,
    this.topicName,
    this.messageId,
    this.subject,
    this.subscriptionsConfirmed,
    this.fifo,
    this.region,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? topicArn;
  final String? topicName;
  final String? messageId;
  final String? subject;
  final int? subscriptionsConfirmed;
  final bool? fifo;
  final String? region;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class AwsSNSCallResult<T> {
  const AwsSNSCallResult({required this.value, this.result});
  final T value;
  final AwsSNSResult? result;
}

Future<T> tracedAwsSNS<T>({
  required String operation,
  required Future<AwsSNSCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (awsSNSInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_aws_sns');
  final span = t.startSpan('sns $operation', kind: SpanKind.producer);
  try {
    span.setStringAttribute('messaging.system', 'aws_sns');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.topicArn != null) {
        span.setStringAttribute('messaging.destination.name', res.topicArn!);
      }
      if (res.topicName != null) {
        span.setStringAttribute('aws.sns.topic_name', res.topicName!);
      }
      if (res.messageId != null) {
        span.setStringAttribute('messaging.message.id', res.messageId!);
      }
      if (res.subject != null) {
        span.setStringAttribute('aws.sns.subject', res.subject!);
      }
      if (res.subscriptionsConfirmed != null) {
        span.setIntAttribute(
          'aws.sns.subscriptions_confirmed',
          res.subscriptionsConfirmed!,
        );
      }
      if (res.fifo != null) {
        span.setBoolAttribute('aws.sns.fifo', res.fifo!);
      }
      if (res.region != null) {
        span.setStringAttribute('cloud.region', res.region!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('sns.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'sns.error',
        );
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
