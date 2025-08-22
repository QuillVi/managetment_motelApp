import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/config/theme/app_theme.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/auth/auth_cubit.dart';
import 'package:motelapp/logic/cubits/building/list_building_cubit.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/room_in_building_cubit.dart';
import 'package:motelapp/logic/cubits/home/statistical_cubit.dart';
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
