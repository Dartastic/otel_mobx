# Changelog

## [0.1.0-beta.1-wip]

### Added

- `tracedRunInAction<T>(name, body)` — runs [body] inside both a
  MobX action and an OTel INTERNAL span named
  `mobx action <name>`, carrying `state.system=mobx`,
  `state.operation=action`, `state.action.name`.
- `tracedRunInActionAsync<T>(name, body)` — async variant.
- Zone-scoped suppression
  (`runWithoutMobxInstrumentation` and async variant).
- 5 tests via real MobX `Observable` (no mocks needed).
