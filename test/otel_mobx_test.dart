// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:mobx/mobx.dart';
import 'package:otel_mobx/otel_mobx.dart';
import 'package:test/test.dart';

class _MemorySpanExporter implements SpanExporter {
  final List<Span> spans = [];
  bool _shutdown = false;

  @override
  Future<void> export(List<Span> s) async {
    if (_shutdown) return;
    spans.addAll(s);
  }

  @override
  Future<void> forceFlush() async {}

  @override
  Future<void> shutdown() async {
    _shutdown = true;
  }
}

Map<String, Object> _attrs(Span span) =>
    {for (final a in span.attributes.toList()) a.key: a.value};

void main() {
  group('tracedRunInAction', () {
    late _MemorySpanExporter exporter;

    setUp(() async {
      await OTel.reset();
      exporter = _MemorySpanExporter();
      await OTel.initialize(
        serviceName: 'mobx-otel-test',
        detectPlatformResources: false,
        spanProcessor: SimpleSpanProcessor(exporter),
      );
    });

    tearDown(() async {
      await OTel.shutdown();
      await OTel.reset();
    });

    test('runs body inside a span and a MobX action', () {
      final count = Observable(0);
      tracedRunInAction('increment', () {
        count.value = count.value + 1;
      });
      expect(count.value, equals(1));

      final span = exporter.spans.single;
      expect(span.name, equals('mobx action increment'));
      expect(span.kind, equals(SpanKind.internal));
      final attrs = _attrs(span);
      expect(attrs['state.system'], equals('mobx'));
      expect(attrs['state.operation'], equals('action'));
      expect(attrs['state.action.name'], equals('increment'));
    });

    test('returns the body return value', () {
      final result = tracedRunInAction<int>('compute', () => 42);
      expect(result, equals(42));
    });

    test('async variant works', () async {
      final count = Observable(0);
      final result = await tracedRunInActionAsync<int>('async_inc', () async {
        count.value = count.value + 1;
        return count.value;
      });
      expect(result, equals(1));

      final span = exporter.spans.single;
      expect(span.name, equals('mobx action async_inc'));
    });

    test('exception flips span to Error and is rethrown', () {
      expect(
        () => tracedRunInAction<void>('boom', () => throw StateError('nope')),
        throwsStateError,
      );
      final span = exporter.spans.single;
      expect(span.status, equals(SpanStatusCode.Error));
      expect(_attrs(span)['error.type'], equals('StateError'));
    });

    test('runWithoutMobxInstrumentation bypasses span creation', () {
      final count = Observable(0);
      runWithoutMobxInstrumentation(() {
        tracedRunInAction('quiet', () => count.value = 99);
      });
      expect(count.value, equals(99));
      expect(exporter.spans, isEmpty);
    });
  });
}
