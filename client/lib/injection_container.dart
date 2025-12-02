import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Biến toàn cục để gọi Dependency Injection ở bất cứ đâu
final sl = GetIt.instance;

Future<void> init() async {
  // --- 1. External (Các thư viện bên ngoài) ---
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // --- 2. Core ---
  // (Sau này sẽ đăng ký NetworkInfo, ApiClient tại đây)

  // --- 3. Features ---

  // Ví dụ: Auth Feature (Sau này bỏ comment khi code xong Auth)
  // sl.registerFactory(() => AuthBloc(sl()));
  // sl.registerLazySingleton(() => AuthRepository(sl()));
}