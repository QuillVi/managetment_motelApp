import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/home/problem_home/create_problem_cubit.dart';
import 'package:motelapp/logic/cubits/home/problem_home/create_problem_state.dart';
import 'package:motelapp/presentation/screens/home/functions/function_problem_home/create_problem/select_room.dart';
import 'package:motelapp/presentation/screens/home/functions/function_problem_home/problem_home.dart';
import 'package:motelapp/router/app_router.dart';

class CreateProblem extends StatefulWidget {
  const CreateProblem({super.key});

  @override
  State<CreateProblem> createState() => _CreateProblemState();
}

class _CreateProblemState extends State<CreateProblem> {
  String _severity = 'Cao';
  String? _selectedRoomName;
  int? _selectedRoomId;

  final TextEditingController nameProblem = TextEditingController();
  final TextEditingController detailProblem = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameProblem.dispose();
    detailProblem.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateProblemCubit, CreateProblemState>(
      listener: (context, state) {
        if (state.status == CreateProblemStatus.loading) {
          // Ví dụ: show dialog loading
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == CreateProblemStatus.success) {
          // Đóng loading nếu đang mở
          Navigator.of(context, rootNavigator: true).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Thêm sự cố thành công!")),
          );

          // push màn hình sau khi thêm thành công
          getIt<AppRouter>().push(ProblemHome());
        }

        if (state.status == CreateProblemStatus.error) {
          // Đóng loading nếu đang mở
          Navigator.of(context, rootNavigator: true).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Lỗi: ${state.error ?? 'Có lỗi xảy ra'}")),
          );
        }
      },
      child: Scaffold(
        // Thanh ứng dụng (AppBar)
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Thêm sự cố',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: const SizedBox.shrink(), // Bỏ nút quay lại mặc định
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () {
                getIt<AppRouter>().push(ProblemHome());
              },
            ),
          ],
        ),
        // Nội dung chính của màn hình
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // 1. Chọn phòng thuê
                const Text(
                  'Chọn phòng thuê',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                ),
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push<Map<String, dynamic>>(
                      context,
                      MaterialPageRoute(builder: (_) => const SelectRoom()),
                    );

                    if (result != null) {
                      print(
                        'Dữ liệu nhận từ SelectRoom: id=${result['id']}, name=${result['name']}',
                      );
                      setState(() {
                        _selectedRoomId = result['id'];
                        _selectedRoomName = result['name'];
                      });
                    }
                  },

                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedRoomName ?? 'Chọn phòng gặp sự cố',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                _selectedRoomName == null
                                    ? Colors.grey
                                    : Colors.black,
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),

                // 2. Sự cố (Nhập tóm tắt)
                _buildLabel('Tên sự cố'),
                const SizedBox(height: 8.0),
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
                    controller: nameProblem,
                    maxLines: 1,
                    decoration: const InputDecoration.collapsed(
                      border: InputBorder.none,
                      hintText: 'Nhập tên sự cố...',
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Mô tả sự cố
                _buildLabel('Mô tả sự cố'),
                const SizedBox(height: 8.0),
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
                    controller: detailProblem,
                    maxLines: 5,
                    decoration: const InputDecoration.collapsed(
                      hintText: 'Nhập mô tả sự cố...',
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Ảnh sự cố
                _buildLabel('Ảnh sự cố (tối đa 5 ảnh)'),
                const SizedBox(height: 8.0),
                _buildImageUploadSection(),
                const SizedBox(height: 24.0),

                // 5. Mức độ nghiêm trọng
                _buildLabel('Mức độ nghiêm trọng'),
                const SizedBox(height: 14.0),
                _buildSeveritySelection(),

                const SizedBox(height: 32.0),
                // Nút "Tạo sự cố"
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      final payload = {
                        "id_phong": _selectedRoomId,
                        "nameProblem": nameProblem.text,
                        "detailProblem": detailProblem.text,
                        "muc_do": _severity,
                      };

                      print("Payload gửi API: $payload");
                      // Gọi API tạo dịch vụ ở đây với payload
                      context.read<CreateProblemCubit>().createProblem(payload);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'Thêm sự cố',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget tạo phần tải ảnh
  Widget _buildImageUploadSection() {
    return Container(
      height: 140,
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
      child: Center(
        child: IconButton(
          icon: const Icon(Icons.add_circle, color: Colors.green, size: 40),
          onPressed: () {
            // Xử lý tải ảnh
          },
        ),
      ),
    );
    // Để giống hình hơn, ta dùng một container rỗng và nút '+'
    /*
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.green, size: 30),
            onPressed: () {
              // Xử lý tải ảnh
            },
          ),
        ],
      ),
    );
    */
  }

  // Widget tạo phần chọn mức độ nghiêm trọng
  Widget _buildSeveritySelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _buildSeverityOption('Cao', Colors.red, 'Cao'),
        _buildSeverityOption('Trung bình', Colors.orange, 'Trung bình'),
        _buildSeverityOption('Thấp', Colors.green, 'Thấp'),
      ],
    );
  }

  // Widget tạo một lựa chọn mức độ nghiêm trọng (Radio Button + Label)
  Widget _buildSeverityOption(String label, Color color, String value) {
    bool isSelected = _severity == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _severity = value;
        });

        print('Người dùng đã chọn mức độ: $_severity');
      },
      child: Row(
        children: [
          // Vòng tròn ngoài (giả lập Radio Button)
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? color : Colors.grey,
                width: 1.5,
              ),
            ),
            child: Center(
              // Dấu chấm bên trong
              child:
                  isSelected
                      ? Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                        ),
                      )
                      : null,
            ),
          ),
          const SizedBox(width: 8),
          // Nút màu (Label)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1), // Nền nhạt
              border: Border.all(color: color), // Viền đậm
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
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
