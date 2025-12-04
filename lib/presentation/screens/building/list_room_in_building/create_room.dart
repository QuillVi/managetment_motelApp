import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/models/service_model.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/building/amenity_cubit.dart';
import 'package:motelapp/logic/cubits/building/amenity_state.dart';
import 'package:motelapp/logic/cubits/building/detail_building_cubit.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/create_room_cubit.dart';
import 'package:motelapp/presentation/screens/building/list_room_in_building/detail_room_in_building/service_list_widget.dart';
import 'package:motelapp/presentation/screens/building/list_room_in_building/list_room_in_building.dart';
import 'package:motelapp/router/app_router.dart';

class CreateRoom extends StatefulWidget {
  final int buildingId;
  final String buildingName;
  const CreateRoom({
    super.key,
    required this.buildingId,
    required this.buildingName,
  });

  @override
  State<CreateRoom> createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> {
  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _roomPriceController = TextEditingController();
  final TextEditingController _roomFloorController = TextEditingController();
  final TextEditingController _roomBedRoomController = TextEditingController();
  final TextEditingController _roomLivingRoomController =
      TextEditingController();
  final TextEditingController _roomAcreageController = TextEditingController();
  final TextEditingController _roomTanentController = TextEditingController();
  final TextEditingController _roomDepositController = TextEditingController();
  final TextEditingController _roomDecriptionController =
      TextEditingController();
  final TextEditingController _roomNoteController = TextEditingController();

  final List<ServiceModel> _selectedServicesForPayload = [];

  final List<String> _selectedAmenities = [];
  void _toggleAmenity(String amenity) {
    // Cập nhật trạng thái
    setState(() {
      if (_selectedAmenities.contains(amenity)) {
        _selectedAmenities.remove(amenity);
        // Log khi BỎ CHỌN
        print('  -> Đã BỎ CHỌN "$amenity".');
      } else {
        _selectedAmenities.add(amenity);
        // Log khi CHỌN
        print('  -> Đã CHỌN "$amenity".');
      }
      // Log trạng thái hiện tại
      print('  -> Danh sách tiện ích hiện tại: $_selectedAmenities');
    });
  }

  String _listToCommaSeparatedString(List<String> list) {
    // Nối các phần tử trong danh sách lại với nhau, phân cách bằng dấu phẩy và khoảng trắng.
    return list.join(', ');
  }

  void _handleServiceSelectionChanged(ServiceModel service, bool isSelected) {
    setState(() {
      if (isSelected) {
        if (!_selectedServicesForPayload.any(
          (s) => s.id_dichvu == service.id_dichvu,
        )) {
          _selectedServicesForPayload.add(service);
        }
      } else {
        _selectedServicesForPayload.removeWhere(
          (s) => s.id_dichvu == service.id_dichvu,
        );
      }

      // Yêu cầu: In ra chuỗi ID đã chọn sau mỗi lần click
      _printSelectedServiceIds();
    });
  }

  // Hàm tạo chuỗi ID và in ra (theo yêu cầu)
  void _printSelectedServiceIds() {
    final String idString = _selectedServicesForPayload
        .map((s) => s.id_dichvu.toString())
        .join(',');

    print('I/flutter (Service IDs): Chuỗi ID dịch vụ đã chọn: $idString');
  }

  // Hàm tạo chuỗi ID để sử dụng trong payload
  String _selectServiceIdString() {
    return _selectedServicesForPayload
        .map((s) => s.id_dichvu.toString())
        .join(',');
  }

  Map<String, dynamic> _createRoomPayload() {
    final String serviceIdString = _selectServiceIdString();

    final String tienIchPhongString = _listToCommaSeparatedString(
      _selectedAmenities,
    );

    final Map<String, dynamic> payload = {
      // Trường số nguyên
      "id_toanha": widget.buildingId,
      "so_tang": int.tryParse(_roomFloorController.text.trim()) ?? 0,
      "phong_khach": int.tryParse(_roomLivingRoomController.text.trim()) ?? 0,
      "phong_ngu": int.tryParse(_roomBedRoomController.text.trim()) ?? 0,
      "so_nguoi_thue": int.tryParse(_roomTanentController.text.trim()) ?? 0,

      // Trường số thực
      "dien_tich": double.tryParse(_roomAcreageController.text.trim()) ?? 0.0,

      // Trường tiền tệ (có thể là int hoặc double, tùy API)
      "gia_phong": int.tryParse(_roomPriceController.text.trim()) ?? 0,
      "tien_dat_coc": int.tryParse(_roomDepositController.text.trim()) ?? 0,

      // Trường chuỗi
      "ten_phong": _roomNameController.text.trim(),
      "trang_thai": "Trống",
      "tien_ich_phong": tienIchPhongString,

      // Mô tả & Ghi chú
      "mo_ta_phong": _roomDecriptionController.text.trim(),
      "luu_y_cho_nguoi_thue_phong": _roomNoteController.text.trim(),

      // Dịch vụ (ID đã nối chuỗi)
      "services": serviceIdString,
    };

    // Loại bỏ các trường có giá trị là 0, 0.0, hoặc chuỗi rỗng sau khi trim (trừ các trường API yêu cầu)
    payload.removeWhere(
      (key, value) =>
          value == null ||
          (value is String && value.isEmpty) ||
          (value is int && value == 0 && key != "id_toanha") || // Giữ id_toanha
          (value is double && value == 0.0),
    );

    return payload;
  }

  @override
  void initState() {
    super.initState();
    context.read<DetailBuildingCubit>().loadBuildingDetail(widget.buildingId);

    context.read<AmenityCubit>().loadAmenitiesByToaNha(widget.buildingId);
  }

  @override
  void dispose() {
    super.dispose();
    _roomNameController.dispose();
    _roomPriceController.dispose();
    _roomFloorController.dispose();
    _roomBedRoomController.dispose();
    _roomLivingRoomController.dispose();
    _roomAcreageController.dispose();
    _roomTanentController.dispose();
    _roomDepositController.dispose();
    _roomDecriptionController.dispose();
    _roomNoteController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            getIt<AppRouter>().pop();
          },
        ),
        title: const Text(
          'Tạo phòng',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      // Body
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // 1. Tên phòng
                _buildTextField(
                  controller: _roomNameController,
                  label: 'Tên phòng',
                  hint: 'Nhập tên phòng',
                  isRequired: true,
                ),
                Divider(color: Colors.grey[300], height: 1, thickness: 1),
                const SizedBox(height: 8),
                // 2. Giá phòng dự kiến
                _buildTextField(
                  controller: _roomPriceController,
                  label: 'Giá phòng dự kiến',
                  hint: 'Nhập giá phòng',
                  isRequired: true,
                  keyboardType: TextInputType.number,
                ),
                Divider(color: Colors.grey[300], height: 1, thickness: 1),
                const SizedBox(height: 8),
                // 3. Tầng
                _buildTextField(
                  controller: _roomFloorController,
                  label: 'Tầng',
                  hint: 'Nhập tầng',
                  isRequired: true,
                  keyboardType: TextInputType.number,
                ),
                Divider(color: Colors.grey[300], height: 1, thickness: 1),
                const SizedBox(height: 8),
                // 4. Số phòng ngủ & Số phòng khách (trên cùng một hàng)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      // Số phòng ngủ
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: const TextSpan(
                                text: 'Số phòng ngủ',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                ),
                                children: [
                                  TextSpan(
                                    text: ' *',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _roomBedRoomController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 16),
                              decoration: InputDecoration(
                                hintText: 'Số phòng ngủ',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(0),
                                isDense: true,
                                fillColor: Colors.white,

                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Divider(
                              color: Colors.grey[300],
                              height: 1,
                              thickness: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20), // Khoảng cách giữa 2 trường
                      // Số phòng khách
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: const TextSpan(
                                text: 'Số phòng khách',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                ),
                                children: [
                                  TextSpan(
                                    text: ' *',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _roomLivingRoomController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 16),
                              decoration: InputDecoration(
                                hintText: 'Số phòng khách',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(0),
                                isDense: true,
                                fillColor: Colors.white,

                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Divider(
                              color: Colors.grey[300],
                              height: 1,
                              thickness: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                // 5. Diện tích (m2)
                _buildTextField(
                  controller: _roomAcreageController,
                  label: 'Diện tích (m2)',
                  hint: 'Nhập diện tích',
                  isRequired: true,
                  keyboardType: TextInputType.number,
                ),
                Divider(color: Colors.grey[300], height: 1, thickness: 1),
                const SizedBox(height: 8),
                // 6. Giới hạn số người thuê
                _buildTextField(
                  controller: _roomTanentController,
                  label: 'Giới hạn số người thuê',
                  hint: 'Nhập số người thuê',
                  isRequired: true,
                  keyboardType: TextInputType.number,
                ),
                Divider(color: Colors.grey[300], height: 1, thickness: 1),
                const SizedBox(height: 8),
                // 7. Tiền đặt cọc
                _buildTextField(
                  controller: _roomDepositController,
                  label: 'Tiền đặt cọc',
                  hint: 'Nhập số tiền đặt cọc khi khách thuê',
                  isRequired: false, // Trường này không có dấu *
                  keyboardType: TextInputType.number,
                ),
                Divider(color: Colors.grey[300], height: 1, thickness: 1),

                const SizedBox(height: 30),

                const SizedBox(height: 30),

                // 1. Tiêu đề Dịch vụ
                const Text(
                  'Dịch vụ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                // Container thông báo
                Container(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Text(
                    '(Chỉnh sửa dịch vụ của phòng sẽ không ảnh hưởng tới hợp đồng thuê nhà hiện tại)',
                    style: TextStyle(fontSize: 13, color: Colors.orange[800]),
                  ),
                ),

                ServiceListWidget(
                  onServiceChanged: _handleServiceSelectionChanged,
                ),

                const SizedBox(height: 30),

                // 2. Ảnh của phòng
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

                const SizedBox(height: 30),

                // 3. Tiện ích phòng
                const Text(
                  'Tiện ích phòng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                // Trong phần 'Tiện ích phòng' của hàm build:
                BlocBuilder<AmenityCubit, AmenityState>(
                  builder: (context, state) {
                    // 1. Trạng thái Loading
                    if (state.status == AmenityStatus.loading ||
                        state.status == AmenityStatus.initial) {
                      // Có thể hiển thị Skeleton hoặc chỉ ProgressIndicator
                      return const Center(child: CircularProgressIndicator());
                    }

                    // 2. Trạng thái Error
                    if (state.status == AmenityStatus.failure) {
                      return Center(
                        child: Text(
                          'Lỗi tải tiện ích: ${state.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    // 3. Trạng thái Success và có dữ liệu
                    final List<String> allAmenities = state.amenities;

                    if (allAmenities.isEmpty) {
                      return const Center(
                        child: Text(
                          'Không tìm thấy tiện ích nào.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children:
                          allAmenities.map((amenity) {
                            final isSelected = _selectedAmenities.contains(
                              amenity,
                            );

                            return _buildAmenityChip(
                              label: amenity,
                              isSelected: isSelected,
                              onTap: () => _toggleAmenity(amenity),
                            );
                          }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // 4. Mô tả phòng
                const Text(
                  'Mô tả phòng (dùng cho đẩy phòng)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                // Trường nhập liệu mô tả
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
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
                    controller: _roomDecriptionController,
                    maxLines: 5, // Cho phép nhập nhiều dòng
                    decoration: InputDecoration(
                      hintText: 'Nhập mô tả cho phòng',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey),
                      fillColor: Colors.white,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // 5. Mô tả phòng
                const Text(
                  'Lưu ý cho người thuê phòng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                // Trường nhập liệu mô tả
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
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
                    controller: _roomNoteController,
                    maxLines: 5, // Cho phép nhập nhiều dòng
                    decoration: InputDecoration(
                      hintText: 'Nhập lưu ý cho người thuê phòng',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey),
                      fillColor: Colors.white,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 30), // Khoảng trống cuối màn hình
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              print('Thêm phòng được nhấn!');

              final payload = _createRoomPayload();

              print('Payload gửi đi: $payload');

              context.read<CreateRoomCubit>().createRoom(payload);

              getIt<AppRouter>().push(
                ListRoomInBuilding(
                  buildingId: widget.buildingId, // <--- THÊM ID
                  buildingName: widget.buildingName,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Thêm toà nhà',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

// Widget để tạo các trường nhập liệu tiêu chuẩn (từ UI trước)
Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required String hint,
  bool isRequired = false,
  TextInputType keyboardType = TextInputType.text,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
            children: [
              if (isRequired)
                const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
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

// Widget cho các nút Tiện ích phòng
Widget _buildUtilityTag({
  required String text,
  required bool isSelected,
  required ValueChanged<bool> onSelected,
}) {
  return Padding(
    padding: const EdgeInsets.only(right: 10.0),
    child: ChoiceChip(
      label: Text(
        text,
        style: TextStyle(
          // Màu chữ sẽ thay đổi tùy thuộc vào trạng thái chọn
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),

      selected: isSelected, // Trạng thái chọn
      onSelected: onSelected, // Xử lý khi người dùng nhấp
      // LOẠI BỎ DẤU CHECK ĐI KÈM MẶC ĐỊNH
      showCheckmark: false,
      // MÀU SẮC KHI CHỌN/KHÔNG CHỌN
      selectedColor: Colors.green, // Màu nền khi được chọn (MÀU GREEN)
      // Màu xám đậm như trong ảnh gốc khi CHƯA được chọn
      backgroundColor: Colors.grey,

      // Cấu hình hình dáng
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
    ),
  );
}

// Custom Chip cho Tiện ích
Widget _buildAmenityChip({
  required String label,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.green : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}
