// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:otel_aws_sns/otel_aws_sns.dart';
import 'package:test/test.dart';

void main() {
  group('otel_aws_sns', () {
    test('suppression toggles in zone', () async {
      expect(awsSNSInstrumentationSuppressed(), isFalse);
      await runWithoutAwsSNSInstrumentationAsync(() async {
        expect(awsSNSInstrumentationSuppressed(), isTrue);
      });
      expect(awsSNSInstrumentationSuppressed(), isFalse);
    });

    test('AwsSNSResult fields default null', () {
      const r = AwsSNSResult();
      expect(r.statusCode, isNull);
    });
  });
}
