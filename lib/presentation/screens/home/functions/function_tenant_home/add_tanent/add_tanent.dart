import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/home/tanent_home/lessee_cubit.dart';
import 'package:motelapp/logic/cubits/home/tanent_home/lessee_state.dart';
import 'package:motelapp/presentation/screens/home/functions/function_tenant_home/add_tanent/select_room.dart';

import 'package:motelapp/router/app_router.dart';

class AddTanent extends StatefulWidget {
  const AddTanent({super.key});

  @override
  State<AddTanent> createState() => _AddTanentState();
}

class _AddTanentState extends State<AddTanent> {
  // Controllers để quản lý dữ liệu nhập vào
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _idCardController = TextEditingController();
  final TextEditingController _issueDateController = TextEditingController();
  final TextEditingController _issuePlaceController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _roomDisplayController = TextEditingController();

  // Biến lưu id phòng đã chọn
  int? _selectedRoomId;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _idCardController.dispose();
    _issueDateController.dispose();
    _issuePlaceController.dispose();
    _addressController.dispose();
    _roomDisplayController.dispose();
    super.dispose();
  }

  // Hàm chọn ngày (Date Picker)
  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green, // Màu xanh chủ đạo
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LesseeCubit, LesseeState>(
      listener: (context, state) {
        // 1. Trường hợp đang xử lý (Loading)
        if (state.status == LesseeStatus.submitting) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => const Center(child: CircularProgressIndicator()),
          );
        } else if (state.status == LesseeStatus.addSuccess) {
          // Tắt loading dialog (của submitting)
          if (Navigator.canPop(context)) {
            Navigator.of(context, rootNavigator: true).pop();
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thành công!'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.of(context).pop(true);
        } else if (state.status == LesseeStatus.error) {
          if (Navigator.canPop(context)) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Lỗi'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white, // Màu nền trắng
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Thêm người thuê',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Họ và tên
                    _buildLabel("Họ và tên", isRequired: true),
                    _buildTextField(
                      controller: _nameController,
                      hintText: "Nhập họ và tên",
                    ),
                    const SizedBox(height: 16),

                    // 2. Số điện thoại
                    _buildLabel("Số điện thoại", isRequired: true),
                    _buildTextField(
                      controller: _phoneController,
                      hintText: "Nhập số điện thoại",
                      keyboardType: TextInputType.phone,
                      // Widget mới dùng Widget? suffix nên phải truyền cả Icon
                      suffix: const Icon(
                        Icons.contact_phone_outlined,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3. Chọn phòng thuê
                    _buildLabel("Chọn phòng thuê"),
                    GestureDetector(
                      onTap: () async {
                        // Logic chọn phòng thuê (Hiển thị danh sách phòng)
                        final result = await getIt<AppRouter>().push(
                          const SelectRoom(),
                        );

                        // Kiểm tra dữ liệu trả về
                        if (result != null && result is Map<String, dynamic>) {
                          setState(() {
                            // Lưu ID để sau này gọi API thêm người
                            _selectedRoomId = result['id'];

                            // Lưu Tên để hiển thị lên UI
                            _roomDisplayController.text = result['name'];
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: _buildTextField(
                          controller: _roomDisplayController,
                          hintText: "Chọn phòng thuê",
                          suffix: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 4. Email
                    _buildLabel("Email"),
                    _buildTextField(
                      controller: _emailController,
                      hintText: "Nhập email",
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // 5. Ngày sinh
                    _buildLabel("Ngày sinh"),
                    GestureDetector(
                      onTap: () => _selectDate(context, _dobController),
                      child: AbsorbPointer(
                        child: _buildTextField(
                          controller: _dobController,
                          hintText: "Chọn ngày sinh",
                          suffix: const Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 6. Số CMND/CCCD
                    _buildLabel("Số CMND/CCCD"),
                    _buildTextField(
                      controller: _idCardController,
                      hintText: "Nhập số CMND/CCCD",
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // 7. Ngày cấp
                    _buildLabel("Ngày cấp"),
                    GestureDetector(
                      onTap: () => _selectDate(context, _issueDateController),
                      child: AbsorbPointer(
                        child: _buildTextField(
                          controller: _issueDateController,
                          hintText: "Chọn ngày cấp CMND/CCCD",
                          suffix: const Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- PHẦN DƯỚI (BOX STYLE) ---

                    // 8. Nơi cấp (Dạng hộp)
                    _buildLabel("Nơi cấp"),
                    const SizedBox(height: 8),
                    _buildBoxTextField(
                      controller: _issuePlaceController,
                      hintText: "Nhập nơi cấp CMND/CCCD",
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // 9. Địa chỉ (Dạng hộp)
                    _buildLabel("Địa chỉ"),
                    const SizedBox(height: 8),
                    _buildBoxTextField(
                      controller: _addressController,
                      hintText: "Nhập địa chỉ của người thuê",
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // 10. Ảnh CMND/CCCD
                    _buildLabel("Ảnh CMND/CCCD (tối đa 2 ảnh)"),
                    const SizedBox(height: 8),
                    _buildImagePickerBox(),

                    const SizedBox(height: 40), // Khoảng trống cuối cùng
                  ],
                ),
              ),
            ),

            // Bottom Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  // 1. Validate dữ liệu
                  if (_nameController.text.isEmpty ||
                      _phoneController.text.isEmpty ||
                      _selectedRoomId == null ||
                      _idCardController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Vui lòng nhập đủ các trường bắt buộc (*)',
                        ),
                      ),
                    );
                    return;
                  }

                  // 2. Chuẩn bị Payload (KEY TIẾNG ANH - KHỚP VỚI SERVER MỚI)
                  final Map<String, dynamic> payload = {
                    // Server: const { roomId, name, phone ... } = req.body;
                    "roomId": _selectedRoomId, // Khớp với roomId
                    "name": _nameController.text.trim(), // Khớp với name
                    "phone": _phoneController.text.trim(), // Khớp với phone
                    "email": _emailController.text.trim(),

                    // Server dùng hàm split('/') nên Flutter phải gửi dạng dd/mm/yyyy
                    // Không cần hàm _convertDateToISO nữa, gửi nguyên text từ controller
                    "dob": _dobController.text.trim(),

                    "idCard": _idCardController.text.trim(),

                    "issueDate":
                        _issueDateController.text.trim(), // Gửi dd/mm/yyyy
                    "issuePlace": _issuePlaceController.text.trim(),
                    "address": _addressController.text.trim(),
                  };

                  print("Payload gửi lên server:");
                  print(payload);

                  // 3. Gọi API qua Cubit
                  context.read<LesseeCubit>().addTanentRoomFunctionHome(
                    payload,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Màu nút xanh giống ảnh
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Thêm người thuê",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget: Label (Tiêu đề field)
  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          children: [
            if (isRequired)
              const TextSpan(text: " *", style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  // Widget cho các ô nhập liệu (TextFormField)
  Widget _buildTextField({
    TextEditingController? controller,
    int maxLines = 1,
    TextInputType? keyboardType,
    Widget? suffix,
    bool isMultiline = false,
    String? hintText,
  }) {
    // Style cho các trường 1 dòng (có gạch chân)
    InputBorder singleLineBorder = const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.black12),
    );
    InputBorder singleLineFocusedBorder = const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.green, width: 2),
    );

    // Style cho trường Ghi chú (multiline, có nền)
    InputBorder multiLineBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    );

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: isMultiline, // Chỉ fill nền cho Ghi chú
        fillColor: Colors.grey.shade100, // Màu nền của Ghi chú
        contentPadding:
            isMultiline
                ? const EdgeInsets.all(12)
                : const EdgeInsets.symmetric(vertical: 10),
        border: isMultiline ? multiLineBorder : singleLineBorder,
        enabledBorder: isMultiline ? multiLineBorder : singleLineBorder,
        focusedBorder: isMultiline ? multiLineBorder : singleLineFocusedBorder,
        suffixIcon: suffix,
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 14,
        ), // Thêm style hint cho đẹp
      ),
    );
  }

  // Helper Widget: Input Field dạng hộp (Cho phần dưới: Nơi cấp, Địa chỉ)
  Widget _buildBoxTextField({
    TextEditingController? controller,
    String? hintText,
    int maxLines = 1,
  }) {
    return Container(
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
        controller: controller,
        maxLines: 5,
        decoration: InputDecoration.collapsed(hintText: hintText),
      ),
    );
  }

  // Helper Widget: Box thêm ảnh
  Widget _buildImagePickerBox() {
    return Container(
      height: 120,
      width: double.infinity,
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
        child: Icon(Icons.add_circle, color: Colors.green, size: 40),
      ),
    );
  }
}
