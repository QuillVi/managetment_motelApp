import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motelapp/data/models/StakeMemberPayload.dart';

class AddStaker extends StatefulWidget {
  const AddStaker({super.key});

  @override
  State<AddStaker> createState() => _AddStakerState();
}

class _AddStakerState extends State<AddStaker> {
  // Controllers quản lý dữ liệu nhập vào
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _idCardController =
      TextEditingController(); // CMND/CCCD
  final TextEditingController _addressController = TextEditingController();

  // --- 1. BIẾN QUẢN LÝ ẢNH ---
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = []; // Danh sách ảnh đã chọn

  // --- 2. HÀM CHỌN ẢNH ---
  Future<void> _pickImage() async {
    if (_selectedImages.length >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chỉ được chọn tối đa 2 ảnh')),
      );
      return;
    }

    // Hiển thị Modal chọn Camera hoặc Thư viện
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Chọn từ thư viện'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null) {
                      setState(() {
                        _selectedImages.add(image);
                      });
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Chụp ảnh'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final XFile? photo = await _picker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (photo != null) {
                      setState(() {
                        _selectedImages.add(photo);
                      });
                    }
                  },
                ),
              ],
            ),
          ),
    );
  }

  // Hàm xóa ảnh
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // Hàm xử lý nút Thêm
  void _handleAddStaker() {
    // 1. Validate dữ liệu
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập Tên và Số điện thoại')),
      );
      return;
    }

    // 2. Tạo object người (Payload)
    // Lưu ý: Cần thêm trường 'anh_cmnd' để chứa list đường dẫn ảnh
    final newPerson = StakeMemberPayload(
      ten: _nameController.text,
      sdt: _phoneController.text,
      email: _emailController.text,
      cmnd: _idCardController.text,
      diaChi: _addressController.text,

      // --- THÊM PHẦN NÀY ---
      // Lấy path của các file XFile đã chọn
      anhCmnd: _selectedImages.map((e) => e.path).toList(),
      // ---------------------
    );

    // 3. Trả dữ liệu về màn hình trước
    Navigator.of(context).pop(newPerson);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _idCardController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // Màu nền xám rất nhạt
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Thêm người cọc',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
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
            // 6. Số CMND/CCCD
            _buildLabel("Số CMND/CCCD"),
            _buildTextField(
              controller: _idCardController,
              hintText: "Nhập số CMND/CCCD",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
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

            const SizedBox(height: 40),

            // 7. Nút Thêm
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50), // Màu xanh lá
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                onPressed: () {
                  // TODO: Xử lý lưu và trả dữ liệu về màn hình trước
                  _handleAddStaker();
                },
                child: const Text(
                  'Thêm',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
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

  Widget _buildImagePickerBox() {
    // TRƯỜNG HỢP 1: Chưa có ảnh nào -> Hiển thị Box to như bạn thiết kế
    if (_selectedImages.isEmpty) {
      return GestureDetector(
        onTap: _pickImage, // Gắn sự kiện click
        child: Container(
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
        ),
      );
    }

    // TRƯỜNG HỢP 2: Đã có ảnh -> Hiển thị Grid ảnh
    return Container(
      width: double.infinity,
      // GridView cần chiều cao cụ thể hoặc shrinkWrap
      constraints: const BoxConstraints(minHeight: 120),
      child: GridView.builder(
        shrinkWrap: true, // Co lại vừa nội dung
        physics: const NeverScrollableScrollPhysics(), // Không cuộn riêng
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 ảnh 1 hàng
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.5, // Tỷ lệ khung hình chữ nhật
        ),
        itemCount:
            _selectedImages.length + (_selectedImages.length < 2 ? 1 : 0),
        itemBuilder: (context, index) {
          // Nếu là ô cuối cùng và chưa đủ 2 ảnh -> Hiện nút Thêm nhỏ
          if (index == _selectedImages.length) {
            return GestureDetector(
              onTap: _pickImage,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_circle, color: Colors.green, size: 30),
                      SizedBox(height: 4),
                      Text(
                        "Thêm ảnh",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // Hiển thị ảnh đã chọn
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(File(_selectedImages[index].path)),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              // Nút Xóa ảnh (Góc trên phải)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
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
          );
        },
      ),
    );
  }
}
