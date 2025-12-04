import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/add_tanent_room_cubit.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/tanent_room_cubit.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/tanent_room_state.dart';
import 'package:motelapp/presentation/screens/building/list_room_in_building/detail_room_in_building/detail_room_in_building.dart';
import 'package:motelapp/presentation/screens/building/list_room_in_building/list_room_in_building.dart';
import 'package:motelapp/router/app_router.dart';

class AddTanentRoom extends StatefulWidget {
  final int roomId;
  final String roomName;
  const AddTanentRoom({
    super.key,
    required this.roomId,
    required this.roomName,
  });

  @override
  State<AddTanentRoom> createState() => _AddTanentRoomState();
}

class _AddTanentRoomState extends State<AddTanentRoom> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _cccdController = TextEditingController();
  final TextEditingController _issueDateCccdController =
      TextEditingController();
  final TextEditingController _issuePlaceCccdController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Biến để lưu trữ ngày sinh đã chọn
  DateTime? _selectedDateOfBirth;
  DateTime? _selectedIssueDateCCCD;

  // Biến lưu id phong
  int? _selectedRoomId;
  // Hàm tái sử dụng cho cả Ngày sinh và Ngày cấp CCCD
  Widget _buildDateField({
    required String hintText,
    required BuildContext context,
    required TextEditingController controller, // Thêm controller
    required DateTime? selectedDate, // Thêm DateTime đã chọn hiện tại
    required VoidCallback onTap, // Thêm hàm xử lý khi chạm (select date)
  }) {
    final String dateTextForController =
        selectedDate != null
            ? "${selectedDate.year}-"
                    "${selectedDate.month.toString().padLeft(2, '0')}-" + // Đảm bảo 2 chữ số cho tháng
                selectedDate.day.toString().padLeft(
                  2,
                  '0',
                ) // Đảm bảo 2 chữ số cho ngày
            : '';

    // 2. Định dạng ngày cho UI hiển thị (Tùy chọn: DD/MM/YYYY)
    final String dateTextForUI =
        selectedDate != null
            ? "${selectedDate.day.toString().padLeft(2, '0')}/"
                    "${selectedDate.month.toString().padLeft(2, '0')}/" +
                "${selectedDate.year}"
            : '';

    // 3. Cập nhật controller với giá trị SERVER (YYYY-MM-DD)
    // Đây là giá trị sẽ được gửi trong payload
    if (controller.text != dateTextForController) {
      controller.text = dateTextForController;
    }

    return TextField(
      readOnly: true, // Không cho gõ, chỉ chọn
      controller: controller, // Gán controller được truyền vào

      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),

        suffixIcon: const Icon(
          Icons.calendar_today_outlined,
          color: Colors.grey,
          size: 20,
        ),
        contentPadding: const EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 10.0),
        fillColor: Colors.white,

        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
      ),
      // 3. Gọi hàm chọn ngày khi người dùng chạm vào
      onTap: onTap,
    );
  }

  // --- Hàm hiển thị Date Picker ---
  Future<void> _selectDateOfBirth(BuildContext context) async {
    // Giá trị khởi tạo cho DatePicker (Ngày hiện tại)
    final initialDate = _selectedDateOfBirth ?? DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900), // Ngày sớm nhất có thể chọn
      lastDate:
          DateTime.now(), // Ngày muộn nhất là ngày hiện tại (hoặc 18 tuổi)
      // Tùy chỉnh theme để phù hợp với ứng dụng (nếu cần)
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            // Tùy chỉnh màu sắc chính
            colorScheme: const ColorScheme.light(
              primary: Colors.green, // Màu xanh lá cho header
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            // Tùy chỉnh màu nút "Hủy", "Chọn thời gian", "Chọn"
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.green, // Màu xanh lá cho chữ
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    // Cập nhật trạng thái nếu người dùng chọn ngày
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  Future<void> _selectIssueDateCCCD(BuildContext context) async {
    // Giá trị khởi tạo cho DatePicker (Ngày hiện tại)
    final initialDate = _selectedIssueDateCCCD ?? DateTime.now();

    final DateTime? pickedCCCD = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900), // Ngày sớm nhất có thể chọn
      lastDate:
          DateTime.now(), // Ngày muộn nhất là ngày hiện tại (hoặc 18 tuổi)
      // Tùy chỉnh theme để phù hợp với ứng dụng (nếu cần)
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            // Tùy chỉnh màu sắc chính
            colorScheme: const ColorScheme.light(
              primary: Colors.green, // Màu xanh lá cho header
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            // Tùy chỉnh màu nút "Hủy", "Chọn thời gian", "Chọn"
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.green, // Màu xanh lá cho chữ
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    // Cập nhật trạng thái nếu người dùng chọn ngày
    if (pickedCCCD != null && pickedCCCD != _selectedIssueDateCCCD) {
      setState(() {
        _selectedIssueDateCCCD = pickedCCCD; // Cập nhật biến _selectedDateCCCD
      });
    }
  }

  Map<String, dynamic> _createTenantPayload() {
    final Map<String, dynamic> payload = {
      "id_phong": _selectedRoomId,
      // Trường chuỗi
      "ten_nguoi_thue": _nameController.text.trim(), // Tên người thuê
      "so_dien_thoai": _phoneController.text.trim(), // Số điện thoại
      "ngay_sinh": _birthdayController.text.trim(), // Ngày sinh (dạng chuỗi)
      "cccd": _cccdController.text.trim(), // Số CCCD/CMND
      "ngay_cap_cccd":
          _issueDateCccdController.text.trim(), // Ngày cấp CCCD (dạng chuỗi)
      "noi_cap_cccd": _issuePlaceCccdController.text.trim(), // Nơi cấp CCCD
      "dia_chi_hien_tai": _addressController.text.trim(), // Địa chỉ hiện tại
    };

    // ---

    // Loại bỏ các trường có giá trị là chuỗi rỗng sau khi trim hoặc null
    payload.removeWhere(
      (key, value) =>
          // Chỉ áp dụng quy tắc loại bỏ cho các khóa KHÔNG PHẢI là 'id_phong'
          key != 'id_phong' &&
          (value == null || (value is String && value.isEmpty)),
    );

    return payload;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //gọi hàm api cubit
    context.read<TanentRoomCubit>().loadNameRoomBuilding(widget.roomId);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _birthdayController.dispose();
    _cccdController.dispose();
    _issueDateCccdController.dispose();
    _issuePlaceCccdController.dispose();
    _addressController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            getIt<AppRouter>().pop();
          },
        ),
        title: const Text(
          'Thêm người thuê',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      // Bọc Body trong Container để thiết lập màu nền
      body: Container(
        child: Column(
          children: [
            // Phần Form cuộn
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Tên
                    _buildRequiredLabel('Họ và tên'),
                    _buildTextField(
                      controller: _nameController,
                      hint: 'Nhập họ và tên',
                      isRequired: true,
                      keyboardType: TextInputType.number,
                    ),
                    Divider(color: Colors.grey[300], height: 1, thickness: 1),
                    const SizedBox(height: 16.0),

                    // Số điện thoại
                    _buildRequiredLabel('Số điện thoại'),
                    _buildPhoneTextField(
                      'Nhập số điện thoại',
                      context,
                      _phoneController,
                    ),
                    Divider(color: Colors.grey[300], height: 1, thickness: 1),
                    const SizedBox(height: 16.0),

                    // Phòng thuê (Không chỉnh sửa)
                    _buildSimpleLabel('Phòng thuê'),
                    BlocBuilder<TanentRoomCubit, TanentRoomState>(
                      builder: (context, state) {
                        // 1. Xử lý trạng thái Loading
                        if (state.status == TanentRoomStatus.loading) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }

                        // 2. Xử lý trạng thái Loaded và có dữ liệu
                        final nameRoomBuilding = state.nameRoomBuilding;
                        if (state.status == TanentRoomStatus.loaded &&
                            nameRoomBuilding != null &&
                            nameRoomBuilding.isNotEmpty) {
                          // Lấy đối tượng đầu tiên (theo JSON API trả về)
                          final roomBuilding = nameRoomBuilding.first;

                          // Kiểm tra Null Safety trước khi sử dụng
                          final tenPhong = roomBuilding.ten_phong ?? 'N/A';
                          final tenToanha = roomBuilding.ten_toanha ?? 'N/A';
                          final idPhong = roomBuilding.id_phong;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            // Bạn phải đảm bảo idPhong là một số nguyên (int) hoặc null
                            // Nếu idPhong của bạn đang là 'N/A' (chuỗi), bạn cần chuyển nó thành int?
                            if (idPhong is int) {
                              _selectedRoomId = idPhong as int?;
                            } else if (idPhong is String && idPhong != 'N/A') {
                              _selectedRoomId = idPhong;
                            } else {
                              _selectedRoomId = null;
                            }
                          });

                          print('ID phong được load là: $idPhong');

                          final displayText = '$tenPhong - $tenToanha';

                          return _buildFixedText(displayText);
                        }
                        // 3. Xử lý trạng thái Error
                        else if (state.status == TanentRoomStatus.error) {
                          return _buildFixedText(
                            'Lỗi tải dữ liệu: ${state.errorMessage ?? 'Không xác định'}',
                          );
                        }

                        // 4. Xử lý trạng thái Initial hoặc Loaded nhưng không có dữ liệu
                        return _buildFixedText('Đang tải/Chưa có dữ liệu');
                      },
                    ),
                    Divider(color: Colors.grey[300], height: 1, thickness: 1),
                    const SizedBox(height: 16.0),

                    // // Email (Không bắt buộc)
                    // _buildSimpleLabel('Email'),
                    // _buildTextField(
                    //   //controller:
                    //   hint: 'Nhập Email',
                    //   isRequired: false,
                    //   keyboardType: TextInputType.emailAddress,
                    // ),
                    // Divider(color: Colors.grey[300], height: 1, thickness: 1),
                    // const SizedBox(height: 16.0),

                    // Ngày sinh
                    _buildSimpleLabel('Ngày sinh'),
                    _buildDateField(
                      hintText: "Chọn ngày sinh",
                      context: context,
                      controller: _birthdayController, // Controller 1
                      selectedDate: _selectedDateOfBirth, // DateTime 1
                      onTap: () => _selectDateOfBirth(context), // Hàm chọn 1
                    ),
                    Divider(color: Colors.grey[300], height: 1, thickness: 1),
                    const SizedBox(height: 16.0),

                    // Số CMND/CCCD
                    _buildSimpleLabel('Số CMND/CCCD'),
                    _buildTextField(
                      controller: _cccdController,
                      hint: 'Nhập số CMND/CCCD',
                      isRequired: false,
                      keyboardType: TextInputType.number,
                    ),
                    Divider(color: Colors.grey[300], height: 1, thickness: 1),
                    const SizedBox(height: 16.0),

                    // Ngày cấp
                    _buildSimpleLabel('Ngày cấp'),
                    _buildDateField(
                      hintText: "Ngày cấp CCCD",
                      context: context,
                      controller: _issueDateCccdController, // Controller 2
                      selectedDate: _selectedIssueDateCCCD, // DateTime 2
                      onTap: () => _selectIssueDateCCCD(context), // Hàm chọn 2
                    ),
                    Divider(color: Colors.grey[300], height: 1, thickness: 1),
                    const SizedBox(height: 16.0),

                    // Nơi cấp
                    _buildSimpleLabel('Nơi cấp'),
                    const SizedBox(height: 8.0),
                    Container(
                      height: 150,
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
                      child: TextField(
                        controller: _issuePlaceCccdController,
                        maxLines: 5, // Cho phép nhập nhiều dòng
                        decoration: InputDecoration(
                          hintText: 'Nhập nơi cấp CMND/CCCD',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey),
                          fillColor: Colors.white,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16.0),

                    // Địa chỉ
                    _buildSimpleLabel('Địa chỉ'),
                    const SizedBox(height: 8.0),
                    Container(
                      height: 150,
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

                      child: TextField(
                        controller: _addressController,
                        maxLines: 5, // Cho phép nhập nhiều dòng
                        decoration: InputDecoration(
                          hintText: 'Nhập địa chỉ của người thuê',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey),
                          fillColor: Colors.white,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                        ),
                      ),
                    ), // maxLines cho ô địa chỉ rộng hơn
                    const SizedBox(height: 16.0),

                    // Ảnh CMND/CCCD
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ảnh của phòng',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Khu vực hiển thị ảnh (Dữ liệu trống)
                    Container(
                      height: 150,
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
                        child: Text(
                          'Dữ liệu trống',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Nút "Thêm người thuê" (Nằm cố định ở dưới)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              color: Colors.transparent,
              child: SizedBox(
                width: double.infinity,
                height: 53,
                child: ElevatedButton(
                  onPressed: () {
                    print('Thêm người thuê được nhấn!');

                    final payload = _createTenantPayload();

                    print('Payload gửi đi: $payload');

                    context.read<AddTanentRoomCubit>().addTanentRoom(payload);

                    getIt<AppRouter>().push(
                      DetailRoomInBuilding(
                        roomId: widget.roomId,
                        roomName: widget.roomName,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Màu xanh lá
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 0,
                  ),
                  child: Center(
                    child: Text(
                      'Thêm người thuê',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Đảm bảo không bị che bởi thanh điều hướng (notch) của điện thoại
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Widget TextField mới với kiểu Box ---
Widget _buildBoxTextField(String hintText, {int maxLines = 1}) {
  return TextField(
    maxLines: maxLines,
    decoration: InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 15.0,
        horizontal: 10.0,
      ),
      fillColor: Colors.white,
      filled: true,
      // Viền bo tròn hình chữ nhật
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none, // Bỏ viền nếu không muốn
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
          width: 1.0,
        ), // Viền xám nhạt
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.blue, width: 1.0),
      ),
    ),
  );
}

// --- Label đơn giản (Dùng lại) ---
Widget _buildSimpleLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
    ),
  );
}

// --- Widget cho phần Tải ảnh CMND/CCCD ---
Widget _buildImageUploadField(String label) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildSimpleLabel(label),
      Container(
        height: 120, // Chiều cao ước tính
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Nội dung (ví dụ: hình ảnh đã upload, hoặc text placeholder)
            Center(
              child: Text(
                'Bấm vào dấu cộng để tải ảnh',
                style: TextStyle(color: Colors.grey.shade400),
              ),
            ),
            // Nút thêm ảnh (dấu cộng màu xanh)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_circle,
                  color: Colors.green,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

// Label bắt buộc (*)
Widget _buildRequiredLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4.0),
    child: Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        const Text(
          ' *',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );
}

// Hiển thị text cố định (Phòng thuê)
Widget _buildFixedText(String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Text(
      text,
      style: const TextStyle(color: Colors.black, fontSize: 16),
    ),
  );
}

Widget _buildTextField({
  required TextEditingController controller,
  //required String label,
  required String hint,
  bool isRequired = false,
  TextInputType keyboardType = TextInputType.text,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),

            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(0),
            isDense: true,
            fillColor: Colors.white,

            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
          ),
        ),
        // Đường kẻ dưới (tùy chọn, vì ảnh có vẻ không có)
        // Divider(color: Colors.grey[300], height: 1, thickness: 1),
      ],
    ),
  );
}

// Text Field cho Số điện thoại (có icon)
Widget _buildPhoneTextField(
  String hintText,
  BuildContext context,
  TextEditingController controller,
) {
  return TextField(
    controller: controller,
    keyboardType: TextInputType.phone,
    decoration: InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
      // Giảm padding
      suffixIcon: Container(
        // Bọc Icon trong Container để giống hình ảnh
        decoration: BoxDecoration(
          color: Colors.grey[600], // Màu nền xám nhạt cho icon
          borderRadius: BorderRadius.circular(4.0),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(4.0),
        child: const Icon(Icons.person, color: Colors.white, size: 20),
      ),

      contentPadding: const EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 10.0),
      fillColor: Colors.white,

      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
    ),
  );
}
