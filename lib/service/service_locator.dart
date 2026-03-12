import 'package:flutter_demo/app_state.dart';
import 'package:flutter_demo/service/auth/auth.dart';
import 'package:flutter_demo/service/local_storage/local_storage.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<LocalStorage>(() => LocalStorage());
  getIt.registerLazySingleton<Auth>(() => Auth());
  getIt.registerLazySingleton<AppState>(() => AppState());
}
