import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

// 首先，定義一個表示登入狀態的StateNotifier
class AuthState extends StateNotifier<bool> {
  AuthState(this.sharedPreferences) : super(false);

  final SharedPreferences? sharedPreferences;

  // 啟動時讀取登入狀態
  void initialize() {
    if (sharedPreferences != null) {}
    final isLoggedIn = sharedPreferences!.getBool('isLoggedIn') ?? false;
    state = isLoggedIn;
  }

  // 登入和登出操作
  Future<void> login() async {
    await sharedPreferences!.setBool('isLoggedIn', true);
    state = true;
  }

  Future<void> logout() async {
    await sharedPreferences!.setBool('isLoggedIn', false);
    state = false;
  }
}

final authStateProvider = StateNotifierProvider<AuthState, bool>((ref) {
  // 讀取AsyncValue<SharedPreferences>
  final sharedPreferences = ref.watch(sharedPreferencesProvider);

  // 檢查SharedPreferences是否已經載入
  if (sharedPreferences is AsyncData<SharedPreferences>) {
    // SharedPreferences已經載入，可以創建和初始化AuthState
    return AuthState(sharedPreferences.value)..initialize();
  } else {
    // SharedPreferences還沒有載入，返回一個初始的AuthState
    // 這個AuthState將會在SharedPreferences載入後被替換
    return AuthState(null);
  }
});
