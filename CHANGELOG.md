# Changelog

## [0.3.2-wip]

## [0.3.1] - 2026-10-17

### Changed

- README: standard header naming the instrumented library, its supported platforms and project links; pubspec description to match.

## [0.3.0] - 2026-10-11

### Changed

- Requires `dartastic_opentelemetry_api >=1.0.0-rc.4 <1.0.0-rc.5`.
- **Breaking:** depends on `dartastic_opentelemetry_api` only, no
  longer on the SDK. The application chooses and initializes the
  OpenTelemetry SDK. Parameters and fields typed with SDK classes
  now use the API types (`APITracer`, `APISpan`, `APILogger`, ...);
  SDK instances are still accepted wherever an API type is expected.

## [0.2.0] - 2026-08-10

### Changed

- Attribute keys are typed constants: the `state.*` keys now live in a
  `MobxSemantics` enum implementing `OTelSemantic` (the semconv registry
  has no state-management convention yet; the emitted keys are unchanged).
- Dependency floors raised to `dartastic_opentelemetry ^1.1.0-beta.12` and
  `dartastic_opentelemetry_api ^1.0.0-rc.1`. The previous floors declared
  compatibility with API versions that predate the semconv enums this
  package uses and could not actually resolve-and-compile.
- `repository` URL corrected to the canonical `Dartastic` org casing so
  pub.dev repository verification succeeds.

### Added

- `tracedRunInAction<T>(name, body)` — runs [body] inside both a
  MobX action and an OTel INTERNAL span named
  `mobx action <name>`, carrying `state.system=mobx`,
  `state.operation=action`, `state.action.name`.
- `tracedRunInActionAsync<T>(name, body)` — async variant.
- Zone-scoped suppression
  (`runWithoutMobxInstrumentation` and async variant).
- 5 tests via real MobX `Observable` (no mocks needed).
- `example/otel_mobx_example.dart`.
