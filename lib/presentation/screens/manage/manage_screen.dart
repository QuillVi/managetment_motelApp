import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/auth/auth_cubit.dart';
import 'package:motelapp/logic/cubits/managet/manage_cubit.dart';
import 'package:motelapp/logic/cubits/managet/manage_state.dart';
import 'package:motelapp/presentation/screens/auth/login_screen.dart';
import 'package:motelapp/router/app_router.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({super.key});

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  @override
  void initState() {
    super.initState();
    //gọi API khi mở màn hình
    context.read<ManageCubit>().fetchManage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quản lý',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold, // Thêm độ đậm cho tiêu đề
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0, // Bỏ đổ bóng
        actions: [
          IconButton(
            onPressed: () {
              // Xử lý khi nhấn nút dấu hỏi
            },
            icon: const Icon(
              Icons.help_outline,
              color: Colors.orange,
            ), // Icon dấu hỏi
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Profile Card
              Card(
                color: Colors.white,
                elevation: 2, // Đổ bóng nhẹ
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: BlocBuilder<ManageCubit, ManageState>(
                    builder: (context, state) {
                      // Hiển thị trạng thái Loading
                      if (state.status == ManageStatus.loading ||
                          state.status == ManageStatus.initial) {
                        return const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      // Hiển thị trạng thái Error
                      if (state.status == ManageStatus.error) {
                        return Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(
                            child: Text(
                              'Lỗi: ${state.error ?? 'Không thể tải dữ liệu'}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        );
                      }

                      // Hiển thị trạng thái Loaded
                      final manage = state.manage;

                      // Kiểm tra nếu dữ liệu ManageModel là null (mặc dù state đã là loaded,
                      // nên kiểm tra này là an toàn)
                      if (manage == null) {
                        return const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(
                            child: Text('Không có dữ liệu quản lý.'),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  // Xử lý khi nhấn nút menu ba chấm
                                },
                              ),
                            ),
                            const CircleAvatar(
                              radius: 40,
                              backgroundColor:
                                  Colors.grey, // Màu nền của avatar
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              manage.ten ?? 'Người dùng', // Tên người dùng
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Số điện thoại',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  manage.soDienThoai ??
                                      'Chưa cập nhật', // Số điện thoại
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Địa chỉ',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  manage.diaChi ?? 'Chưa cập nhật',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 2. Action Buttons Grid
              GridView.count(
                shrinkWrap:
                    true, // Để GridView không chiếm hết không gian theo chiều dọc
                physics:
                    const NeverScrollableScrollPhysics(), // Vô hiệu hóa cuộn của GridView
                crossAxisCount: 2, // 2 cột như trong hình
                crossAxisSpacing: 16, // Khoảng cách giữa các cột
                mainAxisSpacing: 16, // Khoảng cách giữa các hàng
                childAspectRatio:
                    1.5, // Tỷ lệ khung hình của mỗi item để chúng trông giống card
                children: [
                  _buildActionButton(
                    Icons.person_add,
                    'Thêm nhân viên',
                    Colors.grey[200]!,
                  ), // Màu nền nhẹ
                  _buildActionButton(
                    Icons.group,
                    'Danh sách nhân viên',
                    Colors.grey[200]!,
                  ),
                  _buildActionButton(
                    Icons.mail,
                    'Danh sách đã mời',
                    Colors.grey[200]!,
                  ),
                  _buildActionButton(
                    Icons.groups,
                    'Danh sách vai trò',
                    Colors.grey[200]!,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. Management Package Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'GÓI QUẢN LÝ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                    letterSpacing: 0.5, // Khoảng cách chữ
                                  ),
                                ),
                                const SizedBox(width: 20),
                                const Text(
                                  'CÁ NHÂN',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                // Xử lý khi nhấn nút Chi tiết
                              },
                              style: TextButton.styleFrom(
                                padding:
                                    EdgeInsets
                                        .zero, // Bỏ padding mặc định của TextButton
                                minimumSize:
                                    Size.zero, // Bỏ kích thước tối thiểu
                                tapTargetSize:
                                    MaterialTapTargetSize
                                        .shrinkWrap, // Giảm vùng chạm
                              ),
                              child: const Text(
                                'Chi tiết',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Ngày kích hoạt',
                              style: TextStyle(color: Colors.black87),
                            ),
                            Text(
                              '23-03-2025',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Ngày kết thúc',
                              style: TextStyle(color: Colors.black87),
                            ),
                            Text(
                              '22-04-2025',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ), // padding lề trái phải
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await getIt<AuthCubit>().logout();

                      getIt<AppRouter>().pushAndRemoveUntil(
                        const LoginScreen(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Màu nền đỏ
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ), // padding dọc
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Đăng xuất',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
            //Nút đăng xuất
          ),
        ),
      ),
    );
  }

  // Hàm xây dựng một nút hành động trong GridView
  Widget _buildActionButton(
    IconData icon,
    String label,
    Color backgroundColor,
  ) {
    return Card(
      elevation: 1, // Đổ bóng nhẹ cho từng nút
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: backgroundColor,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          // Cho phép nhấn vào toàn bộ card
          onTap: () {
            // Xử lý khi nhấn vào nút
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getIconColor(icon), // Lấy màu icon theo hình ảnh
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 30, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500, // Độ đậm vừa phải
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function để lấy màu icon dựa trên icon data
  Color _getIconColor(IconData icon) {
    if (icon == Icons.person_add) {
      return Colors.grey[600]!; // Màu xám đậm hơn
    } else if (icon == Icons.group) {
      return Colors.orange[600]!; // Màu cam
    } else if (icon == Icons.mail) {
      return Colors.blue[600]!; // Màu xanh dương
    } else if (icon == Icons.groups) {
      return Colors.green[600]!; // Màu xanh lá cây
    }
    return Colors.black; // Mặc định
  }
}
