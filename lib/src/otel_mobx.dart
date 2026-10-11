// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:mobx/mobx.dart' as mobx;

import 'mobx_suppression.dart';

const _tracerName = 'otel_mobx';
const _stateSystem = 'mobx';

APITracer _tracer() => OTelAPI.tracerProvider().getTracer(_tracerName);

/// Typed attribute keys for MobX instrumentation. The OTel semconv
/// registry has no state-management convention yet; these are neutral
/// `state.*` names in a local enum implementing [OTelSemantic] until
/// the registry defines them.
enum MobxSemantics implements OTelSemantic {
  /// `state.system` — the state-management library (`mobx`).
  stateSystem('state.system'),

  /// `state.operation` — the kind of state mutation (`action`).
  stateOperation('state.operation'),

  /// `state.action.name` — the MobX action name.
  stateActionName('state.action.name');

  const MobxSemantics(this.key);

  @override
  final String key;

  @override
  String toString() => key;
}

Attributes _attrs({required String operation, required String actionName}) =>
    OTelAPI.attributesFromMap(<String, Object>{
      MobxSemantics.stateSystem.key: _stateSystem,
      MobxSemantics.stateOperation.key: operation,
      MobxSemantics.stateActionName.key: actionName,
    });

/// Runs [body] inside a MobX action AND inside an OTel span named
/// `mobx action <name>`. The span captures wall time for the
/// action — including any synchronous reactions it triggered.
///
/// ```dart
/// tracedRunInAction('add_to_cart', () {
///   cart.add(item);
///   total.value += item.price;
/// });
/// ```
T tracedRunInAction<T>(String name, T Function() body) {
  if (mobxInstrumentationSuppressed()) {
    return mobx.runInAction(body, name: name);
  }
  final span = _tracer().startSpan(
    'mobx action $name',
    kind: SpanKind.internal,
    attributes: _attrs(operation: 'action', actionName: name),
  );
  try {
    return mobx.runInAction(body, name: name);
  } catch (e, st) {
    span.addAttributes(OTelAPI.attributes([
      OTelAPI.attributeString(
        ErrorAttributes.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}

/// Async variant of [tracedRunInAction] — useful when the body
/// performs awaits (note: MobX itself recommends `asyncAction`
/// for that pattern; this wrapper is more permissive).
Future<T> tracedRunInActionAsync<T>(
  String name,
  Future<T> Function() body,
) async {
  if (mobxInstrumentationSuppressed()) {
    return mobx.runInAction(body, name: name);
  }
  final span = _tracer().startSpan(
    'mobx action $name',
    kind: SpanKind.internal,
    attributes: _attrs(operation: 'action', actionName: name),
  );
  try {
    return await mobx.runInAction(body, name: name);
  } catch (e, st) {
    span.addAttributes(OTelAPI.attributes([
      OTelAPI.attributeString(
        ErrorAttributes.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
