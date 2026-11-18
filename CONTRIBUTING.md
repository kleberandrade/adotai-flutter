# Contributing

Use Flutter 3.50.0 / Dart 3.14.0 and the committed lockfile. Keep changes scoped to a domain responsibility and preserve Kleber Andrade's authorship and the original project history.

1. Run `flutter pub get --enforce-lockfile`.
2. Reproduce a behavior with a failing test before changing it when practical.
3. Use fictional names, `example.test` addresses and the local repository. Never contact a real person or organization from tests.
4. Run `dart format lib test`, `flutter analyze`, `flutter test` and `flutter build web --release --no-web-resources-cdn` sequentially.
5. Check PT-BR and EN at phone and desktop widths, keyboard focus, empty states, persistence and errors. Update screenshots when the UI changes.
6. Describe the problem, resulting behavior and actual validation in the pull request. Do not claim native device tests without evidence.

Keep a single repository writer (the UI disables mutations while a save is pending). Backend integrations must enforce authorization, idempotency and transitions on the server. Do not ship production secrets or represent a local simulation as authentication or a real adoption request.

Source contributions are licensed under MIT; dependencies and generated platform files retain their own notices. Do not contribute artwork without known rights and attribution.
