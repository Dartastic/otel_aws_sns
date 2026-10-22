// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_aws_sns_suppression.dart';

class AwsSNSResult {
  /// Creates a result.
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

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class AwsSNSCallResult<T> {
  /// Creates a call result.
  const AwsSNSCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final AwsSNSResult? result;
}

Future<T> tracedAwsSNS<T>({
  required String operation,
  required Future<AwsSNSCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (awsSNSInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_aws_sns');
  final span = t.startSpan('sns $operation', kind: SpanKind.producer);
  try {
    span.addAttributes(OTelAPI.attributes(
        [OTelAPI.attributeString('messaging.system', 'aws_sns')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.topicArn != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('messaging.destination.name', res.topicArn!)
        ]));
      }
      if (res.topicName != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('aws.sns.topic_name', res.topicName!)]));
      }
      if (res.messageId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('messaging.message.id', res.messageId!)]));
      }
      if (res.subject != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('aws.sns.subject', res.subject!)]));
      }
      if (res.subscriptionsConfirmed != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt(
            'aws.sns.subscriptions_confirmed',
            res.subscriptionsConfirmed!,
          )
        ]));
      }
      if (res.fifo != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeBool('aws.sns.fifo', res.fifo!)]));
      }
      if (res.region != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('cloud.region', res.region!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('sns.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            ErrorAttributes.errorType.key,
            res.errorCode ?? 'sns.error',
          )
        ]));
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
