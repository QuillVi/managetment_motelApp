import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/models/service_model.dart'; // ✅ import model thật
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/home/service_home/service_cubit.dart';
import 'package:motelapp/logic/cubits/home/service_home/service_state.dart';
import 'package:motelapp/presentation/screens/buttonNavicationBar/buttonNavicationBar.dart';
import 'package:motelapp/presentation/screens/home/functions/function_service_home/add_service/add_service.dart';
import 'package:motelapp/presentation/screens/home/functions/function_service_home/update_service_home.dart';

import 'package:motelapp/router/app_router.dart';

class ServiceHome extends StatefulWidget {
  const ServiceHome({super.key});

  @override
  State<ServiceHome> createState() => _ServiceHomeState();
}

class _ServiceHomeState extends State<ServiceHome> {
  //Biến quản lý tìm kiếm
  List<ServiceModel> _allServices = []; // List gốc từ API
  List<ServiceModel> _filteredServices = []; // List hiển thị lên màn hình
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // gọi API khi mở màn hình
    context.read<ServiceCubit>().loadServices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  //  Hàm logic tìm kiếm
  void _runFilter(String enteredKeyword) {
    List<ServiceModel> results = [];
    if (enteredKeyword.isEmpty) {
      // Nếu ô tìm kiếm rỗng -> Hiển thị lại list gốc
      results = _allServices;
    } else {
      // Lọc theo tên (chuyển về chữ thường để tìm không phân biệt hoa thường)
      results =
          _allServices
              .where(
                (service) => service.ten_dichvu.toLowerCase().contains(
                  enteredKeyword.toLowerCase(),
                ),
              )
              .toList();
    }

    // Cập nhật UI
    setState(() {
      _filteredServices = results;
    });
  }

  // Đặt hàm này bên trong class _ServiceHomeState
  void _showServiceOptions(BuildContext context, ServiceModel service) {
    showModalBottomSheet(
      context: context,
      // Làm cho nền của sheet trong suốt để thấy các card bên trong
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return Padding(
          // Khoảng cách 2 bên và dưới
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Chỉ chiếm chiều cao cần thiết
            children: <Widget>[
              // Nút "Cập nhật"
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  title: const Center(
                    child: Text(
                      'Cập nhật',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context); // Đóng bottom sheet
                    getIt<AppRouter>().push(
                      UpdateServiceHome(idDichVu: service.id_dichvu),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8), // Khoảng cách giữa 2 nút
              // Nút "Xoá"
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  title: const Center(
                    child: Text(
                      'Xoá',
                      style: TextStyle(
                        color: Colors.red, // Màu đỏ cho nút xoá
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context); // Đóng bottom sheet
                    context.read<ServiceCubit>().deleteService(
                      service.id_dichvu,
                    );
                    print('Xoá dịch vụ: ${service.ten_dichvu}');
                    getIt<AppRouter>().push(ServiceHome());
                  },
                ),
              ),
              const SizedBox(height: 16), // Khoảng cách với mép dưới
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () => getIt<AppRouter>().push(Buttonnavicationbar()),
            ),
            title: const Text(
              'Dịch vụ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.help_outline, color: Colors.orange),
              ),
            ],
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          // 3. SỬA ĐỔI: Bọc body bằng BlocListener để hứng data API
          body: BlocListener<ServiceCubit, ServiceState>(
            listener: (context, state) {
              // Khi API tải thành công, lưu vào biến local
              if (state.status == ServiceStatus.success && state.data != null) {
                setState(() {
                  _allServices = state.data!;
                  _filteredServices = state.data!; // Ban đầu hiển thị hết
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tìm kiếm
                  TextField(
                    controller: _searchController, // Gán controller
                    onChanged:
                        (value) => _runFilter(value), // 4. Gọi hàm lọc khi gõ
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm theo tên',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      // Thêm nút X để xóa nhanh text tìm kiếm
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _runFilter(''); // Reset list về ban đầu
                                },
                              )
                              : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Danh sách dịch vụ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Danh sách dịch vụ
                  Expanded(
                    child: BlocBuilder<ServiceCubit, ServiceState>(
                      builder: (context, state) {
                        if (state.status == ServiceStatus.loading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state.status == ServiceStatus.failure) {
                          return Center(
                            child: Text(
                              'Lỗi: ${state.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        // 5. SỬA ĐỔI QUAN TRỌNG:
                        // Không lấy state.data trực tiếp nữa, mà dùng _filteredServices
                        // để hiển thị kết quả tìm kiếm.

                        if (_filteredServices.isEmpty) {
                          if (state.status == ServiceStatus.success) {
                            // Nếu API thành công mà list rỗng -> Do tìm kiếm không thấy
                            return const Center(
                              child: Text("Không tìm thấy dịch vụ nào"),
                            );
                          }
                          return const SizedBox();
                        }

                        // Logic hiển thị lưới 3 cột (giữ nguyên logic cũ của bạn)
                        // nhưng thay biến services = _filteredServices
                        final services = _filteredServices;

                        return ListView.builder(
                          itemCount: (services.length / 3).ceil(),
                          itemBuilder: (context, index) {
                            final start = index * 3;
                            final end =
                                (start + 3 < services.length)
                                    ? start + 3
                                    : services.length;
                            final rowItems = services.sublist(start, end);

                            return Row(
                              children:
                                  rowItems
                                      .map(
                                        (service) => Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: GestureDetector(
                                              onTap: () {
                                                _showServiceOptions(
                                                  context,
                                                  service,
                                                );
                                              },
                                              child: ServiceCard(
                                                service: service,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList()
                                    ..addAll(
                                      List.generate(
                                        3 - rowItems.length,
                                        (_) =>
                                            const Expanded(child: SizedBox()),
                                      ),
                                    ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Nút cộng tuỳ chỉnh bằng Positioned
        Positioned(
          bottom: 84,
          right: 24,
          child: GestureDetector(
            onTap: () {
              getIt<AppRouter>().push(const AddService());
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            ),
          ),
        ),
      ],
    );
  }
}

//  ServiceCard dùng model API thật
class ServiceCard extends StatelessWidget {
  final ServiceModel service; // từ data/models/service_model.dart

  const ServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 120,
          width: double.infinity,
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Load icon từ assets (hoặc network)
              Image.asset(
                'lib/assets/icons/${service.icon}',
                height: 40,
                width: 40,
                errorBuilder:
                    (_, __, ___) => const Icon(Icons.broken_image, size: 40),
              ),
              const SizedBox(height: 8),
              Text(service.ten_dichvu, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                '${service.phi_dichvu.toStringAsFixed(0)} đ',
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
          ),
        ),
        Positioned(
          top: 10,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: const Text(
              'Tháng',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
