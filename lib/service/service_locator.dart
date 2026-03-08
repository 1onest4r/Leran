import 'package:flutter_demo/service/local_storage/local_storage.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<LocalStorage>(() => LocalStorage());
}
