import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectPageNotifier extends StateNotifier<int> {
  SelectPageNotifier() : super(0);

  int togglePage(int page) {
    if (state != page) {
      state = page;
    }

    return state;
  }
}

final selectPageProvider =
    StateNotifierProvider<SelectPageNotifier, int>((ref) {
  return SelectPageNotifier();
});
