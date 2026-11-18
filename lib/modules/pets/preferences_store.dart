import 'package:shared_preferences/shared_preferences.dart';

import 'pets_repository.dart';

class PreferencesStore implements StateStore {
  final SharedPreferencesAsync preferences = SharedPreferencesAsync();
  static const key = 'adotai.local.v1';
  @override
  Future<String?> read() => preferences.getString(key);
  @override
  Future<void> write(String value) => preferences.setString(key, value);
}
