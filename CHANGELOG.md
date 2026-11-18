# Changelog

## 2.0.0 — 2026-11-17

- Migrated from Dart 2.7 and retired Firebase/MobX APIs to Flutter 3.50.0 / Dart 3.14.0 and Material UI 1.11.1.
- Retained the pets module and its catalog fields; separated model, repository, persistence adapter and presentation.
- Added a credential-free, explicitly labeled local catalog with six fictional animals, combinable name/species/size filters, profiles and favorites.
- Added validated simulated adoption requests, duplicate prevention, meeting/completion/cancellation transitions and browser persistence.
- Added PT-BR/EN with locally drawn circular flags and original local animal illustrations.
- Added responsive layouts, loading, empty and recoverable save error states, behavioral tests, Web checks and refreshed documentation.
- Removed obsolete account/editor and generated MobX code from the active path. Historical source remains in git; no Firebase backend or identity migration is claimed.
