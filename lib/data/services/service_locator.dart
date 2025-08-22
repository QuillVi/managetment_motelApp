import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:motelapp/data/repositories/auth_repository.dart';
import 'package:motelapp/data/repositories/building_repository/list_building_repo.dart';
import 'package:motelapp/data/repositories/building_repository/list_room_in_building_repository.dart';
import 'package:motelapp/data/repositories/home_repository/statistical_home_repo.dart';
import 'package:motelapp/logic/cubits/auth/auth_cubit.dart';
import 'package:motelapp/logic/cubits/building/list_building_cubit.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/room_in_building_cubit.dart';
import 'package:motelapp/logic/cubits/home/statistical_cubit.dart';
import 'package:motelapp/router/app_router.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  WidgetsFlutterBinding.ensureInitialized();

  getIt.registerLazySingleton(() => AppRouter());
  getIt.registerLazySingleton(() => AuthRepository());
  getIt.registerLazySingleton(() => StatisticalHomeRepository());
  getIt.registerLazySingleton(() => ListBuildingRepository());
  getIt.registerLazySingleton(() => ListRoomInBuildingRepository());

  getIt.registerLazySingleton(
    () => AuthCubit(authRepository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton(
    () => StatisticalCubit(
      statisticalHomeRepository: getIt<StatisticalHomeRepository>(),
    ),
  );

  getIt.registerLazySingleton(
    () => ListBuildingCubit(
      listBuildingRepository: getIt<ListBuildingRepository>(),
    ),
  );

  getIt.registerLazySingleton(
    () => RoomInBuildingCubit(
      listRoomInBuildingRepository: getIt<ListRoomInBuildingRepository>(),
    ),
  );
}
