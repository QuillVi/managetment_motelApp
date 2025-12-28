import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/add_tanent_room_cubit.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/tanent_room_cubit.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/tanent_room_state.dart';
import 'package:motelapp/presentation/screens/building/list_room_in_building/detail_room_in_building/detail_room_in_building.dart';
import 'package:motelapp/router/app_router.dart';

class AddTanentRoomTest extends StatefulWidget {
  final int roomId;
  final String roomName;
  const AddTanentRoomTest({
    super.key,
    required this.roomId,
    required this.roomName,
  });

  @override
  State<AddTanentRoomTest> createState() => _AddTanentRoomTestState();
}

class _AddTanentRoomTestState extends State<AddTanentRoomTest> {
  // --- CONTROLLERS CŨ ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _cccdController = TextEditingController();
  final TextEditingController _issueDateCccdController =
      TextEditingController();
  final TextEditingController _issuePlaceCccdController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // --- CONTROLLERS MỚI (BẮT BUỘC CHO BACKEND) ---
  final TextEditingController _depositController =
      TextEditingController(); // Tiền cọc
  final TextEditingController _startDateController =
      TextEditingController(); // Ngày bắt đầu

  // Biến lưu trữ ngày đã chọn
  DateTime? _selectedDateOfBirth;
  DateTime? _selectedIssueDateCCCD;
  DateTime? _selectedStartDate; // Ngày bắt đầu hợp đồng

  // Biến lưu id phong
  int? _selectedRoomId;

  // --- Hàm chọn ngày chung cho tất cả các trường Date ---
  Future<void> _selectDate(
    BuildContext context, {
    required DateTime? initialDate,
    required Function(DateTime) onDateSelected,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100), // Cho phép chọn ngày tương lai cho hợp đồng
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.green),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }

  // --- Widget chọn ngày (Date Field) ---
  Widget _buildDateField({
    required String hintText,
    required BuildContext context,
    required TextEditingController controller,
    required DateTime? selectedDate,
    required VoidCallback onTap,
  }) {
    // Logic: Luôn cập nhật controller theo định dạng YYYY-MM-DD để gửi lên Server
    if (selectedDate != null) {
      String formattedDate =
          "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

      if (controller.text != formattedDate) {
        controller.text = formattedDate;
      }
    }

    return TextField(
      readOnly: true,
      controller: controller,
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
      onTap: onTap,
    );
  }

  // --- HÀM TẠO PAYLOAD (ĐÃ SỬA LOGIC) ---
  Map<String, dynamic> _createTenantPayload() {
    // 1. Xử lý tiền cọc: Chuyển String sang int, mặc định là 0 nếu lỗi
    int tienCoc = 0;
    if (_depositController.text.isNotEmpty) {
      tienCoc = int.tryParse(_depositController.text) ?? 0;
    }

    // 2. Tạo Map đúng chuẩn Backend yêu cầu (snake_case)
    final Map<String, dynamic> payload = {
      "id_phong":
          _selectedRoomId ??
          widget.roomId, // Ưu tiên lấy từ state, fallback về widget
      // Các trường bắt buộc
      "ten_nguoi_thue": _nameController.text.trim(),
      "so_dien_thoai": _phoneController.text.trim(),
      "cccd": _cccdController.text.trim(),
      "tien_coc": tienCoc, // Gửi dạng số (int)
      "ngay_bat_dau":
          _startDateController.text.trim(), // Gửi dạng String 'YYYY-MM-DD'
      // Các trường tùy chọn
      "ngay_sinh": _birthdayController.text.trim(),
      "ngay_cap_cccd": _issueDateCccdController.text.trim(),
      "noi_cap_cccd": _issuePlaceCccdController.text.trim(),
      "dia_chi_hien_tai": _addressController.text.trim(),
    };

    // 3. Loại bỏ các trường rỗng (trừ các trường số và id)
    payload.removeWhere(
      (key, value) =>
          key != 'id_phong' &&
          key != 'tien_coc' &&
          (value == null || (value is String && value.isEmpty)),
    );

    return payload;
  }

  @override
  void initState() {
    super.initState();
    // Load thông tin phòng
    context.read<TanentRoomCubit>().loadNameRoomBuilding(widget.roomId);

    // Mặc định ngày bắt đầu là hôm nay
    _selectedStartDate = DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _birthdayController.dispose();
    _cccdController.dispose();
    _issueDateCccdController.dispose();
    _issuePlaceCccdController.dispose();
    _addressController.dispose();
    _depositController.dispose(); // Dispose mới
    _startDateController.dispose(); // Dispose mới
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => getIt<AppRouter>().pop(),
        ),
        title: const Text(
          'Thêm người thuê',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // --- THÔNG TIN BẮT BUỘC ---
                    _buildRequiredLabel('Họ và tên'),
                    _buildTextField(
                      controller: _nameController,
                      hint: 'Nhập họ và tên',
                    ),
                    Divider(color: Colors.grey[300], height: 1, thickness: 1),
                    const SizedBox(height: 16.0),

                    _buildRequiredLabel('Số điện thoại'),
                    _buildPhoneTextField(
                      'Nhập số điện thoại',
                      context,
                      _phoneController,
                    ),
                    Divider(color: Colors.grey[300], height: 1, thickness: 1),
                    const SizedBox(height: 16.0),

                    // --- PHÒNG THUÊ ---
                    _buildSimpleLabel('Phòng thuê'),
                    BlocBuilder<TanentRoomCubit, TanentRoomState>(
                      builder: (context, state) {
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
                        final nameRoomBuilding = state.nameRoomBuilding;
                        if (state.status == TanentRoomStatus.loaded &&
                            nameRoomBuilding != null &&
                            nameRoomBuilding.isNotEmpty) {
                          final roomBuilding = nameRoomBuilding.first;

                          // Cập nhật _selectedRoomId
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (roomBuilding.id_phong is int) {
                              _selectedRoomId = roomBuilding.id_phong as int?;
                            } else if (roomBuilding.id_phong is String) {
                              _selectedRoomId = int.tryParse(
                                roomBuilding.id_phong as String,
                              );
                            }
                          });

                          return _buildFixedText(
                            '${roomBuilding.ten_phong ?? 'N/A'} - ${roomBuilding.ten_toanha ?? 'N/A'}',
                          );
                        }
                        return _buildFixedText(
                          widget.roomName,
                        ); // Fallback hiển thị tên phòng từ widget
                      },
                    ),
                    Divider(color: Colors.grey[300], height: 1, thickness: 1),
                    const SizedBox(height: 16.0),

                    // --- TIỀN CỌC (MỚI - BẮT BUỘC) ---
                    _buildRequiredLabel('Tiền đặt cọc'),
                    _buildTextField(
                      controller: _depositController,
                      hint: 'Nhập số tiền (VD: 3000000)',
                      keyboardType: TextInputType.number,
                    ),
                    Divider(color: Colors.grey[300], height: 1, thickness: 1),
                    const SizedBox(height: 16.0),

                    // --- NGÀY BẮT ĐẦU (MỚI - BẮT BUỘC) ---
                    _buildRequiredLabel('Ngày bắt đầu hợp đồng'),
                    _buildDateField(
                      hintText: "Chọn ngày bắt đầu",
                      context: context,
                      controller: _startDateController,
                      selectedDate: _selectedStartDate,
                      onTap:
                          () => _selectDate(
                            context,
                            initialDate: _selectedStartDate,
                            onDateSelected: (picked) {
                              setState(() => _selectedStartDate = picked);
                            },
                          ),
                    ),
                    Divider(color: Colors.grey[300], height: 1, thickness: 1),
                    const SizedBox(height: 16.0),

                    // --- CMND/CCCD (BẮT BUỘC THEO BACKEND) ---
                    _buildRequiredLabel('Số CMND/CCCD'),
                    _buildTextField(
                      controller: _cccdController,
                      hint: 'Nhập số CMND/CCCD',
                      keyboardType: TextInputType.number,
                    ),
                    Divider(color: Colors.grey[300], height: 1, thickness: 1),
                    const SizedBox(height: 16.0),

                    // --- CÁC TRƯỜNG KHÁC ---
                    _buildSimpleLabel('Ngày sinh'),
                    _buildDateField(
                      hintText: "Chọn ngày sinh",
                      context: context,
                      controller: _birthdayController,
                      selectedDate: _selectedDateOfBirth,
                      onTap:
                          () => _selectDate(
                            context,
                            initialDate: _selectedDateOfBirth,
                            onDateSelected: (picked) {
                              setState(() => _selectedDateOfBirth = picked);
                            },
                          ),
                    ),
                    Divider(color: Colors.grey[300], height: 1, thickness: 1),
                    const SizedBox(height: 16.0),

                    _buildSimpleLabel('Ngày cấp'),
                    _buildDateField(
                      hintText: "Ngày cấp CCCD",
                      context: context,
                      controller: _issueDateCccdController,
                      selectedDate: _selectedIssueDateCCCD,
                      onTap:
                          () => _selectDate(
                            context,
                            initialDate: _selectedIssueDateCCCD,
                            onDateSelected: (picked) {
                              setState(() => _selectedIssueDateCCCD = picked);
                            },
                          ),
                    ),
                    Divider(color: Colors.grey[300], height: 1, thickness: 1),
                    const SizedBox(height: 16.0),

                    _buildSimpleLabel('Nơi cấp'),
                    const SizedBox(height: 8.0),
                    _buildBoxTextField(
                      _issuePlaceCccdController,
                      'Nhập nơi cấp CMND/CCCD',
                    ),
                    const SizedBox(height: 16.0),

                    _buildSimpleLabel('Địa chỉ thường trú'),
                    const SizedBox(height: 8.0),
                    _buildBoxTextField(
                      _addressController,
                      'Nhập địa chỉ của người thuê',
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),

            // Nút Submit
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: SizedBox(
                width: double.infinity,
                height: 53,
                child: ElevatedButton(
                  onPressed: () {
                    // Validate sơ bộ
                    if (_nameController.text.isEmpty ||
                        _phoneController.text.isEmpty ||
                        _cccdController.text.isEmpty ||
                        _depositController.text.isEmpty ||
                        _startDateController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Vui lòng nhập đầy đủ các trường bắt buộc (*)',
                          ),
                        ),
                      );
                      return;
                    }

                    final payload = _createTenantPayload();
                    print('Payload gửi đi: $payload');

                    //context.read<AddTanentRoomCubit>().addTanentRoom(form);

                    getIt<AppRouter>().push(
                      DetailRoomInBuilding(
                        roomId: widget.roomId,
                        roomName: widget.roomName,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
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
          ],
        ),
      ),
    );
  }

  // --- WIDGETS CON (Helper) ---

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

  Widget _buildRequiredLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0, top: 8.0),
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

  Widget _buildFixedText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black, fontSize: 16),
      ),
    );
  }
}

// --- Widget TextField mới với kiểu Box ---
Widget _buildBoxTextField(TextEditingController controller, String hintText) {
  return TextField(
    controller: controller,
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
