import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/storage/hive_storage.dart';

class MessagesState {
  final List<String> allMessages;
  final String selectedMessage;

  const MessagesState({
    required this.allMessages,
    required this.selectedMessage,
  });

  MessagesState copyWith({List<String>? allMessages, String? selectedMessage}) {
    return MessagesState(
      allMessages: allMessages ?? this.allMessages,
      selectedMessage: selectedMessage ?? this.selectedMessage,
    );
  }
}

class MessagesNotifier extends StateNotifier<MessagesState> {
  MessagesNotifier()
      : super(MessagesState(
          allMessages: [
            ...AppConstants.defaultMessages,
            ...HiveStorage.getCustomMessages(),
          ],
          selectedMessage: HiveStorage.getMessage(),
        ));

  static const int _maxLength = 80;

  Future<void> selectMessage(String message) async {
    await HiveStorage.setMessage(message);
    state = state.copyWith(selectedMessage: message);
  }

  /// Returns null on success, or an error string for the UI to display.
  Future<String?> addCustomMessage(String raw) async {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'Message cannot be empty.';
    if (trimmed.length > _maxLength) {
      return 'Message must be $_maxLength characters or fewer.';
    }
    if (state.allMessages.contains(trimmed)) {
      await selectMessage(trimmed);
      return null;
    }

    final customMessages = HiveStorage.getCustomMessages();
    final updatedCustom = [...customMessages, trimmed];
    await HiveStorage.setCustomMessages(updatedCustom);

    final updatedAll = [...state.allMessages, trimmed];
    state = state.copyWith(allMessages: updatedAll);
    await selectMessage(trimmed);
    return null;
  }

  Future<void> deleteCustomMessage(String message) async {
    if (AppConstants.defaultMessages.contains(message)) return;
    final customMessages = HiveStorage.getCustomMessages()..remove(message);
    await HiveStorage.setCustomMessages(customMessages);

    final updatedAll = state.allMessages.where((m) => m != message).toList();
    String selected = state.selectedMessage;
    if (selected == message) {
      selected = AppConstants.defaultMessages.first;
      await HiveStorage.setMessage(selected);
    }
    state = state.copyWith(allMessages: updatedAll, selectedMessage: selected);
  }
}

final messagesProvider =
    StateNotifierProvider<MessagesNotifier, MessagesState>((ref) {
  return MessagesNotifier();
});
