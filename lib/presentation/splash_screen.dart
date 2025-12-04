import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/auth/auth_cubit.dart';
import 'package:motelapp/logic/cubits/auth/auth_state.dart';
import 'package:motelapp/presentation/screens/auth/login_screen.dart';
import 'package:motelapp/presentation/screens/buttonNavicationBar/buttonNavicationBar.dart';
import 'package:motelapp/presentation/user_screens/userButtonNavicationBar/userButtonNavicationBar.dart';
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

    context.read<AuthCubit>().tryAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // ========== THÊM LOGIC VAI TRÒ VÀO ĐÂY ==========
        if (state.status == AuthStatus.authenticated) {
          // 1. Tự động đăng nhập thành công, kiểm tra vai trò
          final String vaiTro = state.user?.vaitro ?? '';
          print('Tự động đăng nhập thành công. Vai trò: $vaiTro');

          // 2. Điều hướng dựa trên vai trò
          if (vaiTro == 'ChuTro') {
            getIt<AppRouter>().pushAndRemoveUntil(const Buttonnavicationbar());
          } else if (vaiTro == 'NguoiThue') {
            getIt<AppRouter>().pushAndRemoveUntil(
              const UserButtonnavicationbar(),
            );
          } else {
            // Vai trò lạ? Về Login.
            getIt<AppRouter>().pushAndRemoveUntil(const LoginScreen());
          }
        } else if (state.status == AuthStatus.unauthenticated) {
          // 3. Tự động đăng nhập thất bại (không có token, hết hạn, v.v.)
          print('Tự động đăng nhập thất bại. Chuyển đến LoginScreen.');
          getIt<AppRouter>().pushAndRemoveUntil(const LoginScreen());
        }
        // =============================================
      },
      child: Scaffold(
        backgroundColor: Colors.green,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.maps_home_work_outlined,
                color: Colors.white,
                size: 80,
              ),
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
      ),
    );
  }
}
