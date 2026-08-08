// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'dart:async';

const Symbol _suppressKey = #otel_mobx_suppress;

/// Whether MobX instrumentation is suppressed in the current [Zone]
/// (i.e. the caller is inside [runWithoutMobxInstrumentation] or
/// [runWithoutMobxInstrumentationAsync]).
bool mobxInstrumentationSuppressed() {
  return Zone.current[_suppressKey] == true;
}

/// Runs [body] with MobX instrumentation suppressed: `traced*` calls
/// made inside it execute normally but create no spans.
T runWithoutMobxInstrumentation<T>(T Function() body) {
  return runZoned(body, zoneValues: {_suppressKey: true});
}

/// Async variant of [runWithoutMobxInstrumentation].
Future<T> runWithoutMobxInstrumentationAsync<T>(
  Future<T> Function() body,
) {
  return runZoned(body, zoneValues: {_suppressKey: true});
}
