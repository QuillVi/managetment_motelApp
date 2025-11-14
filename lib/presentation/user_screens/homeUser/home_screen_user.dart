import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/auth/auth_cubit.dart';
import 'package:motelapp/logic/cubits/home/statistical_cubit.dart';
import 'package:motelapp/presentation/screens/auth/login_screen.dart';
import 'package:motelapp/presentation/screens/home/functions/function_bill_home/bill_home.dart';
import 'package:motelapp/presentation/screens/home/functions/function_contract_home/contract_home.dart';
import 'package:motelapp/presentation/screens/home/functions/function_eletricwater_home/electricwater_home.dart';
import 'package:motelapp/presentation/screens/home/functions/function_owe_home/owe_home.dart';
import 'package:motelapp/presentation/screens/home/functions/function_problem_home/problem_home.dart';
import 'package:motelapp/presentation/screens/home/notify_home/notify_home.dart';
import 'package:motelapp/presentation/screens/home/setting_home/setting_home.dart';
import 'package:motelapp/presentation/user_screens/homeUser/function/function_bill_home/bill_home_user.dart';
import 'package:motelapp/presentation/user_screens/homeUser/function/function_contract_home/contract_home_user.dart';
import 'package:motelapp/presentation/user_screens/homeUser/function/function_owe_home/owe_home_user.dart';
import 'package:motelapp/presentation/user_screens/homeUser/function/function_problem_home/problem_home_user.dart';
import 'package:motelapp/router/app_router.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final List<Map<String, dynamic>> functionMotelApp = [
    //{'icon': Icons.lightbulb, 'label': 'Dịch vụ', 'color': Colors.amber},
    //{'icon': Icons.speed, 'label': 'Chốt điện nước', 'color': Colors.blue},
    {'icon': Icons.receipt_long, 'label': 'Hoá đơn', 'color': Colors.green},
    //{'icon': Icons.person, 'label': 'Người thuê', 'color': Colors.orange},
    {'icon': Icons.report_problem, 'label': 'Sự cố', 'color': Colors.red},
    {'icon': Icons.handshake, 'label': 'Hợp đồng', 'color': Colors.purple},
    //{'icon': Icons.attach_money, 'label': 'Cọc giữ chỗ', 'color': Colors.teal},
    //{'icon': Icons.local_mall, 'label': 'Đầy phòng', 'color': Colors.indigo},
    {'icon': Icons.article, 'label': 'Số nợ', 'color': Colors.brown},
    {'icon': Icons.help_outline, 'label': 'Hướng dẫn', 'color': Colors.grey},
  ];

  void _onFeatureTap(int index) {
    final router = getIt<AppRouter>();

    switch (index) {
      case 0:
        router.push(BillHomeUser());
        break;
      case 1:
        router.push(ProblemHomeUser());
        break;
      case 2:
        router.push(ContractHomeUser());
        break;
      case 3:
        router.push(OweHomeUser());
        break;

      default:
        ScaffoldMessenger.of(
          getIt<AppRouter>().navigatorKey.currentContext!,
        ).showSnackBar(
          const SnackBar(
            content: Text('Chức năng đang được phát triển'),
            duration: Duration(seconds: 2),
          ),
        );
    }
  }

  // ... các import và phần code trên giữ nguyên ...

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Giả sử AuthCubit cung cấp AuthRepository
      final authRepository = context.read<AuthCubit>().authRepository;

      final token = await authRepository.getToken();

      if (token != null) {
        // Có token, tiếp tục tải dữ liệu
        if (mounted) {
          context.read<StatisticalCubit>().loadStatistics();
        }
      } else {
        // KHÔNG CÓ TOKEN -> Hiển thị Dialog thông báo hết phiên
        print("Chưa có token, hãy login trước. Hiển thị thông báo hết phiên.");

        // Đảm bảo context còn hợp lệ (mounted) trước khi sử dụng showDialog
        if (mounted) {
          showDialog(
            context: context,
            // Ngăn người dùng đóng dialog bằng cách nhấn ra ngoài
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: const Text('Hết phiên đăng nhập'),
                content: const Text(
                  'Phiên đăng nhập của bạn đã hết hạn hoặc bạn chưa đăng nhập. Vui lòng đăng nhập lại.',
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Đăng nhập lại'),
                    onPressed: () {
                      // 1. Đóng dialog trước
                      Navigator.of(dialogContext).pop();

                      // 2. Chuyển hướng người dùng sang màn hình đăng nhập
                      getIt<AppRouter>().push(LoginScreen());
                    },
                  ),
                ],
              );
            },
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;

    final ten = user?.ten.isNotEmpty == true ? user!.ten : 'Người dùng';
    print(
      "thong tin nguoi dung: id: ${user?.id_nguoidung},ten: ${user?.ten}, vaiTro: ${user?.vaitro},Token: ${user?.token}",
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(180),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              // child: SafeArea(
              //   child: Padding(
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 16.0,
              //       vertical: 12,
              //     ),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Text(
              //               'Xin chào',
              //               style: TextStyle(fontSize: 14, color: Colors.white),
              //             ),
              //             Text(
              //               ten ?? 'Người dùng',

              //               style: TextStyle(
              //                 fontSize: 22,
              //                 color: Colors.white,
              //                 fontWeight: FontWeight.bold,
              //               ),
              //             ),
              //           ],
              //         ),
              //         Row(
              //           children: [
              //             IconButton(
              //               icon: const Icon(
              //                 Icons.settings,
              //                 color: Colors.white,
              //               ),
              //               onPressed: () {
              //                 getIt<AppRouter>().push(SettingsScreen());
              //               },
              //             ),
              //             IconButton(
              //               icon: const Icon(
              //                 Icons.notifications_outlined,
              //                 color: Colors.white,
              //               ),
              //               onPressed: () {
              //                 getIt<AppRouter>().push(NotificationScreen());
              //               },
              //             ),
              //           ],
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ),

            Positioned(
              bottom: -20,
              left: 20,
              right: 20,
              child: Container(
                height: 150,
                // Sửa: Thêm padding ngang để các icon không bị dính sát mép
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                // THAY ĐỔI TỪ ĐÂY: Dùng Stack thay vì Center/Row
                child: Stack(
                  children: [
                    // --- 1. Phần văn bản được căn giữa ---
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        // Cần 2 dòng này để căn giữa Column
                        mainAxisSize:
                            MainAxisSize.min, // Co Column lại vừa đủ nội dung
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // Căn giữa "Xin chào"
                        children: [
                          Text(
                            'Xin chào',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          Text(
                            ten ?? 'Người dùng',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- 2. Các icon ở góc trên bên phải ---
                    Align(
                      alignment: Alignment.topRight,
                      child: Row(
                        // Co Row lại vừa đủ 2 icon
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.settings,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              getIt<AppRouter>().push(SettingsScreen());
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_outlined,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              getIt<AppRouter>().push(NotificationScreen());
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      body: Center(
        child: Container(
          height: 540,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: functionMotelApp.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              final item = functionMotelApp[index];
              return InkWell(
                onTap: () => _onFeatureTap(index),
                child: _featureItem(
                  item['icon'],
                  item['label'],
                  item['color'] ?? Colors.black87,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _infoBox(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.black, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, color: Colors.black)),
      ],
    );
  }

  Widget _featureItem(IconData icon, String label, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 36, color: color),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
