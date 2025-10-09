import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/config/theme/app_theme.dart';
import 'package:motelapp/data/repositories/problem_repository/list_problem_repository.dart';
import 'package:motelapp/data/services/service_locator.dart';
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
import 'package:motelapp/presentation/splash_screen.dart';
import 'package:motelapp/router/app_router.dart';

void main() async {
  await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
        // Add other BlocProviders here as needed
        // BlocProvider<AnotherCubit>(
        //   create: (_) => getIt<AnotherCubit>(),
        // ),
      ],
      child: MaterialApp(
        title: 'Motel App',
        navigatorKey: getIt<AppRouter>().navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
