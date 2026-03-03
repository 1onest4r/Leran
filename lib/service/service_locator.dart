import 'local_storage/local_storage.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupServiceLoader() {
  getIt.registerLazySingleton<LocalStorage>(() => LocalStorage());
}
