import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserIDNotifier extends StateNotifier<int> {
  UserIDNotifier() : super(1);

  int setUserId(int UserId) {
    state = UserId;

    return state;
  }
}

final userIdProvider = StateNotifierProvider<UserIDNotifier, int>((ref) {
  return UserIDNotifier();
});
