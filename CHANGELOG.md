# Changelog

## [0.2.0-wip]

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
