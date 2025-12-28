import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:motelapp/data/models/service_model.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/building/detail_building_cubit.dart';
import 'package:motelapp/logic/cubits/building/detail_building_state.dart';
import 'package:motelapp/presentation/screens/building/list_room_in_building/detail_room_in_building/service_list_widget.dart';
import 'package:motelapp/presentation/screens/building/select_service.dart';
import 'package:motelapp/router/app_router.dart';

class UpdateBuilding extends StatefulWidget {
  final int buildingId;
  const UpdateBuilding({super.key, required this.buildingId});

  @override
  State<UpdateBuilding> createState() => _UpdateBuildingState();
}

class _UpdateBuildingState extends State<UpdateBuilding> {
  // 1. KHAI BÁO CÁC CONTROLLER ĐỂ QUẢN LÝ NHẬP LIỆU
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _floorsController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController(
    text: "Hồ Chí Minh",
  ); // Mặc định
  final TextEditingController _districtController = TextEditingController(
    text: "Quận 1",
  ); // Mặc định

  final TextEditingController _openTimeController = TextEditingController();
  final TextEditingController _closeTimeController = TextEditingController();
  final TextEditingController _billDateController = TextEditingController();
  final TextEditingController _paymentAlertController = TextEditingController();
  final TextEditingController _paymentDateController = TextEditingController();
  final TextEditingController _deadlineController =
      TextEditingController(); // Field phụ (Hạn nộp)

  final TextEditingController _noteTenantController = TextEditingController();
  final TextEditingController _noteBillController = TextEditingController();

  // Biến cờ để kiểm tra xem đã gán dữ liệu lần đầu chưa
  bool _isDataLoaded = false;

  bool _isSubmitting = false;

  // --- 1. BIẾN DỮ LIỆU ĐỊA CHÍNH ---
  List<dynamic> _provinces = []; // Danh sách Tỉnh/TP tải từ API
  List<dynamic> _districts = []; // Danh sách Quận/Huyện tải từ API
  dynamic _selectedProvince; // Lưu đối tượng Tỉnh đang chọn để lấy code

  // Danh sách dịch vụ đã chọn
  List<ServiceModel> _selectedServicesForDisplay = [];

  // 1. Danh sách TỔNG các tiện ích (Bạn có thể thêm bớt tùy ý ở đây)
  // Đây là nguồn dữ liệu để vẽ ra các item
  final List<String> _allUtilities = [
    "Chỗ để xe",
    "Thang máy",
    "Wifi",
    "Camera an ninh",
    "Bảo vệ 24/7",
    "Hồ bơi",
    "Sân thượng",
    "Tự do giờ giấc",
    "Vệ sinh hành lang",
    "Máy giặt chung",
    "Khóa vân tay",
  ];

  // 2. Danh sách tiện ích ĐANG ĐƯỢC CHỌN (Sẽ hứng dữ liệu từ API)
  List<String> _selectedUtilities = [];

  @override
  void initState() {
    super.initState();
    context.read<DetailBuildingCubit>().loadBuildingDetail(widget.buildingId);

    // Gọi API lấy danh sách Tỉnh ngay khi vào màn hình
    _fetchProvinces();
  }

  // --- 2. HÀM GỌI API ---

  // Lấy danh sách toàn bộ Tỉnh/Thành phố và sắp xếp ưu tiên
  Future<void> _fetchProvinces() async {
    try {
      final response = await http.get(
        Uri.parse('https://provinces.open-api.vn/api/p/'),
      );
      if (response.statusCode == 200) {
        // 1. Decode dữ liệu thô
        List<dynamic> rawList = json.decode(utf8.decode(response.bodyBytes));

        // 2. Tìm TP.HCM và Hà Nội trong danh sách
        // Lưu ý: Tên trong API thường là "Thành phố Hồ Chí Minh" và "Thành phố Hà Nội"
        final hcm = rawList.firstWhere(
          (p) => p['name'].toString().contains("Hồ Chí Minh"),
          orElse: () => null,
        );
        final hanoi = rawList.firstWhere(
          (p) => p['name'].toString().contains("Hà Nội"),
          orElse: () => null,
        );

        // 3. Xóa chúng khỏi danh sách gốc để tránh trùng lặp
        rawList.removeWhere(
          (p) =>
              p['name'].toString().contains("Hồ Chí Minh") ||
              p['name'].toString().contains("Hà Nội"),
        );

        // 4. Chèn lại vào đầu danh sách theo thứ tự mong muốn
        // Muốn cái nào đứng đầu tiên thì insert sau cùng vào vị trí 0,
        // HOẶC insert lần lượt:

        if (hanoi != null) {
          rawList.insert(
            0,
            hanoi,
          ); // Hà Nội xuống thứ 2 (hoặc 1 nếu chèn HCM sau)
        }
        if (hcm != null) {
          rawList.insert(
            0,
            hcm,
          ); // HCM chèn vào 0 -> HCM đứng đầu, Hà Nội bị đẩy xuống thứ 2
        }

        // 5. Cập nhật UI
        setState(() {
          _provinces = rawList;
        });
      }
    } catch (e) {
      print("Lỗi tải Tỉnh/TP: $e");
    }
  }

  // Lấy danh sách Quận/Huyện dựa theo mã Tỉnh (province_code)
  Future<void> _fetchDistricts(int provinceCode) async {
    try {
      final response = await http.get(
        Uri.parse('https://provinces.open-api.vn/api/p/$provinceCode?depth=2'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _districts =
              data['districts']; // API trả về key 'districts' chứa mảng
        });
      }
    } catch (e) {
      print("Lỗi tải Quận/Huyện: $e");
    }
  }

  // --- 3. WIDGET PICKER STYLE IOS ---
  // Hàm này hiển thị danh sách dạng cuộn
  void _showIOSPicker(
    BuildContext context, {
    required List<dynamic> items, // Nhận vào List dynamic (object từ API)
    required Function(int) onSelectedItemChanged, // Trả về index đã chọn
  }) {
    showCupertinoModalPopup(
      context: context,
      builder:
          (_) => Container(
            height: 250,
            color: Colors.white,
            child: Column(
              children: [
                // Thanh công cụ: Nút Xong
                SizedBox(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CupertinoButton(
                        child: const Text(
                          "Xong",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                // Phần cuộn chọn
                Expanded(
                  child: CupertinoPicker(
                    backgroundColor: Colors.white,
                    itemExtent: 40, // Chiều cao mỗi dòng
                    scrollController: FixedExtentScrollController(
                      initialItem: 0,
                    ),
                    onSelectedItemChanged: (index) {
                      onSelectedItemChanged(index);
                    },
                    children:
                        items.map((item) {
                          return Center(
                            child: Text(
                              item['name'], // Hiển thị tên (ví dụ: "Thành phố Hà Nội")
                              style: const TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // --- WIDGET INPUT DẠNG CHỌN (Read-only) ---
  Widget _buildPickerField(
    String label,
    TextEditingController controller,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      controller.text.isEmpty ? "Chọn..." : controller.text,
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            controller.text.isEmpty
                                ? Colors.grey
                                : Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.grey,
                  ), // Icon mũi tên cho đẹp
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Giải phóng bộ nhớ
    _nameController.dispose();
    _floorsController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _openTimeController.dispose();
    _closeTimeController.dispose();
    _billDateController.dispose();
    _paymentAlertController.dispose();
    _paymentDateController.dispose();
    _deadlineController.dispose();
    _noteTenantController.dispose();
    _noteBillController.dispose();
    super.dispose();
  }

  void _onUpdatePressed() {
    // 1. Validate cơ bản (Giữ nguyên)
    if (_nameController.text.isEmpty || _floorsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập đầy đủ thông tin bắt buộc (*)"),
        ),
      );
      return;
    }

    // Đánh dấu là đang thực hiện submit form
    setState(() {
      _isSubmitting = true; // <--- 2. BẬT CỜ SUBMIT
    });

    // 2. Xử lý dữ liệu tiền tệ (Giữ nguyên)
    String rawPrice = _priceController.text.replaceAll('.', '');
    double priceValue = double.tryParse(rawPrice) ?? 0;

    // 3. Xử lý Tiện ích (Giữ nguyên)
    String utilitiesString = _selectedUtilities.join(', ');

    // --- SỬA Ở ĐÂY ---
    // 4. Xử lý Dịch vụ: Chỉ lấy ID và nối thành chuỗi "1,2,3"
    String servicesIdsString = _selectedServicesForDisplay
        .map((service) => service.idDichVu.toString()) // Lấy từng ID ra
        .join(','); // Nối lại bằng dấu phẩy
    // ----------------

    // 5. Đóng gói dữ liệu
    final updateData = {
      "id_toanha": widget.buildingId,
      "ten_toanha": _nameController.text,
      "so_tang": int.tryParse(_floorsController.text) ?? 1,
      "phi_thue_nha": priceValue,

      // Địa chỉ (Gộp lại thành 1 chuỗi đầy đủ nếu API yêu cầu, hoặc gửi rời tùy API)
      // Theo logic cũ bạn muốn tách, nhưng thường API update sẽ nhận 1 chuỗi full address hoặc các trường riêng.
      // Ở đây mình gửi theo format mà API Nodejs bạn cung cấp (req.body.address)
      "address":
          "${_addressController.text}, ${_districtController.text}, ${_cityController.text}",

      // Nếu API backend của bạn có hỗ trợ nhận riêng tỉnh/huyện thì mở comment dòng dưới:
      // "tinh_tp": _cityController.text,
      // "quan_huyen": _districtController.text,

      // Thời gian
      "mo_cua": _openTimeController.text,
      "dong_cua": _closeTimeController.text,
      "ngay_chot_tien": _billDateController.text,
      "chuyen_bao_truoc": _paymentAlertController.text,
      "thoi_gian_nop_tien": _paymentDateController.text,

      // Ghi chú
      "mo_ta": _descController.text,
      "luu_y_cho_nguoi_thue": _noteTenantController.text,
      "ghi_chu_hoa_don": _noteBillController.text,

      // Dữ liệu phức tạp
      "tien_ich_toanha": utilitiesString, // Ví dụ: "Wifi, Thang máy"
      // --- SỬA KEY Ở ĐÂY CHO KHỚP BACKEND ---
      "services":
          servicesIdsString, // Ví dụ: "1,5,8" (Backend Nodejs của bạn đọc field 'services')
    };

    // 6. Debug
    print("----- DỮ LIỆU CHUẨN BỊ GỬI UPDATE -----");
    print(updateData);

    // 7. Gọi API
    context.read<DetailBuildingCubit>().updateBuilding(
      widget.buildingId,
      updateData,
    );
  }

  // Hàm helper format tiền (để hiển thị)
  String _formatMoney(String amount) {
    try {
      double value = double.parse(amount);
      return value
          .toStringAsFixed(0)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          );
    } catch (e) {
      return amount;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // ... giữ nguyên code AppBar
        title: const Text(
          "Cập nhật",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Lệnh đóng màn hình hiện tại
          },
        ),
        centerTitle: true,
      ),

      // SỬ DỤNG BLOC CONSUMER: Vừa lắng nghe (Logic) vừa vẽ (UI)
      body: BlocConsumer<DetailBuildingCubit, DetailBuildingState>(
        // PHẦN LẮNG NGHE: Để gán dữ liệu vào Controller
        listener: (context, state) {
          if (state.status == DetailBuildingStatus.success &&
              state.data != null &&
              !_isDataLoaded) {
            final b = state.data!;

            // --- GÁN DỮ LIỆU TỪ API VÀO CONTROLLER ---
            _nameController.text = b.tentoanha ?? "";
            _floorsController.text = b.soTang?.toString() ?? "";

            // Xử lý giá tiền: Chuyển double thành string integer (12000000) để dễ sửa
            if (b.phiThueNha != null) {
              _priceController.text = _formatMoney(b.phiThueNha!.toString());
            }

            _descController.text = b.moTa ?? "";
            // --- XỬ LÝ TÁCH ĐỊA CHỈ (MỚI) ---
            if (b.diachi_toanha != null && b.diachi_toanha!.isNotEmpty) {
              String fullAddress = b.diachi_toanha!;
              List<String> parts = fullAddress.split(',');

              // Logic: Chuỗi chuẩn thường có ít nhất 3 phần: [Đường, Quận, Thành phố]
              if (parts.length >= 3) {
                // 1. Lấy Thành phố (Phần cuối cùng)
                String city = parts.last.trim();

                // 2. Lấy Quận/Huyện (Phần kế cuối)
                String district = parts[parts.length - 2].trim();

                // 3. Lấy Địa chỉ đường (Gộp các phần còn lại phía trước)
                // Dùng sublist từ 0 đến length-2 để lấy hết phần đầu
                String street =
                    parts.sublist(0, parts.length - 2).join(',').trim();

                // 4. Gán vào Controller
                _addressController.text = street;
                _districtController.text = district;
                _cityController.text = city;

                // 5. [QUAN TRỌNG] LOGIC ĐỒNG BỘ API:
                // Tự động tìm code của Tỉnh/TP để load danh sách Quận/Huyện tương ứng
                // Để khi người dùng bấm vào ô Quận/Huyện, nó hiện đúng danh sách của TP đó.
                if (_provinces.isNotEmpty) {
                  // Tìm object tỉnh trong danh sách API khớp với tên thành phố lấy được
                  final matchProvince = _provinces.firstWhere(
                    (p) =>
                        // So sánh tương đối vì API có thể có chữ "Thành phố" hoặc không
                        p['name'].toString().toLowerCase().contains(
                          city.toLowerCase(),
                        ) ||
                        city.toLowerCase().contains(
                          p['name'].toString().toLowerCase(),
                        ),
                    orElse: () => null,
                  );

                  if (matchProvince != null) {
                    _selectedProvince = matchProvince; // Lưu lại object tỉnh
                    _fetchDistricts(
                      matchProvince['code'],
                    ); // Gọi API lấy quận huyện ngay lập tức
                  }
                }
              } else {
                // Trường hợp dữ liệu không đúng chuẩn (không đủ dấu phẩy), gán tất cả vào ô địa chỉ
                _addressController.text = fullAddress;
              }
            } else {
              _addressController.text = "";
            }
            _openTimeController.text = b.moCua ?? "";
            _closeTimeController.text = b.dongCua ?? "";
            _billDateController.text = b.ngayChotTien ?? "";
            _paymentAlertController.text = b.chuyenBaoTruoc ?? "";
            _paymentDateController.text = b.thoiGianNopTien ?? "";

            _noteTenantController.text = b.luu_y_cho_nguoi_thue ?? "";
            _noteBillController.text = b.ghi_chu_hoa_don ?? "";

            // Để khi vào màn hình Update, người dùng thấy các dịch vụ đã có sẵn
            if (b.dichvu != null) {
              _selectedServicesForDisplay = List.from(b.dichvu!);
            }

            // --- XỬ LÝ TIỆN ÍCH ---
            if (b.tien_ich_toanha != null) {
              // 1. Làm sạch chuỗi và tách thành List
              // Ví dụ API trả về: "[Wifi, Thang máy]"
              List<String> apiList =
                  b.tien_ich_toanha
                      .toString()
                      .replaceAll('[', '')
                      .replaceAll(']', '')
                      .replaceAll('"', '')
                      .split(',')
                      .map((e) => e.trim()) // Xóa khoảng trắng thừa
                      .where((e) => e.isNotEmpty)
                      .toList();

              setState(() {
                // Gán vào biến đang chọn
                _selectedUtilities = apiList;

                // 2. [QUAN TRỌNG] MERGE DỮ LIỆU:
                // Nếu API có tiện ích nào lạ không nằm trong danh sách tổng
                // Ta thêm nó vào danh sách tổng để nó hiện ra (tránh bị ẩn mất)
                for (var item in apiList) {
                  if (!_allUtilities.contains(item)) {
                    _allUtilities.add(item);
                  }
                }
              });
            }

            // Đánh dấu đã gán xong để không gán lại khi rebuild
            setState(() {
              _isDataLoaded = true;
            });
          }

          // Nếu thành công VÀ đang trong quá trình submit
          if (state.status == DetailBuildingStatus.success && _isSubmitting) {
            // Tắt cờ submit
            setState(() {
              _isSubmitting = false;
            });

            // Hiển thị thông báo
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Cập nhật thành công!"),
                backgroundColor: Colors.green,
              ),
            );

            // Đợi 1 chút cho người dùng thấy thông báo rồi thoát (optional)
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                // Trả về 'true' để màn hình trước biết là có update
                Navigator.pop(context, true);
              }
            });
          }

          // Nếu thất bại
          if (state.status == DetailBuildingStatus.failure && _isSubmitting) {
            setState(() {
              _isSubmitting = false;
            }); // Tắt cờ để cho phép bấm lại
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Lỗi: ${state.error}"),
                backgroundColor: Colors.red,
              ),
            );
          }
        },

        // PHẦN VẼ GIAO DIỆN
        builder: (context, state) {
          if (state.status == DetailBuildingStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == DetailBuildingStatus.failure) {
            return Center(child: Text("Lỗi: ${state.error}"));
          }

          // Khi có dữ liệu, hiển thị form
          if (state.status == DetailBuildingStatus.success &&
              state.data != null) {
            // Lấy object để dùng cho các phần hiển thị không phải input (như list dịch vụ, tiện ích)
            final building = state.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- CÁC INPUT ĐÃ CÓ DỮ LIỆU ---
                  _buildTextField("Tên toà nhà *", _nameController),
                  _buildTextField(
                    "Số tầng *",
                    _floorsController,
                    isNumber: true,
                  ),
                  _buildTextField(
                    "Chi phí thuê nhà",
                    _priceController,
                    isNumber: true,
                  ),

                  _buildLabel("Mô tả *"),
                  const SizedBox(height: 8),
                  _buildTextAreaBox(_descController),
                  const SizedBox(height: 20),

                  _buildTextField("Địa chỉ *", _addressController),

                  Row(
                    children: [
                      // CỘT 1: TỈNH / THÀNH PHỐ
                      Expanded(
                        child: _buildPickerField(
                          "Tỉnh/Thành phố *",
                          _cityController,
                          () {
                            // Khi bấm chọn Tỉnh
                            if (_provinces.isEmpty) {
                              // Nếu chưa tải xong thì báo hoặc tải lại
                              _fetchProvinces();
                              return;
                            }

                            // Mặc định chọn cái đầu tiên nếu người dùng mở lên mà không cuộn gì cả
                            // (Logic này tuỳ chọn, ở đây mình xử lý trong onSelectedItemChanged)

                            _showIOSPicker(
                              context,
                              items: _provinces,
                              onSelectedItemChanged: (index) {
                                final selected = _provinces[index];
                                setState(() {
                                  _cityController.text =
                                      selected['name']; // Gán tên vào ô input
                                  _selectedProvince =
                                      selected; // Lưu object để lấy code

                                  // RESET QUẬN HUYỆN
                                  _districtController.text = "";
                                  _districts = [];
                                });
                                // Gọi API lấy huyện của tỉnh vừa chọn
                                _fetchDistricts(selected['code']);
                              },
                            );
                          },
                        ),
                      ),

                      const SizedBox(width: 16),

                      // CỘT 2: QUẬN / HUYỆN
                      Expanded(
                        child: _buildPickerField(
                          "Quận/Huyện *",
                          _districtController,
                          () {
                            // Kiểm tra: Phải chọn Tỉnh trước
                            if (_districts.isEmpty) {
                              if (_cityController.text.isNotEmpty) {
                                // Trường hợp đã có tên Tỉnh (do load từ DB) nhưng chưa fetch Huyện
                                // Ta báo người dùng chọn lại Tỉnh để đồng bộ
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Vui lòng chọn lại Tỉnh/TP để cập nhật danh sách",
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Vui lòng chọn Tỉnh/Thành phố trước",
                                    ),
                                  ),
                                );
                              }
                              return;
                            }

                            _showIOSPicker(
                              context,
                              items: _districts,
                              onSelectedItemChanged: (index) {
                                final selected = _districts[index];
                                setState(() {
                                  _districtController.text = selected['name'];
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const Divider(
                    height: 30,
                    thickness: 1,
                    color: Color(0xFFEEEEEE),
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField("Mở cửa", _openTimeController),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          "Đóng cửa",
                          _closeTimeController,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          "Ngày chốt tiền *",
                          _billDateController,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          "Báo chuyển trước *",
                          _paymentAlertController,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          "Thời gian nộp tiền phòng *",
                          _paymentDateController,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- PHẦN QUẢN LÝ (Chỉ hiển thị, không dùng Controller) ---
                  _buildSection("Quản lý toà nhà"),
                  const SizedBox(height: 12),
                  if (building.quanly != null)
                    Row(
                      children: [
                        _buildManagerCard(
                          building.quanly!.ten ?? "",
                          building.quanly!.sdt ?? "",
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // --- PHẦN DỊCH VỤ (Hiển thị list từ API) ---
                  _buildServiceSection(context),

                  // --- PHẦN TIỆN ÍCH ---
                  const SizedBox(height: 30),
                  const Text(
                    "Tiện ích tòa nhà",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    // Duyệt qua danh sách TỔNG để vẽ tất cả các item
                    children:
                        _allUtilities.map((utilName) {
                          // LOGIC KIỂM TRA MÀU SẮC:
                          // Nếu tên này nằm trong list đã chọn -> True (Xanh)
                          final isSelected = _selectedUtilities.contains(
                            utilName,
                          );

                          return InkWell(
                            // Cho phép bấm vào để chọn/bỏ chọn
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedUtilities.remove(
                                    utilName,
                                  ); // Đang xanh -> Xóa -> Thành xám
                                } else {
                                  _selectedUtilities.add(
                                    utilName,
                                  ); // Đang xám -> Thêm -> Thành xanh
                                }
                              });
                              print(
                                "Các tiện ích đang chọn: $_selectedUtilities",
                              );
                            },
                            // Tái sử dụng widget chip cũ của bạn
                            // Tham số thứ 2 (isSelected) sẽ quyết định màu Xanh hay Xám
                            child: _buildChip(utilName, isSelected),
                          );
                        }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // --- GHI CHÚ (INPUT) ---
                  _buildLabel("Lưu ý của toà nhà"),
                  const SizedBox(height: 8),
                  _buildTextAreaBox(_noteTenantController),

                  const SizedBox(height: 20),

                  _buildLabel("Ghi chú cho hoá đơn"),
                  const SizedBox(height: 8),
                  _buildTextAreaBox(_noteBillController),

                  const SizedBox(height: 30),

                  // NÚT CẬP NHẬT
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _onUpdatePressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Cập nhật",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          }
          return const Center(child: Text("Không có dữ liệu"));
        },
      ),
    );
  }

  // --- WIDGET HELPERS ĐÃ SỬA ĐỔI ---

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isLabel = true,
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLabel) _buildLabel(label),
          if (isLabel) const SizedBox(height: 8),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
            ),
            child: TextFormField(
              controller: controller,
              keyboardType:
                  isNumber ? TextInputType.number : TextInputType.text,
              style: const TextStyle(fontSize: 16, color: Colors.black87),

              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),

                // 2. Cấu hình nền trắng tuyệt đối
                filled: true,
                fillColor: Colors.white,
                hoverColor:
                    Colors.transparent, // Bỏ màu khi rê chuột (web/desktop)
                focusColor: Colors.white, // Bỏ màu nền khi focus
                // 3. Tắt TOÀN BỘ viền của Input (kể cả khi focus)
                border: InputBorder.none,
                focusedBorder:
                    InputBorder.none, // Quan trọng: Tắt viền xanh khi focus
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,

                hintText: "Nhập dữ liệu...",
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //  Nhận vào TextEditingController cho Text Area
  Widget _buildTextAreaBox(TextEditingController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, // 1. Set nền trắng cho Container
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: 4,
        style: const TextStyle(fontSize: 16, color: Colors.black87),

        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.zero,

          // 3. Cấu hình nền và tắt hiệu ứng focus mặc định
          filled: true,
          fillColor: Colors.white,
          hoverColor: Colors.transparent,
          focusColor: Colors.white,

          // 4. Tắt toàn bộ viền của Input (vì Container bên ngoài đã có viền rồi)
          border: InputBorder.none,
          focusedBorder:
              InputBorder.none, // Quan trọng: Tắt viền xanh khi focus
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  // ... (Giữ nguyên các widget _buildLabel, _buildManagerCard, _buildServiceCard, _buildChip)
  Widget _buildLabel(String text) {
    bool isRequired = text.contains("*");
    return RichText(
      text: TextSpan(
        text: text.replaceAll("*", ""),
        style: const TextStyle(color: Colors.black54, fontSize: 14),
        children: [
          if (isRequired)
            const TextSpan(text: " *", style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildServiceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header có nút bấm để chuyển màn hình
        _buildSectionHeader(
          'Dịch vụ có phí',
          onTap: () async {
            // Điều hướng sang màn hình chọn dịch vụ
            // Lưu ý: Bạn nên truyền danh sách hiện tại (_selectedServicesForDisplay)
            // sang màn hình SelectService để nó tick sẵn các ô đã chọn.
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SelectService(),
              ), // Giả sử bạn dùng Navigator
              // Hoặc dùng: await getIt<AppRouter>().push(const SelectService());
            );

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
                  // Tính toán kích thước để chia 3 cột (như logic code bạn gửi)
                  return SizedBox(
                    width:
                        (MediaQuery.of(context).size.width - 32 - 12 * 2) /
                        3, // 32 là padding màn hình, 12*2 là spacing
                    child: ServiceCard(
                      service: service,
                    ), // Widget hiển thị từng ô dịch vụ
                  );
                }).toList(),
          ),

        const SizedBox(height: 30),
      ],
    );
  }

  // Widget Header có nút bấm (Chỉnh lại từ _buildSectionHeaderWithAction cũ)
  Widget _buildSectionHeader(String title, {required VoidCallback onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }
}

Widget _buildManagerCard(String name, String phone) {
  return Container(
    width: 100,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      border: Border.all(color: Colors.grey.shade100),
    ),
    child: Column(
      children: [
        const CircleAvatar(
          backgroundColor: Color(0xFFE0E0E0),
          radius: 20,
          child: Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          phone,
          style: const TextStyle(fontSize: 12, color: Color(0xFF4CAF50)),
        ),
      ],
    ),
  );
}

Widget _buildServiceCard(
  String name,
  String price,
  String iconFile, {
  bool isPaid = false,
}) {
  const String assetPath = 'lib/assets/icons/';
  return Stack(
    children: [
      Container(
        width: 100,
        margin: const EdgeInsets.only(top: 6, right: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Image.asset(
              '$assetPath$iconFile',
              width: 32,
              height: 32,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.image_not_supported,
                  size: 32,
                  color: Colors.grey,
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          ],
        ),
      ),
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.remove, color: Colors.white, size: 14),
        ),
      ),
    ],
  );
}

Widget _buildChip(String label, bool isSelected) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFF9E9E9E),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: const TextStyle(color: Colors.white, fontSize: 14),
    ),
  );
}

// Widget tạo tiêu đề section
Widget _buildSection(String title) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ],
  );
}
