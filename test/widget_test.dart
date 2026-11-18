import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adotai/modules/pets/pets_page.dart';
import 'package:adotai/modules/pets/pets_repository.dart';

import 'adoption_test.dart' show MemoryStore;

void main() {
  testWidgets('mobile layout, language switch and empty favorites', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repo = LocalPetsRepository(MemoryStore());
    await tester.pumpWidget(AdotaiApp(repository: repo));
    await tester.pumpAndSettle();
    expect(find.textContaining('MODO LOCAL'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('English (United Kingdom)'));
    await tester.pumpAndSettle();
    expect(find.textContaining('LOCAL MODE'), findsOneWidget);
    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();
    expect(find.text('No friends here yet.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('profile, form validation and request tracking work together', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repo = LocalPetsRepository(MemoryStore());
    await tester.pumpWidget(AdotaiApp(repository: repo));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Conheça Luna  →'));
    await tester.tap(find.text('Conheça Luna  →'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quero adotar • simulação'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar solicitação local'));
    await tester.pumpAndSettle();
    expect(find.text('Informe pelo menos 2 caracteres.'), findsOneWidget);
    final fields = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(fields.at(0), 'Ana Teste');
    await tester.enterText(fields.at(1), 'ana@example.test');
    await tester.enterText(
      fields.at(2),
      'Um lar seguro com tempo para carinho e passeios.',
    );
    await tester.tap(find.byType(CheckboxListTile));
    await tester.tap(find.text('Salvar solicitação local'));
    await tester.pumpAndSettle();
    expect(repo.state.requests, hasLength(1));
    expect(find.text('Simular encontro'), findsOneWidget);
    await tester.tap(find.text('Simular encontro'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Concluir simulação'));
    await tester.pumpAndSettle();
    expect(repo.state.requests.single.status.name, 'completed');
  });
}
