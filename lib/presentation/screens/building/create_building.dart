import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/models/service_model.dart';
import 'package:motelapp/data/repositories/auth_repository.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/building/amenity_cubit.dart';
import 'package:motelapp/logic/cubits/building/amenity_state.dart';
import 'package:motelapp/logic/cubits/building/create_building_cubit.dart';
import 'package:motelapp/logic/cubits/managet/manage_cubit.dart';
import 'package:motelapp/logic/cubits/managet/manage_state.dart';
import 'package:motelapp/presentation/screens/building/building_screen.dart';
import 'package:motelapp/presentation/screens/building/select_service.dart';

import 'package:motelapp/router/app_router.dart';

// Đây là class StatefulWidget của màn hình, giữ nguyên tên
class CreateBuilding extends StatefulWidget {
  const CreateBuilding({super.key});

  @override
  State<CreateBuilding> createState() => _CreateBuildingState();
}

class _CreateBuildingState extends State<CreateBuilding> {
  // --- Controllers và Variables cho TOÀN BỘ Form ---
  // (Giữ nguyên các Controllers và List<String> từ các phần trước)
  final TextEditingController _buildingNameController = TextEditingController();
  final TextEditingController _floorCountController = TextEditingController();
  final TextEditingController _rentCostController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  Timer? _debounceTimer;
  String? _selectedProvinceCity;
  String? _selectedDistrict;
  // Khai báo các biến trạng thái và dữ liệu
  // Dữ liệu mô phỏng việc liên kết Tỉnh/Thành phố và Quận/Huyện
  final Map<String, List<String>> _dataMap = {
    'Hà Nội': [
      'Quận Ba Đình',
      'Quận Hoàn Kiếm',
      'Quận Tây Hồ',
      'Quận Hai Bà Trưng',
      'Quận Đống Đa',
      'Quận Cầu Giấy',
      'Quận Thanh Xuân',
      'Quận Hoàng Mai',
      'Quận Long Biên',
      'Quận Bắc Từ Liêm',
      'Quận Nam Từ Liêm',
      'Quận Hà Đông',
      'Thị xã Sơn Tây',
      'Huyện Ba Vì',
      'Huyện Chương Mỹ',
      'Huyện Đan Phượng',
      'Huyện Đông Anh',
      'Huyện Gia Lâm',
      'Huyện Hoài Đức',
      'Huyện Mê Linh',
      'Huyện Mỹ Đức',
      'Huyện Phú Xuyên',
      'Huyện Phúc Thọ',
      'Huyện Quốc Oai',
      'Huyện Sóc Sơn',
      'Huyện Thạch Thất',
      'Huyện Thanh Oai',
      'Huyện Thanh Trì',
      'Huyện Thường Tín',
      'Huyện Ứng Hòa',
    ],
    'Hồ Chí Minh': [
      'Quận 1',
      'Quận 3',
      'Quận 4',
      'Quận 5',
      'Quận 6',
      'Quận 7',
      'Quận 8',
      'Quận 10',
      'Quận 11',
      'Quận 12',
      'Quận Bình Thạnh',
      'Quận Bình Tân',
      'Quận Gò Vấp',
      'Quận Phú Nhuận',
      'Quận Tân Bình',
      'Quận Tân Phú',
      'Quận Thủ Đức', // Thành phố Thủ Đức (Bao gồm Q.2, Q.9, Q.Thủ Đức cũ)
      'Huyện Bình Chánh',
      'Huyện Cần Giờ',
      'Huyện Củ Chi',
      'Huyện Hóc Môn',
      'Huyện Nhà Bè',
    ],
    'Đà Nẵng': [
      'Quận Hải Châu',
      'Quận Cẩm Lệ',
      'Quận Thanh Khê',
      'Quận Sơn Trà',
      'Quận Ngũ Hành Sơn',
      'Quận Liên Chiểu',
      'Huyện Hòa Vang',
      'Huyện Hoàng Sa',
    ],
  };

  // Lấy danh sách Tỉnh/Thành phố từ Map
  late final List<String> _provinceCities = _dataMap.keys.toList();

  // Phần 2 (Từ hình ảnh trước)
  final TextEditingController _openTimeController = TextEditingController(
    text: '6:00',
  );
  final TextEditingController _closeTimeController = TextEditingController(
    text: '23:00',
  );
  final TextEditingController _dueDateController = TextEditingController();
  final TextEditingController _noticeDaysController = TextEditingController();
  final TextEditingController _periodDateController = TextEditingController();
  DateTime? _selectedDueDate;

  // --- NEW: Phần 3 (Từ hình ảnh mới nhất) ---
  final TextEditingController _buildingNoteController = TextEditingController();
  final TextEditingController _billNoteController = TextEditingController();
  final List<String> _selectedAmenities = [];

  List<ServiceModel> _selectedServicesForDisplay = [];

  void _showSelectionDialog({
    required BuildContext context,
    required String title,
    required List<String> items,
    required Function(String) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext dialogContext) {
        return Container(
          height:
              MediaQuery.of(context).size.height * 0.9, // Chiếm 90% màn hình
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(dialogContext).viewInsets.bottom,
          ),
          child: Column(
            children: [
              // Phần Header và Nút Đóng
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Nút Đóng (X)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ],
                ),
              ),

              // Thanh Tìm kiếm (Chỉ là placeholder cho giống UI)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                  ),
                  onChanged: (query) {
                    // Thêm logic lọc ở đây nếu cần (yêu cầu StatefulBuilder)
                  },
                ),
              ),

              // Danh sách các mục
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder:
                      (context, index) => const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Colors.grey,
                        ),
                      ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      title: Text(item),
                      onTap: () {
                        onSelect(item);
                        Navigator.pop(dialogContext);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  //hàm log full address
  void _logFullAddress() {
    final address = _addressController.text.trim();
    final district = _selectedDistrict;
    final provinceCity = _selectedProvinceCity;

    // Chỉ log khi ít nhất 2 trong 3 trường đã được chọn
    if (address.isNotEmpty || district != null || provinceCity != null) {
      // Tạo chuỗi địa chỉ đầy đủ
      final fullAddress = [
        if (address.isNotEmpty) address,
        if (district != null) district,
        if (provinceCity != null) provinceCity,
      ].join(', ');

      print('ĐỊA CHỈ ĐÃ CẬP NHẬT: $fullAddress');
    }
  }

  // Hàm được gọi bởi _addressController.addListener()
  void _onAddressChanged() {
    // 1. Hủy bỏ timer hiện có nếu nó đang chạy
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    // 2. Thiết lập một timer mới. Hàm log sẽ chạy sau 500 mili giây (0.5 giây)
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      // 3. Thực thi hàm log chính sau khi người dùng ngừng gõ
      _logFullAddress();
    });
  }

  String _createFullAddressStringForApi() {
    final String addressDetail = _addressController.text.trim();
    final String? district = _selectedDistrict;
    final String? provinceCity = _selectedProvinceCity;

    // Tạo danh sách các phần của địa chỉ, chỉ thêm các phần có giá trị
    final List<String> addressParts = [
      if (addressDetail.isNotEmpty) addressDetail,
      if (district != null) district,
      if (provinceCity != null) provinceCity,
    ];

    print('addressParts: $addressParts');

    return addressParts.join(', ');
  }

  final AuthRepository _authRepository = AuthRepository();

  Future<int?> _getManagerId() async {
    // Gọi hàm lấy ID từ Repository bạn vừa cung cấp
    return await _authRepository.getUserId();
  }

  String _selectServiceIdString() {
    // 1. Lấy danh sách các ID dưới dạng Iterable<int>
    final Iterable<int> serviceIds = _selectedServicesForDisplay.map(
      (service) => service.id_dichvu,
    );

    // 2. Chuyển đổi Iterable<int> thành List<String>
    final List<String> serviceIdStrings =
        serviceIds.map((id) => id.toString()).toList();

    // 3. Nối các chuỗi ID lại với nhau, phân cách bằng dấu phẩy
    final String idString = serviceIdStrings.join(',');

    // Bạn có thể giữ log này để kiểm tra
    print('Chuỗi ID dịch vụ đã chọn để gửi API: $idString');
    return idString;
  }

  // Helper cho việc chọn/bỏ chọn tiện ích (amenities)
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

  Map<String, dynamic> _createBuildingPayload() {
    // Lấy chuỗi địa chỉ đầy đủ theo yêu cầu API
    final String fullAddress = _createFullAddressStringForApi();

    final String rentCostString = _rentCostController.text.trim();
    final String floorCountString = _floorCountController.text.trim();

    final String dueDateApiString = _dueDateController.text.trim();

    final String noticeDaysText = _noticeDaysController.text.trim();
    final String noticeDaysApiString =
        noticeDaysText.isEmpty ? '' : '$noticeDaysText ngày'; // Ví dụ: "7 ngày"

    final String periodDateApiString = _periodDateController.text.trim();
    final String serviceIdString = _selectServiceIdString();

    final Map<String, dynamic> payload = {
      "name": _buildingNameController.text.trim(),
      "total_floor": floorCountString,
      "rent_cost": rentCostString,
      "description": _descriptionController.text.trim(),
      "address": fullAddress,
      "open_time": _openTimeController.text.trim(),
      "close_time": _closeTimeController.text.trim(),

      "due_date": dueDateApiString,

      "notice_days": noticeDaysApiString,

      "period_date": periodDateApiString,

      "services": serviceIdString,
      "amenities": _selectedAmenities,
      "building_note": _buildingNoteController.text.trim(),
      "bill_note": _billNoteController.text.trim(),
    };

    // Loại bỏ các trường trống/null
    payload.removeWhere(
      (key, value) => value == null || (value is String && value.isEmpty),
    );

    return payload;
  }

  @override
  void initState() {
    super.initState();
    //gọi api get manage
    context.read<ManageCubit>().fetchManage();

    //gọi api get amenities
    context.read<AmenityCubit>().loadAmenities();

    // Thêm listener cho ô nhập Địa chỉ
    _addressController.addListener(_onAddressChanged);
  }

  @override
  void dispose() {
    _buildingNameController.dispose();
    _floorCountController.dispose();
    _rentCostController.dispose();
    _descriptionController.dispose();

    _addressController.removeListener(_logFullAddress);
    _addressController.dispose();
    _openTimeController.dispose();
    _closeTimeController.dispose();
    _dueDateController.dispose();
    _noticeDaysController.dispose();
    _periodDateController.dispose();
    // --- NEW: Dispose new controllers ---
    _buildingNoteController.dispose();
    _billNoteController.dispose();
    // --- END NEW ---
    super.dispose();
  }

  // Helper for selecting date
  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
    Function(DateTime?) onDateSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.day}/${picked.month}/${picked.year}";
        onDateSelected(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Colors.black;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => getIt<AppRouter>().pop(context),
        ),
        title: const Text(
          'Thêm toà nhà',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- Phần 1 (Tên toà nhà đến Quận/Huyện) ---
            _buildRequiredLabel('Tên toà nhà'),
            _buildTextField(
              controller: _buildingNameController,
              hintText: 'Nhập tên toà nhà',
            ),
            const SizedBox(height: 20),

            _buildRequiredLabel('Số tầng'),
            _buildTextField(
              controller: _floorCountController,
              hintText: 'Nhập số tầng',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            _buildLabel('Chi phí thuê nhà'),
            _buildTextField(
              controller: _rentCostController,
              hintText: 'Nhập chi phí thuê nhà nếu có',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            _buildRequiredLabel('Mô tả'),
            _buildTextField(
              controller: _descriptionController,
              hintText: 'Nhập mô tả cho toà nhà',
              maxLines: 4,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 20),

            _buildRequiredLabel('Địa chỉ'),
            _buildTextField(
              controller: _addressController,
              hintText: 'Nhập địa chỉ',
              keyboardType: TextInputType.streetAddress,
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // ====== Ô CHỌN TỈNH/THÀNH PHỐ ======
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRequiredLabel('Tỉnh/Thành phố'),
                      _buildSelectableField(
                        hintText: 'Chọn Tỉnh/Thành...',
                        value: _selectedProvinceCity,
                        onTap: () {
                          _showSelectionDialog(
                            context: context,
                            title: 'Tỉnh/Thành phố',
                            items: _provinceCities,
                            onSelect: (selected) {
                              setState(() {
                                // 1. Cập nhật Tỉnh/Thành phố
                                _selectedProvinceCity = selected;
                                // 2. Reset Quận/Huyện khi Tỉnh/Thành phố thay đổi
                                _selectedDistrict = null;
                              });
                              _logFullAddress();
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),

                // ====== Ô CHỌN QUẬN/HUYỆN ======
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRequiredLabel('Quận/Huyện'),
                      _buildSelectableField(
                        hintText: 'Chọn Quận/Huyện',
                        value: _selectedDistrict,
                        onTap: () {
                          // Ràng buộc: CHƯA CHỌN TỈNH/THÀNH PHỐ
                          if (_selectedProvinceCity == null) {
                            // Có thể hiển thị SnackBar hoặc thông báo
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Vui lòng chọn Tỉnh/Thành phố trước.',
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return; // Ngăn không cho mở dialog
                          }

                          // Lọc danh sách Quận/Huyện theo Tỉnh/Thành phố đã chọn
                          final List<String> availableDistricts =
                              _dataMap[_selectedProvinceCity] ?? [];

                          _showSelectionDialog(
                            context: context,
                            title: 'Quận/Huyện',
                            items: availableDistricts,
                            onSelect: (selected) {
                              setState(() {
                                _selectedDistrict = selected;
                              });
                              _logFullAddress();
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // --- Phần 2 (Giờ Mở/Đóng, Chốt tiền, Quản lý, Dịch vụ có phí) ---
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Mở cửa'),
                      _buildTextField(
                        controller: _openTimeController,
                        hintText: 'Giờ mở cửa',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Đóng cửa'),
                      _buildTextField(
                        controller: _closeTimeController,
                        hintText: 'Giờ đóng cửa',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRequiredLabel('Ngày chốt tiền'),
                      _buildTextField(
                        controller: _dueDateController,
                        hintText: 'Chọn ngày',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRequiredLabel('Báo chuyển trước'),
                      _buildTextField(
                        controller: _noticeDaysController,
                        hintText: 'Số ngày báo trước',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildRequiredLabel('Thời gian nộp tiền phòng'),
            _buildTextField(
              controller: _periodDateController,
              hintText: 'Số ngày nộp tiền hàng tháng',
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 30),

            // Header: Quản lý toà nhà
            _buildSectionHeader('Quản lý toà nhà', onTap: () {}),

            // --- Sử dụng BlocBuilder để hiển thị dữ liệu ---
            BlocBuilder<ManageCubit, ManageState>(
              builder: (context, state) {
                // 1. Trạng thái Loading
                if (state.status == ManageStatus.loading ||
                    state.status == ManageStatus.initial) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                // 2. Trạng thái Error
                if (state.status == ManageStatus.error) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Center(
                      child: Text(
                        'Lỗi tải dữ liệu: ${state.error}',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                // 3. Trạng thái Loaded (và dữ liệu hợp lệ)
                final manager = state.manage;

                if (state.status == ManageStatus.loaded && manager != null) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: _buildManagerCard(
                      name: manager.ten ?? 'Chưa có Tên',
                      phone: manager.soDienThoai ?? 'Chưa có SĐT',
                      onTap: () {
                        // Xử lý khi nhấn vào card (ví dụ: gọi điện)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gọi đến: ${manager.soDienThoai}'),
                          ),
                        );
                      },
                    ),
                  );
                }

                // 4. Trạng thái Loaded nhưng không có dữ liệu (manager == null)
                return const Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Center(
                    child: Text(
                      'Chưa có thông tin quản lý.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              },
            ),

            //dich vụ có phí
            _buildServiceSection(context),
            const SizedBox(height: 30),

            _buildSectionHeader(
              'Dịch vụ miễn phí',
              onTap: () {
                // Xử lý thêm dịch vụ miễn phí
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: Text(
                  'Dữ liệu trống',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // --- Tiện ích toà nhà (Building Amenities) ---
            const Text(
              'Tiện ích toà nhà',
              style: TextStyle(
                color: primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
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
                        final isSelected = _selectedAmenities.contains(amenity);

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

            const Text(
              'Lưu ý của toà nhà',
              style: TextStyle(
                color: primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildNoteTextField(
              controller: _buildingNoteController,
              hintText: 'Nhập lưu ý của toà nhà cho người thuê phòng',
            ),
            const SizedBox(height: 30),

            // --- Ghi chú cho hoá đơn (Notes for Invoice) ---
            const Text(
              'Ghi chú cho hoá đơn',
              style: TextStyle(
                color: primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildNoteTextField(
              controller: _billNoteController,
              hintText: 'Nhập ghi chú cho hoá đơn',
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              print('Thêm toà nhà được nhấn!');

              final payload = _createBuildingPayload();

              print('Payload gửi đi: $payload');

              context.read<CreateBuildingCubit>().createBuilding(payload);

              getIt<AppRouter>().push(const BuildingScreen());
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

  // Standard label for required fields
  Widget _buildRequiredLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          children: const <TextSpan>[
            TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  // Standard label for optional fields
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  // Custom text field (single line, bottom border)
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black, fontSize: 16),
      decoration: InputDecoration(hintText: hintText),
    );
  }

  // Custom dropdown field
  Widget _buildDropdown({
    required String hintText,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      hint: Text(
        hintText,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
      style: const TextStyle(color: Colors.black, fontSize: 16),
      isExpanded: true,
      items:
          items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
      onChanged: onChanged,
    );
  }

  // Helper for section headers with an optional add button
  Widget _buildSectionHeader(String title, {VoidCallback? onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (onTap != null)
          GestureDetector(
            onTap: onTap,
            child: const Icon(Icons.add_circle, color: Colors.green, size: 28),
          ),
      ],
    );
  }

  Widget _buildServiceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        _buildSectionHeader(
          'Dịch vụ có phí',
          onTap: () async {
            final result = await getIt<AppRouter>().push(const SelectService());

            if (result is List<ServiceModel>) {
              setState(() {
                _selectedServicesForDisplay = result;
              });
            }
          },
        ),
        const SizedBox(height: 20.0),
        if (_selectedServicesForDisplay.isEmpty)
          const Center(
            child: Text(
              'Dữ liệu trống',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 8.0,
            children:
                _selectedServicesForDisplay.map((service) {
                  return SizedBox(
                    width:
                        (MediaQuery.of(context).size.width - 32 - 16 * 2) / 3,
                    child: ServiceCard(service: service),
                  );
                }).toList(),
          ),

        const SizedBox(height: 30),
      ],
    );
  }

  // Helper for displaying manager card
  Widget _buildManagerCard({
    required String name,
    required String phone,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFF0F0F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.grey, size: 24),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  phone,
                  style: const TextStyle(color: Colors.green, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets MỚI cho phần này ---

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

  // Custom Text Field cho Ghi chú/Lưu ý (nhiều dòng, có border)
  Widget _buildNoteTextField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return Container(
      child: TextField(
        controller: controller,
        maxLines: 5,
        style: const TextStyle(color: Colors.black, fontSize: 16),
        decoration: InputDecoration(hintText: hintText),
      ),
    );
  }
}

// Widget hiển thị ô chọn có thể nhấn
Widget _buildSelectableField({
  required String hintText,
  required String? value,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 50, // Chiều cao cố định
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 246, 255, 241),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value ?? hintText,
            style: TextStyle(
              fontSize: 12,
              color: value == null ? Colors.grey.shade600 : Colors.black,
            ),
          ),
          const Icon(Icons.arrow_drop_down, color: Colors.grey),
        ],
      ),
    ),
  );
}
