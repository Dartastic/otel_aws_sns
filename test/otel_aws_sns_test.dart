// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

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
