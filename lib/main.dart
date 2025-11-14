import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/config/theme/app_theme.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/firebase_options.dart';
import 'package:motelapp/logic/cubits/auth/auth_cubit.dart';
import 'package:motelapp/logic/cubits/auth/auth_state.dart';
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
import 'package:motelapp/presentation/splash_screen.dart';
import 'package:motelapp/router/app_router.dart';

// BẮT BUỘC: Đặt hàm này ở top-level (bên ngoài các class)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Khởi tạo Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  // Đảm bảo binding được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Gắn hàm xử lý background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt<AppRouter>();
    return MultiBlocProvider(
      providers: [
        // BlocProvider for AuthCubit
        BlocProvider<AuthCubit>(create: (_) => getIt<AuthCubit>()),
        // BlocProvider for StatisticalCubit in Home
        BlocProvider<StatisticalCubit>(
          create: (_) => getIt<StatisticalCubit>()..loadStatistics(),
        ),
        // BlocProvider for ListBuildingCubit
        BlocProvider<ListBuildingCubit>(
          create: (_) => getIt<ListBuildingCubit>()..loadBuildings(),
        ),
        // BlocProvider for RoomInBuildingCubit
        BlocProvider<RoomInBuildingCubit>(
          create: (_) => getIt<RoomInBuildingCubit>(),
        ),
        // BlocProvider for DetailBuildingCubit
        BlocProvider<DetailBuildingCubit>(
          create: (_) => getIt<DetailBuildingCubit>(),
        ),
        // BlocProvider for ServiceCubit
        BlocProvider<ServiceCubit>(
          create: (_) => getIt<ServiceCubit>()..loadServices(),
        ),
        BlocProvider<ClosureServiceCubit>(
          create: (_) => getIt<ClosureServiceCubit>(),
        ),

        // BlocProvider for DetailRoomCubit
        BlocProvider<DetailRoomCubit>(create: (_) => getIt<DetailRoomCubit>()),
        // BlocProvider for TanentRoomCubit
        BlocProvider<TanentRoomCubit>(create: (_) => getIt<TanentRoomCubit>()),

        // BlocProvider for DetailTanentCubit
        BlocProvider<DetailTanentCubit>(
          create: (_) => getIt<DetailTanentCubit>(),
        ),

        // BlocProvider for CreateServiceCubit
        BlocProvider<CreateServiceCubit>(
          create: (_) => getIt<CreateServiceCubit>(),
        ),

        // BlocProvider for TanentCubit
        BlocProvider<LesseeCubit>(
          create: (_) => getIt<LesseeCubit>()..loadTanents(),
        ),
        // BlocProvider for ListProblemCubit
        BlocProvider<ListProblemDonedCubit>(
          create: (_) => getIt<ListProblemDonedCubit>()..loadListProblemDoned(),
        ),
        BlocProvider<ListProblemRequestingCubit>(
          create:
              (_) =>
                  getIt<ListProblemRequestingCubit>()
                    ..loadListProblemRequesting(),
        ),

        // BlocProvider for ListProblemUserCubit
        BlocProvider<ListProblemUserCubit>(
          create: (_) => getIt<ListProblemUserCubit>()..loadListProblemUser(),
        ),

        // BlocProvider for DetailProblemCubit
        BlocProvider<DetailProblemCubit>(
          create: (_) => getIt<DetailProblemCubit>(),
        ),
        BlocProvider<SelectRoomProblemCubit>(
          create: (_) => getIt<SelectRoomProblemCubit>(),
        ),

        //BlocProvider for CreateProblem
        BlocProvider<CreateProblemCubit>(
          create: (_) => getIt<CreateProblemCubit>(),
        ),

        //BlocProvider for get list contract
        BlocProvider<ListContractCubit>(
          create: (_) => getIt<ListContractCubit>()..LoadListContract(),
        ),
        //BlocProvider for get Deposit
        BlocProvider<StakeCubit>(create: (_) => getIt<StakeCubit>()),
        BlocProvider<ContentStakeCubit>(
          create: (_) => getIt<ContentStakeCubit>(),
        ),

        // BlocProvider for get amenity
        BlocProvider<AmenityCubit>(create: (_) => getIt<AmenityCubit>()),

        // BlocProvider for CreateBuildingCubit
        BlocProvider<CreateBuildingCubit>(
          create: (_) => getIt<CreateBuildingCubit>(),
        ),

        // BlocProvider for CreateRoomCubit
        BlocProvider<CreateRoomCubit>(create: (_) => getIt<CreateRoomCubit>()),

        // BlocProvider for get list owe
        BlocProvider<OweCubit>(create: (_) => getIt<OweCubit>()),

        // BlocProvider for AddTanentRoomCubit
        BlocProvider<AddTanentRoomCubit>(
          create: (_) => getIt<AddTanentRoomCubit>(),
        ),

        // BlocProvider for BillHomeCubit
        BlocProvider<BillCubit>(create: (_) => getIt<BillCubit>()),

        // BlocProvider for CostCubit
        BlocProvider<CostCubit>(create: (_) => getIt<CostCubit>()),

        //BlocProvider for ManageCubit
        BlocProvider<ManageCubit>(create: (_) => getIt<ManageCubit>()),
        // Add other BlocProviders here as needed
        // BlocProvider<AnotherCubit>(
        //   create: (_) => getIt<AnotherCubit>(),
        // ),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          // !!! LẮNG NGHE TRẠNG THÁI HẾT PHIÊN ĐĂNG NHẬP
          if (state.status == AuthStatus.sessionExpired) {
            print('Phiên hết hạn. Tự động chuyển hướng.');

            // Gọi phương thức mới để xóa stack và chuyển hướng
            appRouter.replaceAllToLogin();
          }
        },
        // Vì bạn dùng GlobalKey, bạn phải dùng MaterialApp truyền thống
        child: MaterialApp(
          title: 'Motel App',
          // Gán GlobalKey vào MaterialApp để AppRouter có thể điều hướng
          navigatorKey: appRouter.navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          // Giữ lại SplashScreen như màn hình khởi đầu
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
