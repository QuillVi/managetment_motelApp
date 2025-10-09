import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/building/list_building_cubit.dart';
import 'package:motelapp/logic/cubits/building/list_building_state.dart';
import 'package:motelapp/logic/cubits/home/service_home/create_service_cubit.dart';
import 'package:motelapp/logic/cubits/home/service_home/create_service_state.dart';
import 'package:motelapp/presentation/screens/home/functions/function_service_home/add_service/add_image_service.dart';
import 'package:motelapp/presentation/screens/home/functions/function_service_home/service_home.dart';
import 'package:motelapp/router/app_router.dart';

class AddService extends StatefulWidget {
  const AddService({super.key});

  @override
  State<AddService> createState() => _AddServiceState();
}

class _AddServiceState extends State<AddService> {
  String? selectedChargeBasedOn;
  bool applyToAll = false;
  final Map<int, bool> selectedBuildings = {};

  Map<String, dynamic>? _selectedIcon;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController feeController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Gọi cubit load danh sách tòa nhà
    context.read<ListBuildingCubit>().loadBuildings();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameController.dispose();
    feeController.dispose();
    noteController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateServiceCubit, CreateServiceState>(
      listener: (context, state) {
        if (state.status == CreateServiceStatus.loading) {
          // Ví dụ: show dialog loading
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == CreateServiceStatus.success) {
          // Đóng loading nếu đang mở
          Navigator.of(context, rootNavigator: true).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Thêm dịch vụ thành công!")),
          );

          // Pop màn hình sau khi thêm thành công
          getIt<AppRouter>().push(ServiceHome());
        }

        if (state.status == CreateServiceStatus.error) {
          // Đóng loading nếu đang mở
          Navigator.of(context, rootNavigator: true).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Lỗi: ${state.error ?? 'Có lỗi xảy ra'}")),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => getIt<AppRouter>().pop(context),
          ),
          title: const Text(
            'Thêm dịch vụ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tên dịch vụ
              _buildLabel('Tên dịch vụ *'),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Điện, nước, thang máy, bảo vệ...',
                ),
              ),
              const SizedBox(height: 16),

              // Phí dịch vụ
              _buildLabel('Phí dịch vụ'),
              TextField(
                controller: feeController,
                decoration: const InputDecoration(hintText: '0đ'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Ảnh đại diện
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Ảnh đại diện'),
                trailing:
                    _selectedIcon == null
                        ? const Icon(Icons.chevron_right)
                        : Icon(_selectedIcon!["icon"], size: 28),

                onTap: () async {
                  final result = await getIt<AppRouter>().push(
                    AddImageService(),
                  );

                  if (result != null && result is Map<String, dynamic>) {
                    setState(() {
                      _selectedIcon = result;
                    });

                    print("Chọn icon: ${result["name"]}");
                  }
                },
              ),
              const Divider(),

              // Ghi chú
              _buildLabel('Ghi chú'),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: noteController,
                  maxLines: 5,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Nhập ghi chú...',
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Thêm cho tòa nhà
              const Text(
                'Thêm dịch vụ này cho toà nhà',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Checkbox "Tất cả toà nhà"
              CheckboxListTile(
                value: applyToAll,
                onChanged: (val) {
                  setState(() {
                    applyToAll = val!;

                    if (applyToAll) {
                      // Chọn hết tất cả toà nhà
                      if (context.read<ListBuildingCubit>().state.data !=
                          null) {
                        for (var b
                            in context.read<ListBuildingCubit>().state.data!) {
                          selectedBuildings[b.id_toanha] = true;
                        }
                      }
                    } else {
                      // Bỏ hết chọn
                      if (context.read<ListBuildingCubit>().state.data !=
                          null) {
                        for (var b
                            in context.read<ListBuildingCubit>().state.data!) {
                          selectedBuildings[b.id_toanha] = false;
                        }
                      }
                    }
                  });
                },
                title: const Text('Tất cả toà nhà'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              // Danh sách toà nhà
              BlocBuilder<ListBuildingCubit, ListBuildingState>(
                builder: (context, state) {
                  if (state.status == ListBuildingStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state.status == ListBuildingStatus.loaded) {
                    final buildings = state.data ?? [];
                    return Column(
                      children:
                          buildings.map((building) {
                            return CheckboxListTile(
                              value:
                                  selectedBuildings[building.id_toanha] ??
                                  false,
                              onChanged: (val) {
                                setState(() {
                                  selectedBuildings[building.id_toanha] = val!;

                                  // Nếu có 1 tòa chưa chọn thì applyToAll = false
                                  if (selectedBuildings.values.every(
                                    (e) => e == true,
                                  )) {
                                    applyToAll = true;
                                  } else {
                                    applyToAll = false;
                                  }
                                });
                              },
                              title: Text(building.tentoanha),
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            );
                          }).toList(),
                    );
                  } else if (state.status == ListBuildingStatus.error) {
                    return Text('Lỗi: ${state.error}');
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
        // nút cố định dưới cùng
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                final selectedIds =
                    selectedBuildings.entries
                        .where((e) => e.value == true)
                        .map((e) => e.key)
                        .toList();

                final payload = {
                  "ten_dichvu": nameController.text,
                  "phi_dichvu": feeController.text,
                  "ghi_chu": noteController.text,
                  "toa_nha_ids": selectedIds,
                  "icon":
                      _selectedIcon != null
                          ? "${_selectedIcon!["name"]}.png"
                          : null,
                };

                print("Payload gửi API: $payload");
                // Gọi API tạo dịch vụ ở đây với payload
                context.read<CreateServiceCubit>().createService(payload);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Thêm dịch vụ',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
    );
  }
}
