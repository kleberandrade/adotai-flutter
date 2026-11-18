# Validation record

Validated locally on 2026-11-17 (America/Sao_Paulo).

## Toolchain and dependencies

- Isolated Flutter **3.50.0**, framework revision `ab2912035e160d9cad6306df307576da6128ebdb`; bundled Dart **3.14.0**.
- Material UI **1.11.1**, Shared Preferences **2.5.6**, Flutter Lints **6.0.0**. The original Firebase, MobX, get_it, flushbar and dynamic_theme dependency path was retired.
- `flutter pub outdated` reported direct and dev dependencies current. `vector_math` was upgraded from 2.4.3 to **2.4.4**. Newer `material_color_utilities` 0.13.1 and `test_api` 0.7.15 are outside Flutter's compatible resolved set (0.13.0 and 0.7.14); no overrides applied.
- Framework stable tag was checked against official GitHub tags. Initial artifact-index retrieval failed (404); the official tagged SDK itself was then downloaded and validated. No shared SDK was updated.

## Automated checks

- Formatting completed for all active Dart source and tests.
- `flutter analyze`: **no issues found**.
- `flutter test`: **8 passed**. Coverage includes combined filters/search, favorites/language/request persistence through a new repository instance, invalid application fields, active duplicate prevention, allowed and forbidden transitions, cancellation and reapplication, write failure preserving committed state, corrupt JSON and unknown persisted animal IDs, mobile language/empty state, and the complete profile/form/tracking widget flow.
- The mobile test initially reproduced a dropdown horizontal overflow. `isExpanded` fixed the constrained dropdown; the same test passed afterward.
- The persisted unknown-ID regression test failed before adding read validation and passed after it.
- `flutter build web --release --no-web-resources-cdn`: **passed**, release Web build with local rendering resources (final build: 71.3 seconds).
- Heavy Flutter tests and builds were executed sequentially in this chat.

## Real browser inspection

Chrome desktop (1920×929 viewport) and phone-sized Chrome (390×844) were inspected through browser controls. This is responsive Web inspection, not a physical phone test.

- Catalog, profile, circular language controls, filter controls and mobile bottom navigation rendered visibly.
- Saved Luna as a favorite, switched to Favorites and reloaded; the saved favorite remained.
- Switched to English; the favorite remained, and language was restored after reload.
- Opened Luna's profile, observed inline invalid-form errors, entered fictional data (`Ana Teste`, `ana@example.test`), confirmed the commitment and saved locally.
- Simulated a meeting, reloaded and verified **Meeting simulated** remained in Requests.
- Captured the running desktop, mobile and request screens in `docs/screenshots/`. Conceptual cover and animal illustrations are explicitly distinguished from screenshots.

## Limits and release state

- Local-only learning application: no real animals, shelters, messages, authentication, cloud sync or Firebase/emulator adapter. `PetsRepository` and `StateStore` are substitution boundaries, not proof of a backend implementation.
- Storage is browser-origin preferences, not encrypted/critical storage. No cross-tab coordination or audit history. A new application replaces that pet's cancelled record. Browser policy, eviction or explicit deletion can remove data.
- The historical Android/iOS host projects were not migrated or built. No emulator, native plugin/device or app-store claims. No legal SDK licenses were accepted.
- Keyboard-focusable Material controls, labels, semantic images and tooltips are present. Automated mobile layout and real accessibility-tree inspection were performed; no full WCAG certification or external screen-reader audit is claimed.
- No Medium URL/editor session was available. `MEDIUM_LESSON_PT_BR.md` is a concrete draft with five final exercises, not a published revision.
- Description and seven GitHub topics updated successfully. Repository pushes follow the requested ub-mode workflow. No app, backend, package or hosting deployment is authorized or performed; production publication requires a separate decision.
- GitHub Actions is configured to repeat local checks; its actual run status is available from the README badge. Local success is not a claim that an unobserved remote run passed.
