import 'package:material_ui/material_ui.dart';

import 'modules/pets/pets_page.dart';
import 'modules/pets/pets_repository.dart';
import 'modules/pets/preferences_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(AdotaiApp(repository: LocalPetsRepository(PreferencesStore())));
}
