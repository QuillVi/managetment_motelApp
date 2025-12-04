import 'package:get_it/get_it.dart';
import 'package:motelapp/data/repositories/auth_repository.dart';
import 'package:motelapp/data/repositories/bill_repository/bill_repository.dart';
import 'package:motelapp/data/repositories/building_repository/amenity_repository.dart';
import 'package:motelapp/data/repositories/building_repository/create_building_repository.dart';
import 'package:motelapp/data/repositories/building_repository/detail_building_repository.dart';
import 'package:motelapp/data/repositories/building_repository/list_building_repo.dart';
import 'package:motelapp/data/repositories/building_repository/list_room_in_building_repository.dart';
import 'package:motelapp/data/repositories/cost_repository/cost_repository.dart';
import 'package:motelapp/data/repositories/home_repository/contract_repository/contract_home_repository.dart';
import 'package:motelapp/data/repositories/home_repository/service_repository/create_service_repository.dart';
import 'package:motelapp/data/repositories/home_repository/service_repository/service_home_repository.dart';
import 'package:motelapp/data/repositories/home_repository/statistical_home_repo.dart';
import 'package:motelapp/data/repositories/home_repository/lessee_repository/list_lessee_repository.dart';
import 'package:motelapp/data/repositories/manage_repository/manage_repository.dart';
import 'package:motelapp/data/repositories/owe_repository/owe_repository.dart';
import 'package:motelapp/data/repositories/problem_repository/create_problem_repository.dart';
import 'package:motelapp/data/repositories/problem_repository/detail_problem_repository.dart';
import 'package:motelapp/data/repositories/problem_repository/list_problem_repository.dart';
import 'package:motelapp/data/repositories/problem_repository/select_room_problem_repository.dart';
import 'package:motelapp/data/repositories/room_repository/add_tanent_room_repository.dart';
import 'package:motelapp/data/repositories/room_repository/create_room_repository.dart';
import 'package:motelapp/data/repositories/room_repository/detail_room_repository.dart';
import 'package:motelapp/data/repositories/room_repository/detail_tanent_reposittory.dart';
import 'package:motelapp/data/repositories/room_repository/tanent_room_repository.dart';
import 'package:motelapp/data/repositories/stake_repository/stake_repository.dart';
import 'package:motelapp/data/services/fcm_service.dart';
import 'package:motelapp/logic/cubits/auth/auth_cubit.dart';
import 'package:motelapp/logic/cubits/building/amenity_cubit.dart';
import 'package:motelapp/logic/cubits/building/create_building_cubit.dart';
import 'package:motelapp/logic/cubits/building/detail_building_cubit.dart';
import 'package:motelapp/logic/cubits/building/list_building_cubit.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/add_tanent_room_cubit.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/create_room_cubit.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/detail_room_cubit.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/detail_tanent_cubit.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/room_in_building_cubit.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/tanent_room_cubit.dart';
import 'package:motelapp/logic/cubits/cost/cost_cubit.dart';
import 'package:motelapp/logic/cubits/home/bill_home/bill_cubit.dart';
import 'package:motelapp/logic/cubits/home/contract_home/contract_cubit.dart';
import 'package:motelapp/logic/cubits/home/owe_home/owe_cubit.dart';
import 'package:motelapp/logic/cubits/home/problem_home/create_problem_cubit.dart';
import 'package:motelapp/logic/cubits/home/problem_home/detail_problem_cubit.dart';
import 'package:motelapp/logic/cubits/home/problem_home/list_problem_cubit.dart';
import 'package:motelapp/logic/cubits/home/problem_home/select_room_problem_cubit.dart';
import 'package:motelapp/logic/cubits/home/service_home/create_service_cubit.dart';
import 'package:motelapp/logic/cubits/home/service_home/service_cubit.dart';
import 'package:motelapp/logic/cubits/home/stake_home/stake_cubit.dart';
import 'package:motelapp/logic/cubits/home/statistical_cubit.dart';
import 'package:motelapp/logic/cubits/home/tanent_home/lessee_cubit.dart';
import 'package:motelapp/logic/cubits/managet/manage_cubit.dart';
import 'package:motelapp/router/app_router.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Register your services, repositories, and cubits here
  getIt.registerLazySingleton(() => FcmService());
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
  getIt.registerLazySingleton(() => ListProblemByUserIdRepository());

  getIt.registerLazySingleton(() => DetailProblemRepository());
  getIt.registerLazySingleton(() => SelectRoomProblemRepository());
  getIt.registerLazySingleton(() => CreateProblemRepository());
  getIt.registerLazySingleton(() => ListContractRepository());
  getIt.registerLazySingleton(() => StakeRepository());
  getIt.registerLazySingleton(() => ManageRepository());
  getIt.registerLazySingleton(() => AmenityRepository());
  getIt.registerLazySingleton(() => CreateBuildingRepository());
  getIt.registerLazySingleton(() => CreateRoomRepository());
  getIt.registerLazySingleton(() => OweRepository());
  getIt.registerLazySingleton(() => AddTanentRoomRepository());
  getIt.registerLazySingleton(() => BillRepository());
  getIt.registerLazySingleton(() => CostRepository());

  // KHỞI TẠO CÁC LẮNG NGHE FCM
  // (Bây giờ nó sẽ gọi các hàm onMessage, onMessageOpenedApp)
  await getIt<FcmService>().initNotifications();

  // Register DetailRoomRepository
  getIt.registerLazySingleton<AuthCubit>(
    () => AuthCubit(
      authRepository: getIt<AuthRepository>(),
      fcmService: getIt<FcmService>(),
    ),
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
    () => TanentRoomCubit(
      tanentRoomRepository: getIt<TanentRoomRepository>(),
      addTanentRoomRepository: getIt<AddTanentRoomRepository>(),
    ),
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
    () => LesseeCubit(
      listTanentRepository: getIt<ListLesseeRepository>(),
      addTanentRoomRepository: getIt<AddTanentRoomRepository>(),
    ),
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

  getIt.registerLazySingleton(
    () => ListProblemUserCubit(
      listProblemByUserIdRepository: getIt<ListProblemByUserIdRepository>(),
    ),
  );

  getIt.registerLazySingleton(
    () => DetailProblemCubit(
      detailProblemRepository: getIt<DetailProblemRepository>(),
    ),
  );

  getIt.registerLazySingleton(
    () => SelectRoomProblemCubit(
      selectRoomProblemRepository: getIt<SelectRoomProblemRepository>(),
    ),
  );

  getIt.registerLazySingleton(
    () => CreateProblemCubit(
      createProblemRepository: getIt<CreateProblemRepository>(),
    ),
  );

  getIt.registerLazySingleton(
    () => ListContractCubit(
      listContractRepository: getIt<ListContractRepository>(),
    ),
  );
  getIt.registerLazySingleton(
    () => StakeCubit(stakeRepository: getIt<StakeRepository>()),
  );

  getIt.registerLazySingleton(
    () => ContentStakeCubit(stakeRepository: getIt<StakeRepository>()),
  );

  getIt.registerLazySingleton(
    () => ClosureServiceCubit(
      serviceHomeRepository: getIt<ServiceHomeRepository>(),
    ),
  );

  getIt.registerLazySingleton(
    () => ManageCubit(manageRepository: getIt<ManageRepository>()),
  );

  getIt.registerLazySingleton(
    () => AmenityCubit(amenityRepository: getIt<AmenityRepository>()),
  );

  getIt.registerLazySingleton(
    () => CreateBuildingCubit(
      createBuildingRepository: getIt<CreateBuildingRepository>(),
    ),
  );

  getIt.registerLazySingleton(
    () => CreateRoomCubit(createRoomRepository: getIt<CreateRoomRepository>()),
  );

  getIt.registerLazySingleton(
    () => OweCubit(oweRepository: getIt<OweRepository>()),
  );

  getIt.registerLazySingleton(
    () => AddTanentRoomCubit(
      addTanentRoomRepository: getIt<AddTanentRoomRepository>(),
    ),
  );

  getIt.registerLazySingleton(
    () => BillCubit(billRepository: getIt<BillRepository>()),
  );

  getIt.registerLazySingleton(
    () => CostCubit(costRepository: getIt<CostRepository>()),
  );
}
