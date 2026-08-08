// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:mobx/mobx.dart';
import 'package:otel_mobx/otel_mobx.dart';

Future<void> main() async {
  // Initialize the OpenTelemetry SDK once at app startup. With no
  // exporter configured here, spans print nowhere — point OTLP at your
  // collector via the standard OTEL_EXPORTER_OTLP_* environment
  // variables in a real app.
  await OTel.initialize(serviceName: 'otel-mobx-example');

  final counter = Observable(0);
  final total = Observable(0.0);

  // Each call runs the body inside both a MobX action and an INTERNAL
  // span named `mobx action <name>`, with state.system=mobx,
  // state.operation=action and state.action.name=<name>.
  tracedRunInAction('add_to_cart', () {
    counter.value = counter.value + 1;
    total.value = total.value + 9.99;
  });

  await tracedRunInActionAsync('checkout', () async {
    counter.value = 0;
    total.value = 0.0;
  });

  // Suppression: no spans are created inside this zone.
  runWithoutMobxInstrumentation(() {
    tracedRunInAction('quiet_update', () => counter.value = 42);
  });

  await OTel.shutdown();
}
