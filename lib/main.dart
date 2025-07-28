import 'package:flutter/material.dart';
import 'package:motelapp/config/theme/app_theme.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/presentation/screens/auth/login_screen.dart';
import 'package:motelapp/router/app_router.dart';

void main() async {
  await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Motel App',
      navigatorKey: getIt<AppRouter>().navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
