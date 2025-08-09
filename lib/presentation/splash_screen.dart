import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/auth/auth_cubit.dart';
import 'package:motelapp/logic/cubits/auth/auth_state.dart';
import 'package:motelapp/presentation/screens/auth/login_screen.dart';
import 'package:motelapp/presentation/screens/buttonNavicationBar/buttonNavicationBar.dart';
import 'package:motelapp/router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    await Future.delayed(const Duration(seconds: 2)); // Optional delay

    final authCubit = context.read<AuthCubit>();
    await authCubit.tryAutoLogin();

    if (!mounted) return;

    if (authCubit.state.status == AuthStatus.authenticated) {
      getIt<AppRouter>().pushAndRemoveUntil(const Buttonnavicationbar());
    } else {
      getIt<AppRouter>().pushAndRemoveUntil(const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.maps_home_work_outlined, color: Colors.white, size: 80),
            SizedBox(height: 16),
            Text(
              'MOTEL APP',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text('Đang tải...', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

