import 'package:flutter/material.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/presentation/screens/home/functions/function_service_home/add_service/add_service.dart';
import 'package:motelapp/router/app_router.dart';

class ServiceHome extends StatefulWidget {
  const ServiceHome({super.key});

  @override
  State<ServiceHome> createState() => _ServiceHomeState();
}

class _ServiceHomeState extends State<ServiceHome> {
  final List<ServiceModel> services = [
    ServiceModel(icon: Icons.wifi, title: 'wifi', price: '300.000 đ/Người'),
    ServiceModel(
      icon: Icons.ac_unit,
      title: 'Máy lạnh',
      price: '300.000 đ/Phòng',
    ),
    ServiceModel(
      icon: Icons.local_laundry_service,
      title: 'Giặt ủi',
      price: '100.000 đ/Phòng',
    ),
    ServiceModel(icon: Icons.tv, title: 'Truyền hình', price: '50.000 đ/Phòng'),
    ServiceModel(
      icon: Icons.cleaning_services,
      title: 'Dọn phòng',
      price: '200.000 đ/Lần',
    ),
    ServiceModel(
      icon: Icons.electric_bolt,
      title: 'Điện',
      price: '3.000 đ/kWh',
    ),
  ];

  @override
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Phần giao diện chính
        Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () => getIt<AppRouter>().pop(context),
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
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tìm kiếm
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo tên',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Dịch vụ có phí',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Danh sách dịch vụ
                Expanded(
                  child: ListView.builder(
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
                                      child: ServiceCard(service: service),
                                    ),
                                  ),
                                )
                                .toList()
                              ..addAll(
                                List.generate(
                                  3 - rowItems.length,
                                  (_) => const Expanded(child: SizedBox()),
                                ),
                              ),
                      );
                    },
                  ),
                ),
              ],
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

class ServiceModel {
  final IconData icon;
  final String title;
  final String price;

  ServiceModel({required this.icon, required this.title, required this.price});
}

class ServiceCard extends StatelessWidget {
  final ServiceModel service;

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
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(service.icon, size: 40),
              const SizedBox(height: 8),
              Text(service.title, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 4),
              Text(
                service.price,
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
