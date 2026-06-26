import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/hive_storage.dart';

class ThemeSelectionNotifier extends StateNotifier<String> {
  ThemeSelectionNotifier() : super(HiveStorage.getThemeId());

  Future<void> select(String themeId) async {
    await HiveStorage.setThemeId(themeId);
    state = themeId;
  }
}

final themeSelectionProvider =
    StateNotifierProvider<ThemeSelectionNotifier, String>((ref) {
  return ThemeSelectionNotifier();
});
