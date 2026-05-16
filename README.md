# otel_mobx

OpenTelemetry instrumentation for
[`package:mobx`](https://pub.dev/packages/mobx).

```dart
import 'package:otel_mobx/otel_mobx.dart';

tracedRunInAction('add_to_cart', () {
  cart.add(item);
  total.value += item.price;
});

await tracedRunInActionAsync('checkout', () async {
  cart.clear();
  user.lastPurchase = DateTime.now();
});
```

Each call opens an INTERNAL span named `mobx action <name>` with
`state.system=mobx`, `state.operation=action`,
`state.action.name=<name>`. The span captures wall time for the
action body — including any synchronous reactions it triggered.

Suppression: `runWithoutMobxInstrumentation` and its async
variant.

## License

Apache 2.0
