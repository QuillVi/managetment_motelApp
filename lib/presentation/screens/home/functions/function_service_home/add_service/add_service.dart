import 'package:flutter/material.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/presentation/screens/home/functions/function_service_home/add_service/add_image_service.dart';
import 'package:motelapp/router/app_router.dart';

class AddService extends StatefulWidget {
  const AddService({super.key});

  @override
  State<AddService> createState() => _AddServiceState();
}

class _AddServiceState extends State<AddService> {
  String? selectedChargeBasedOn;
  bool applyToAll = false;
  bool applyToVi = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController feeController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  final List<String> chargeOptions = ['Chỉ số', 'Phòng', 'Người', 'Số lần'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

            // Thu phí dựa trên
            _buildLabel('Thu phí dựa trên *'),
            DropdownButtonFormField<String>(
              hint: const Text(
                'Lũy tiến theo chỉ số, phòng, người, số lần',
                style: TextStyle(color: Colors.grey),
              ),
              value: selectedChargeBasedOn,
              items:
                  chargeOptions.map((option) {
                    return DropdownMenuItem(value: option, child: Text(option));
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedChargeBasedOn = value;
                });
              },
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
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                getIt<AppRouter>().push(AddImageService());
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
            CheckboxListTile(
              value: applyToAll,
              onChanged: (val) => setState(() => applyToAll = val!),
              title: const Text('Tất cả toà nhà'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              value: applyToVi,
              onChanged: (val) => setState(() => applyToVi = val!),
              title: const Text('vi'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: xử lý khi nhấn nút
                  print('Đã nhấn nút thêm dịch vụ');
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
          ],
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
