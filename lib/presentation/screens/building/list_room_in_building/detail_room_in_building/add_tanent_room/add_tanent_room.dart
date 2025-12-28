import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motelapp/logic/cubits/home/tanent_home/lessee_cubit.dart';
import 'package:motelapp/logic/cubits/home/tanent_home/lessee_state.dart';

class AddTanentRoom extends StatefulWidget {
  const AddTanentRoom({super.key});

  @override
  State<AddTanentRoom> createState() => _AddTanentRoomState();
}

class _AddTanentRoomState extends State<AddTanentRoom> {
  // Controllers để quản lý dữ liệu nhập vào
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _idCardController = TextEditingController();
  final TextEditingController _issueDateController = TextEditingController();
  final TextEditingController _issuePlaceController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

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

  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  // 2. Hàm chọn ảnh (Tự động thêm vào danh sách)
  Future<void> _pickImage(ImageSource source) async {
    // Nếu đã đủ 2 ảnh thì không cho chọn thêm (đề phòng)
    if (_selectedImages.length >= 2) return;

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImages.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      debugPrint("Lỗi chọn ảnh: $e");
    }
  }

  // 3. Hàm xóa ảnh theo index
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // 4. Hiển thị BottomSheet chọn nguồn
  void _showImageSourceActionSheet(BuildContext context) {
    if (_selectedImages.length >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã chọn đủ 2 ảnh (Mặt trước & sau)')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Chọn từ thư viện'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Chụp ảnh mới'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
    );
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
                onPressed: () async {
                  // --- DEBUG: IN GIÁ TRỊ RA ĐỂ KIỂM TRA ---
                  print("Tên: '${_nameController.text}'");
                  print("SĐT: '${_phoneController.text}'");
                  print("CMND: '${_idCardController.text}'");
                  // ----------------------------------------
                  // Chỉ kiểm tra thông tin cá nhân
                  if (_nameController.text.trim().isEmpty ||
                      _phoneController.text.trim().isEmpty ||
                      _idCardController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Vui lòng nhập đủ: Họ tên, SĐT và CMND/CCCD (*)',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Kiểm tra đã chọn ảnh chưa (Bắt buộc phải có ít nhất 1 ảnh)
                  if (_selectedImages.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Vui lòng chọn ảnh CCCD/CMND (Mặt trước & sau)',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // --- 2. CHUẨN BỊ PAYLOAD (DẠNG FORM DATA) ---
                  // Dùng FormData để gửi được File + Text
                  try {
                    // a. Đóng gói Text data
                    final Map<String, dynamic> textData = {
                      "name": _nameController.text.trim(),
                      "phone": _phoneController.text.trim(),
                      "email": _emailController.text.trim(),
                      "dob": _dobController.text.trim(),
                      "idCard": _idCardController.text.trim(),
                      "issueDate": _issueDateController.text.trim(),
                      "issuePlace": _issuePlaceController.text.trim(),
                      "address": _addressController.text.trim(),
                    };

                    // Tạo FormData từ Map text
                    final FormData formData = FormData.fromMap(textData);

                    // b. Đóng gói Ảnh (Loop qua list _selectedImages)
                    // Lưu ý: Key 'images' phải khớp với key mà Multer trên Server Node.js đang hứng
                    // Ví dụ server dùng: upload.array('images', 2)
                    for (var file in _selectedImages) {
                      formData.files.add(
                        MapEntry(
                          "images", // <-- Tên key này phải KHỚP với Server
                          await MultipartFile.fromFile(
                            file.path,
                            filename:
                                file.path.split('/').last, // Lấy tên file gốc
                          ),
                        ),
                      );
                    }

                    print("--- KIỂM TRA DỮ LIỆU FORM DATA ---");

                    // 1. In ra các trường Text
                    print("Danh sách Fields:");
                    for (var field in formData.fields) {
                      print("- Key: ${field.key} | Value: ${field.value}");
                    }

                    // 2. In ra các File ảnh
                    print("Danh sách Files:");
                    for (var file in formData.files) {
                      print(
                        "- Key: ${file.key} | Filename: ${file.value.filename} | Path: ${file.value.contentType}",
                      );
                    }

                    print("----------------------------------");

                    // --- 3. GỌI API QUA CUBIT ---
                    // Lưu ý: Bạn cần sửa hàm addTanentRoom trong Cubit
                    // để nó nhận tham số là 'FormData' thay vì 'Map'
                    context.read<LesseeCubit>().addTanentRoom(formData);
                  } catch (e) {
                    print("Lỗi khi tạo FormData: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Có lỗi khi xử lý ảnh')),
                    );
                  }
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
      height: 130, // Chiều cao hộp
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 18,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ô ảnh 1 (Mặt trước)
          Expanded(child: _buildSingleImageBox(0, "Mặt trước")),
          const SizedBox(width: 12), // Khoảng cách giữa 2 ô
          // Ô ảnh 2 (Mặt sau)
          Expanded(child: _buildSingleImageBox(1, "Mặt sau")),
        ],
      ),
    );
  }

  // Widget con: Hiển thị 1 ô ảnh đơn lẻ
  Widget _buildSingleImageBox(int index, String placeholderLabel) {
    // Kiểm tra xem vị trí index này đã có ảnh chưa
    bool hasImage = index < _selectedImages.length;
    File? imageFile = hasImage ? _selectedImages[index] : null;

    return GestureDetector(
      onTap: () {
        if (!hasImage) {
          _showImageSourceActionSheet(context);
        } else {
          // (Tuỳ chọn) Xem ảnh phóng to hoặc làm gì đó
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child:
            hasImage
                ? Stack(
                  fit: StackFit.expand,
                  children: [
                    // Ảnh
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(imageFile!, fit: BoxFit.cover),
                    ),
                    // Nút xóa X
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_a_photo, color: Colors.grey, size: 28),
                    const SizedBox(height: 4),
                    Text(
                      placeholderLabel,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
      ),
    );
  }
}
