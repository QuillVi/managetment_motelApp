import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:motelapp/core/utils/thousands_formatter.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/detail_tanent_cubit.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/detail_tanent_state.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/tanent_room_cubit.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/tanent_room_state.dart';
import 'package:motelapp/router/app_router.dart';

class UpdateDetailTanent extends StatefulWidget {
  final int idNguoiThue;
  const UpdateDetailTanent({super.key, required this.idNguoiThue});

  @override
  State<UpdateDetailTanent> createState() => _UpdateDetailTanentState();
}

class _UpdateDetailTanentState extends State<UpdateDetailTanent> {
  // --- CONTROLLERS ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _cccdController = TextEditingController();
  final TextEditingController _issueDateCccdController =
      TextEditingController();
  final TextEditingController _issuePlaceCccdController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _depositController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();

  DateTime? _selectedDateOfBirth;
  DateTime? _selectedIssueDateCCCD;
  DateTime? _selectedStartDate;
  int? _selectedRoomId; // Sẽ được cập nhật khi API trả về

  // Hàm parse ngày an toàn
  DateTime? _parseDateString(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

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

  // Hàm thu thập dữ liệu từ UI để gửi lên Server
  Map<String, dynamic> _preparePayload() {
    // 1. Xử lý Tiền cọc: Xóa dấu chấm phân cách hàng nghìn (3.000.000 -> 3000000)
    String rawDeposit = _depositController.text.replaceAll('.', '');
    // Chuyển sang số (int hoặc double tùy backend, ở đây mình để int/double an toàn)
    // Nếu rỗng thì mặc định là 0
    num tienCoc = 0;
    if (rawDeposit.isNotEmpty) {
      tienCoc = num.tryParse(rawDeposit) ?? 0;
    }

    // 2. Xử lý ID Phòng (Nếu chưa chọn thì lấy mặc định hoặc 0)
    int idPhong = _selectedRoomId ?? 0;

    // 3. Gom dữ liệu vào Map (Key phải trùng khớp với Backend mong đợi)
    // Dựa vào model UserModel bạn đã gửi trước đó
    return {
      // --- CÁC TRƯỜNG BẮT BUỘC (Theo logic form) ---
      "id_nguoidung": widget.idNguoiThue, // ID người đang cập nhật
      "id_phong": idPhong,
      "ten": _nameController.text.trim(),
      "sdt":
          _phoneController.text
              .trim(), // Key backend nhận là 'sdt' hoặc 'so_dienthoai' tùy API update của bạn
      "cmnd_cccd": _cccdController.text.trim(),

      // Tiền cọc (Gửi số nguyên/thực, không gửi chuỗi có dấu chấm)
      "tien_coc": tienCoc,

      // Ngày bắt đầu (Format YYYY-MM-DD chuẩn SQL)
      "ngay_bat_dau": _startDateController.text.trim(),

      // --- CÁC TRƯỜNG TÙY CHỌN (Có thể rỗng) ---
      "email":
          "", // Nếu UI không có ô nhập email thì để rỗng hoặc giữ nguyên email cũ nếu có biến lưu
      "ngay_sinh": _birthdayController.text.trim(),
      "ngay_cap": _issueDateCccdController.text.trim(),
      "noi_cap": _issuePlaceCccdController.text.trim(),
      "dia_chi": _addressController.text.trim(),

      // Các trường khác nếu backend cần nhưng UI không sửa thì có thể bỏ qua
      // hoặc gửi null tùy logic backend
    };
  }

  @override
  void initState() {
    super.initState();

    // 1. Chỉ gọi API lấy chi tiết người thuê dựa vào ID
    // (Thông tin phòng sẽ được load sau khi có kết quả từ API này)
    context.read<DetailTanentCubit>().loadTanentDetail(widget.idNguoiThue);
  }

  // Hàm điền dữ liệu vào Controller
  void _populateDataToControllers(dynamic data) {
    _nameController.text = data.ten ?? '';
    _phoneController.text = data.soDienThoai ?? '';
    _cccdController.text = data.cmndCccd ?? '';
    _addressController.text = data.diaChi ?? '';
    _issuePlaceCccdController.text = data.noiCap ?? '';

    if (data.tienCoc != null) {
      double tien = double.tryParse(data.tienCoc.toString()) ?? 0;
      _depositController.text = tien.toInt().toString();
    }

    _selectedDateOfBirth = _parseDateString(data.ngaySinh);
    if (_selectedDateOfBirth != null) {
      _birthdayController.text = DateFormat(
        'yyyy-MM-dd',
      ).format(_selectedDateOfBirth!);
    }

    _selectedIssueDateCCCD = _parseDateString(data.ngayCap);
    if (_selectedIssueDateCCCD != null) {
      _issueDateCccdController.text = DateFormat(
        'yyyy-MM-dd',
      ).format(_selectedIssueDateCCCD!);
    }

    _selectedStartDate = _parseDateString(data.ngayBatDau);
    if (_selectedStartDate != null) {
      _startDateController.text = DateFormat(
        'yyyy-MM-dd',
      ).format(_selectedStartDate!);
    }

    // --- QUAN TRỌNG: Load thông tin phòng sau khi có dữ liệu ---
    if (data.id_phong != null) {
      try {
        int idPhongParsed = int.parse(data.id_phong.toString());
        _selectedRoomId = idPhongParsed;
        // Gọi API load tên phòng dựa trên ID vừa lấy được
        context.read<TanentRoomCubit>().loadNameRoomBuilding(idPhongParsed);
      } catch (e) {
        print("Lỗi parse ID phòng: $e");
      }
    }
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
    _depositController.dispose();
    _startDateController.dispose();
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
          'Cập nhật người thuê',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: BlocConsumer<DetailTanentCubit, DetailTanentState>(
        listener: (context, state) {
          if (state.status == DetailTanentStatus.loaded &&
              state.detailTanent != null) {
            _populateDataToControllers(state.detailTanent);
          }
          if (state.status == DetailTanentStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi: ${state.errorMessage}')),
            );
          }

          // --- LOGIC MỚI: XỬ LÝ KHI CẬP NHẬT THÀNH CÔNG ---
          if (state.status == DetailTanentStatus.updateSuccess) {
            // 1. Thông báo
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cập nhật thành công!'),
                backgroundColor: Colors.green,
              ),
            );

            // 2. Đóng màn hình và trả về kết quả 'true'
            // Dùng Navigator.pop hoặc router.pop đều được, nhưng phải gửi kèm 'true'
            Navigator.of(context).pop(true);
          }

          // Xử lý lỗi
          if (state.status == DetailTanentStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi: ${state.errorMessage}')),
            );
          }
        },

        builder: (context, state) {
          if (state.status == DetailTanentStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          bool isUpdating = state.status == DetailTanentStatus.updating;

          return Container(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildRequiredLabel('Họ và tên'),
                        _buildTextField(
                          controller: _nameController,
                          hint: 'Nhập họ và tên',
                        ),
                        Divider(color: Colors.grey[300]),
                        const SizedBox(height: 16.0),

                        _buildRequiredLabel('Số điện thoại'),
                        _buildPhoneTextField(
                          'Nhập số điện thoại',
                          context,
                          _phoneController,
                        ),
                        Divider(color: Colors.grey[300]),
                        const SizedBox(height: 16.0),

                        // --- PHÒNG THUÊ ---
                        _buildSimpleLabel('Phòng thuê'),
                        BlocBuilder<TanentRoomCubit, TanentRoomState>(
                          builder: (context, roomState) {
                            // Case 1: Đã load được tên phòng
                            if (roomState.status == TanentRoomStatus.loaded &&
                                roomState.nameRoomBuilding != null &&
                                roomState.nameRoomBuilding!.isNotEmpty) {
                              return _buildFixedText(
                                '${roomState.nameRoomBuilding!.first.ten_phong} - ${roomState.nameRoomBuilding!.first.ten_toanha}',
                              );
                            }
                            // Case 2: Đang load
                            if (roomState.status == TanentRoomStatus.loading) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: SizedBox(
                                  height: 15,
                                  width: 15,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            }
                            // Case 3: Chưa có dữ liệu hoặc lỗi
                            return _buildFixedText("Đang cập nhật...");
                          },
                        ),
                        Divider(color: Colors.grey[300]),
                        const SizedBox(height: 16.0),

                        // --- CÁC TRƯỜNG KHÁC GIỮ NGUYÊN ---
                        _buildRequiredLabel('Tiền đặt cọc'),
                        _buildTextField(
                          controller: _depositController,
                          hint: 'Nhập số tiền',
                          keyboardType: TextInputType.number,
                          inputFormatters: [ThousandsSeparatorInputFormatter()],
                        ),
                        Divider(color: Colors.grey[300]),
                        const SizedBox(height: 16.0),

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
                                  _startDateController.text = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(picked);
                                },
                              ),
                        ),
                        Divider(color: Colors.grey[300]),
                        const SizedBox(height: 16.0),

                        _buildRequiredLabel('Số CMND/CCCD'),
                        _buildTextField(
                          controller: _cccdController,
                          hint: 'Nhập số CMND/CCCD',
                          keyboardType: TextInputType.number,
                        ),
                        Divider(color: Colors.grey[300]),
                        const SizedBox(height: 16.0),

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
                                  _birthdayController.text = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(picked);
                                },
                              ),
                        ),
                        Divider(color: Colors.grey[300]),
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
                                  setState(
                                    () => _selectedIssueDateCCCD = picked,
                                  );
                                  _issueDateCccdController.text = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(picked);
                                },
                              ),
                        ),
                        Divider(color: Colors.grey[300]),
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

                // Nút Cập nhật
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 53,
                    child: ElevatedButton(
                      onPressed: () {
                        // 1. VALIDATE CƠ BẢN
                        if (_nameController.text.isEmpty ||
                            _phoneController.text.isEmpty ||
                            _depositController.text.isEmpty ||
                            _startDateController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Vui lòng nhập đầy đủ thông tin bắt buộc (*)!',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // 2. LẤY PAYLOAD
                        final payload = _preparePayload();

                        // In ra log để kiểm tra trước khi gửi
                        print("---------- DATA GỬI ĐI ----------");
                        print(payload);

                        // 3. GỌI CUBIT ĐỂ CẬP NHẬT (Ví dụ)
                        context.read<DetailTanentCubit>().updateTanent(payload);

                        getIt<AppRouter>().pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'Cập nhật',
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
          );
        },
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

  List<TextInputFormatter>? inputFormatters,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          inputFormatters: inputFormatters,
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
