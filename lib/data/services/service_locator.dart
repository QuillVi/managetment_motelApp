import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:motelapp/data/repositories/auth_repository.dart';
import 'package:motelapp/data/repositories/building_repository/detail_building_repository.dart';
import 'package:motelapp/data/repositories/building_repository/list_building_repo.dart';
import 'package:motelapp/data/repositories/building_repository/list_room_in_building_repository.dart';
import 'package:motelapp/data/repositories/home_repository/service_repository/create_service_repository.dart';
import 'package:motelapp/data/repositories/home_repository/service_repository/service_home_repository.dart';
import 'package:motelapp/data/repositories/home_repository/statistical_home_repo.dart';
import 'package:motelapp/data/repositories/home_repository/lessee_repository/list_lessee_repository.dart';
import 'package:motelapp/data/repositories/problem_repository/list_problem_repository.dart';
import 'package:motelapp/data/repositories/room_repository/detail_room_repository.dart';
import 'package:motelapp/data/repositories/room_repository/detail_tanent_reposittory.dart';
import 'package:motelapp/data/repositories/room_repository/tanent_room_repository.dart';
import 'package:motelapp/logic/cubits/auth/auth_cubit.dart';
import 'package:motelapp/logic/cubits/building/detail_building_cubit.dart';
import 'package:motelapp/logic/cubits/building/list_building_cubit.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/detail_room_cubit.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/detail_tanent_cubit.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/room_in_building_cubit.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/tanent_room_cubit.dart';
import 'package:motelapp/logic/cubits/home/problem_home/list_problem_cubit.dart';
import 'package:motelapp/logic/cubits/home/service_home/create_service_cubit.dart';
import 'package:motelapp/logic/cubits/home/service_home/service_cubit.dart';
import 'package:motelapp/logic/cubits/home/statistical_cubit.dart';
import 'package:motelapp/logic/cubits/home/tanent_home/lessee_cubit.dart';
import 'package:motelapp/router/app_router.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register your services, repositories, and cubits here
  getIt.registerLazySingleton(() => AppRouter());
  getIt.registerLazySingleton(() => AuthRepository());
  getIt.registerLazySingleton(() => StatisticalHomeRepository());
  getIt.registerLazySingleton(() => ListBuildingRepository());
  getIt.registerLazySingleton(() => ListRoomInBuildingRepository());
  getIt.registerLazySingleton(() => DetailBuildingRepository());
  getIt.registerLazySingleton(() => ServiceHomeRepository());
  getIt.registerLazySingleton(() => DetailRoomRepository());
  getIt.registerLazySingleton(() => TanentRoomRepository());
  getIt.registerLazySingleton(() => DetailTanentReposittory());
  getIt.registerLazySingleton(() => CreateServiceRepository());
  getIt.registerLazySingleton(() => ListLesseeRepository());
  getIt.registerLazySingleton(() => ListProblemDoneRepository());
  getIt.registerLazySingleton(() => ListProblemRequestingRepository());

  // Register DetailRoomRepository
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

  getIt.registerLazySingleton(
    () => DetailBuildingCubit(
      detailBuildingRepository: getIt<DetailBuildingRepository>(),
    ),
  );

  getIt.registerLazySingleton(
    () => ServiceCubit(serviceHomeRepository: getIt<ServiceHomeRepository>()),
  );
  getIt.registerLazySingleton(
    () => DetailRoomCubit(detailRoomRepository: getIt<DetailRoomRepository>()),
  );

  getIt.registerLazySingleton(
    () => TanentRoomCubit(tanentRoomRepository: getIt<TanentRoomRepository>()),
  );

  getIt.registerLazySingleton(
    () => DetailTanentCubit(
      detailTanentReposittory: getIt<DetailTanentReposittory>(),
    ),
  );

  getIt.registerLazySingleton(
    () => CreateServiceCubit(
      createServiceRepository: getIt<CreateServiceRepository>(),
    ),
  );
  getIt.registerLazySingleton(
    () => LesseeCubit(listTanentRepository: getIt<ListLesseeRepository>()),
  );

  getIt.registerLazySingleton(
    () => ListProblemRequestingCubit(
      listProblemRequestingRepository: getIt<ListProblemRequestingRepository>(),
    ),
  );
  getIt.registerLazySingleton(
    () => ListProblemDonedCubit(
      listProblemDoneRepository: getIt<ListProblemDoneRepository>(),
    ),
  );
}
