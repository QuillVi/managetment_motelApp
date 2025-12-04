import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:motelapp/data/models/contract_model.dart';
import 'package:motelapp/data/models/tanent_model.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/home/contract_home/contract_cubit.dart';
import 'package:motelapp/logic/cubits/home/contract_home/contract_state.dart';
import 'package:motelapp/presentation/screens/home/functions/function_contract_home/add_contract/select_tanent_contract.dart';
import 'package:motelapp/router/app_router.dart';

class UpdateContract extends StatefulWidget {
  final int idHopDong;
  const UpdateContract({super.key, required this.idHopDong});

  @override
  State<UpdateContract> createState() => _UpdateContractState();
}

class _UpdateContractState extends State<UpdateContract> {
  // Màu chủ đạo
  final Color primaryColor = const Color(0xFF5CB85C);

  // Danh sách người thuê cục bộ (để thao tác thêm/xóa trên UI)
  List<TenantDetailContractModel> _currentTenants = [];

  // Cờ kiểm tra xem đã nạp dữ liệu từ API vào list cục bộ chưa
  bool _hasInitData = false;

  // Biến lưu ID người đại diện được chọn
  int? _selectedTanentId;
  // Biến lưu tên người đại diện để hiển thị lên UI
  final TextEditingController _nameTanentDisplayController =
      TextEditingController();

  //biến lưu ngày bắt đầu và kết thúc
  DateTime? _tempNgayBatDau;
  DateTime? _tempNgayKetThuc;

  // Biến tạm lưu tiền phòng và tiền cọc (lưu dạng String thô, ví dụ: "3000000")
  String? _tempTienPhong;
  String? _tempTienCoc;

  // Hàm tính khoảng cách tháng giữa 2 ngày
  int _calculateMonthsDifference(DateTime startDate, DateTime endDate) {
    int years = endDate.year - startDate.year;
    int months = endDate.month - startDate.month;
    int diff = years * 12 + months;

    // Nếu ngày kết thúc nhỏ hơn ngày bắt đầu trong tháng (ví dụ 15/2 đến 10/3),
    // có thể coi là chưa đủ 1 tháng tròn. Tuỳ logic app bạn có trừ đi hay không.
    // Ở đây mình để logic đơn giản là tính theo tháng dương lịch.
    if (endDate.day < startDate.day) {
      diff--;
    }
    return diff < 0 ? 0 : diff;
  }

  // Hàm lấy ngày kết thúc (Ưu tiên biến tạm -> Tính từ API)
  DateTime _getEffectiveEndDate(DetailContractModel data) {
    if (_tempNgayKetThuc != null) return _tempNgayKetThuc!;

    // Nếu chưa chọn ngày kết thúc mới, tính từ Ngày bắt đầu (gốc hoặc mới) + thời hạn gốc
    DateTime start = _tempNgayBatDau ?? parseDate(data.ngayBatDau);
    return DateTime(start.year, start.month + data.thoiHan, start.day);
  }

  @override
  void initState() {
    super.initState();
    // Gọi API lấy chi tiết hợp đồng
    context.read<ListContractCubit>().LoadDetailContract(widget.idHopDong);
  }

  // --- HÀM HELPER: Format tiền tệ ---
  String formatCurrency(String? amountStr) {
    if (amountStr == null || amountStr.isEmpty) return "0";

    // --- FIX LỖI 2 SỐ 0 Ở ĐUÔI ---
    // Kiểm tra nếu chuỗi kết thúc bằng ".00" (định dạng SQL) thì cắt bỏ nó đi trước
    if (amountStr.endsWith('.00')) {
      amountStr = amountStr.substring(0, amountStr.length - 3);
    }
    // Hoặc trường hợp tổng quát hơn: Nếu có dấu chấm thập phân, cắt bỏ phần sau dấu chấm
    // (Chỉ áp dụng nếu chuỗi có đúng 1 dấu chấm - tức là dạng số thập phân chuẩn)
    else if (amountStr.contains('.') &&
        amountStr.indexOf('.') == amountStr.lastIndexOf('.')) {
      amountStr = amountStr.split('.')[0];
    }
    // -----------------------------

    // Sau đó mới chạy logic cũ: Xóa các ký tự không phải số (ví dụ dấu chấm hàng nghìn nếu có)
    String cleanStr = amountStr!.replaceAll(RegExp(r'[^0-9]'), '');

    double number = double.tryParse(cleanStr) ?? 0;
    final format = NumberFormat("#,###", "vi_VN");
    return format.format(number);
  }

  // --- HÀM HELPER: Format ngày tháng ---
  // Model trả về String, ta hiển thị lại cho đẹp hoặc giữ nguyên
  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "Chưa cập nhật";
    try {
      // Thử parse nếu format chuẩn ISO (yyyy-MM-dd)
      DateTime date = DateTime.parse(dateString);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      // Nếu API trả về dd-MM-yyyy sẵn hoặc format lạ thì hiển thị nguyên gốc
      return dateString;
    }
  }

  // --- HÀM HELPER: Tính ngày kết thúc dựa vào Ngày bắt đầu + Thời hạn (tháng) ---
  String calculateEndDate(String startStr, int months) {
    try {
      DateTime startDate = DateTime.parse(startStr);
      // Cộng thêm số tháng (ước lượng 30 ngày/tháng hoặc dùng logic DateTime)
      DateTime endDate = DateTime(
        startDate.year,
        startDate.month + months,
        startDate.day,
      );
      return DateFormat('dd-MM-yyyy').format(endDate);
    } catch (e) {
      return "$months tháng"; // Nếu lỗi parse ngày thì chỉ hiện số tháng
    }
  }

  // Hàm helper để parse ngày từ chuỗi API (tránh lỗi null)
  DateTime parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return DateTime.now();
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }

  void _showIOSDatePicker(
    BuildContext context, {
    required DateTime initialDate,
    required Function(DateTime) onConfirm,
  }) {
    // Biến tạm để lưu giá trị khi người dùng cuộn, mặc định là ngày ban đầu
    DateTime tempPickedDate = initialDate;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (BuildContext builder) {
        return SizedBox(
          height: 300, // Chiều cao của bảng chọn
          child: Column(
            children: [
              // --- THANH CÔNG CỤ (Huỷ - Title - Chọn) ---
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Nút Huỷ
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        "Huỷ",
                        style: TextStyle(color: Colors.green, fontSize: 16),
                      ),
                    ),
                    // Tiêu đề
                    const Text(
                      "Chọn thời gian",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    // Nút Chọn
                    GestureDetector(
                      onTap: () {
                        onConfirm(tempPickedDate); // Trả về ngày đã chọn
                        Navigator.pop(context); // Đóng modal
                      },
                      child: const Text(
                        "Chọn",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // --- VÒNG QUAY CHỌN NGÀY (CupertinoDatePicker) ---
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date, // Chỉ chọn ngày tháng năm
                  initialDateTime: initialDate,
                  use24hFormat: true,
                  // Giới hạn năm (tuỳ chọn)
                  minimumDate: DateTime(2000),
                  maximumDate: DateTime(2100),
                  onDateTimeChanged: (DateTime newDate) {
                    tempPickedDate = newDate; // Cập nhật biến tạm khi cuộn
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 1. Khai báo danh sách ảnh đã chọn
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];

  // 1. Hàm chụp ảnh từ Camera (Chỉ chụp 1 tấm mỗi lần)
  Future<void> _takePhoto() async {
    // Kiểm tra giới hạn trước khi mở camera
    if (_selectedImages.length >= 10) {
      _showLimitDialog();
      return;
    }

    try {
      // Sử dụng ImageSource.camera
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80, // Nén nhẹ ảnh cho đỡ nặng
      );

      if (photo != null) {
        setState(() {
          _selectedImages.add(photo);
        });
      }
    } catch (e) {
      debugPrint('Lỗi chụp ảnh: $e');
      // Có thể hiển thị thông báo lỗi nếu cần, ví dụ: người dùng từ chối quyền camera
    }
  }

  // 2. Hàm chọn ảnh từ Thư viện (Sửa tên lại cho rõ ràng)
  Future<void> _pickImagesFromGallery() async {
    if (_selectedImages.length >= 10) {
      _showLimitDialog();
      return;
    }

    try {
      final List<XFile> images = await _picker.pickMultiImage(
        limit: 10 - _selectedImages.length,
      );

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
          if (_selectedImages.length > 10) {
            _selectedImages = _selectedImages.sublist(0, 10);
          }
        });
      }
    } catch (e) {
      debugPrint('Lỗi chọn ảnh thư viện: $e');
    }
  }

  // 3. Hàm xóa ảnh (Giữ nguyên)
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // 4. Hàm hiển thị thông báo khi quá giới hạn (Helper nhỏ)
  void _showLimitDialog() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Thông báo"),
            content: const Text("Bạn chỉ được chọn tối đa 10 ảnh."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Đóng"),
              ),
            ],
          ),
    );
  }

  // 5. HÀM QUAN TRỌNG NHẤT: Hiển thị Bottom Sheet lựa chọn
  void _showImageSourceActionSheet(BuildContext context) {
    if (_selectedImages.length >= 10) {
      _showLimitDialog();
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.green),
                title: const Text('Chụp ảnh mới'),
                onTap: () {
                  Navigator.of(context).pop(); // Đóng bottom sheet trước
                  _takePhoto(); // Gọi hàm chụp ảnh
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('Chọn từ thư viện'),
                onTap: () {
                  Navigator.of(context).pop(); // Đóng bottom sheet trước
                  _pickImagesFromGallery(); // Gọi hàm chọn thư viện
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 6. Hàm hiển thị dialog nhập tiền tệ
  Future<void> _showCurrencyInputDialog(
    BuildContext context, {
    required String title,
    required String currentValue,
    required Function(String) onConfirm,
  }) async {
    // 1. Loại bỏ các ký tự không phải số
    String tempValue = currentValue;

    // FIX LỖI: Nếu chuỗi kết thúc bằng .00 (dạng thập phân SQL), cắt bỏ nó đi trước
    if (tempValue.endsWith('.00')) {
      tempValue = tempValue.substring(0, tempValue.length - 3);
    }

    // Sau đó mới xóa các ký tự lạ (như dấu chấm phân cách hàng nghìn nếu có)
    String cleanValue = tempValue.replaceAll(RegExp(r'[^0-9]'), '');

    final TextEditingController controller = TextEditingController(
      text: cleanValue,
    );

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number, // Chỉ hiện bàn phím số
            decoration: const InputDecoration(
              hintText: "Nhập số tiền",
              suffixText: "VNĐ",
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Huỷ", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                // Trả về giá trị mới và đóng dialog
                onConfirm(controller.text);
                Navigator.pop(context);
              },
              child: const Text(
                "Lưu",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Map<String, dynamic> prepareUpdatePayload(DetailContractModel originalData) {
    // 1. XỬ LÝ NGƯỜI THUÊ (id_nguoidung)
    // Lấy người đầu tiên trong danh sách hiển thị (vì bạn đã xóa cũ thêm mới)
    // Nếu không có thay đổi (list rỗng), lấy từ dữ liệu gốc
    int? tenantId;
    if (_currentTenants.isNotEmpty) {
      tenantId = _currentTenants.first.idNguoiThue;
    } else if (originalData.listNguoiThue.isNotEmpty) {
      tenantId = originalData.listNguoiThue.first.idNguoiThue;
    }

    // 2. XỬ LÝ NGÀY BẮT ĐẦU (ngay_batdau) -> Format yyyy-MM-dd cho SQL
    DateTime startDate = _tempNgayBatDau ?? parseDate(originalData.ngayBatDau);
    String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);

    // 3. XỬ LÝ THỜI HẠN (thoi_han)
    // Tính lại dựa trên ngày kết thúc hiện tại trên UI
    DateTime endDate = _getEffectiveEndDate(originalData);
    int duration = _calculateMonthsDifference(startDate, endDate);

    // 4. XỬ LÝ TIỀN (tien_coc, tien_phong) -> Xóa dấu chấm/phẩy, chuyển thành số
    // Lấy từ biến tạm (nếu user sửa) hoặc lấy gốc
    String rawTienCoc = _tempTienCoc ?? originalData.tienCoc;
    String rawTienPhong = _tempTienPhong ?? originalData.tienPhong;

    // Hàm helper nhỏ để clean tiền
    double parseMoney(String money) {
      if (money.isEmpty) return 0;

      // BƯỚC 1: Xử lý đuôi thập phân .00 từ Database
      if (money.endsWith('.00')) {
        money = money.substring(0, money.length - 3);
      }
      // Hoặc xử lý tổng quát: Nếu có dấu chấm thập phân ở cuối cùng, cắt bỏ phần sau nó
      else if (money.contains('.') &&
          money.lastIndexOf('.') == money.length - 3) {
        // logic này phòng hờ các trường hợp .xx khác
        money = money.split('.')[0];
      }
      String clean = money.replaceAll(RegExp(r'[^0-9]'), '');

      return double.tryParse(clean) ?? 0;
    }

    // 5. XỬ LÝ KỲ THANH TOÁN
    // (Giả sử UI hiển thị "1 tháng" nhưng DB lưu là "Thang")
    // Bạn cần map lại đúng value DB cần. Ở đây mình lấy nguyên gốc nếu không có UI sửa field này.
    String paymentPeriod = "Thang"; // Hoặc lấy từ biến nếu có dropdown chọn

    // --- TẠO PAYLOAD ---
    return {
      "id_nguoidung": tenantId, // Cột: id_nguoidung

      "ngay_batdau": formattedStartDate, // Cột: ngay_batdau (Format SQL)
      "thoi_han": duration, // Cột: thoi_han (Int)

      "tien_coc": parseMoney(rawTienCoc), // Cột: tien_coc (Double/Decimal)
      // Lưu ý: Trong ảnh DB không thấy cột tien_phong, nhưng nếu API cần thì gửi:
      "tien_phong": parseMoney(rawTienPhong),

      "ky_thanhtoan": paymentPeriod, // Cột: ky_thanhtoan
      // Các trường trạng thái giữ nguyên hoặc xử lý riêng nếu cần
      //"trang_thai": "DangHoatDong",
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ListContractCubit, ListContractState>(
      listener: (context, state) {
        if (state.status == ListContractIsActiveStatus.updating) {
          // Hiện loading dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => const Center(child: CircularProgressIndicator()),
          );
        } else if (state.status == ListContractIsActiveStatus.updateSuccess) {
          // Tắt loading
          Navigator.pop(context);
          // Thông báo
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Cập nhật thành công!")));
          // Quay về màn hình trước
          Navigator.pop(context, true);
        } else if (state.status == ListContractIsActiveStatus.updateFailure) {
          // Tắt loading & Hiện lỗi
          Navigator.pop(context);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage ?? "Lỗi")));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: const Text(
            'Chỉnh sửa hợp đồng',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        body: BlocBuilder<ListContractCubit, ListContractState>(
          builder: (context, state) {
            // 1. Loading
            if (state.status == ListContractIsActiveStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            // 2. Error
            if (state.status == ListContractIsActiveStatus.error) {
              return Center(child: Text("Lỗi: ${state.errorMessage}"));
            }
            // 3. Loaded
            final data = state.detailContractModel;
            if (data == null) {
              return const Center(child: Text("Không có dữ liệu"));
            }

            // Nếu chưa khởi tạo dữ liệu cục bộ thì copy từ API sang
            if (!_hasInitData) {
              _currentTenants = List.from(
                data.listNguoiThue,
              ); // Copy list để không ảnh hưởng data gốc
              _hasInitData =
                  true; // Đánh dấu đã lấy xong, các lần build sau sẽ không ghi đè nữa

              // Cập nhật luôn tên đại diện nếu chưa có
              if (_nameTanentDisplayController.text.isEmpty &&
                  _currentTenants.isNotEmpty) {
                _nameTanentDisplayController.text =
                    _currentTenants[0].tenNguoiThue;
              }
            }
            // 1. Xác định các giá trị hiện tại
            DateTime currentStartDate =
                _tempNgayBatDau ?? parseDate(data.ngayBatDau);
            DateTime currentEndDate = _getEffectiveEndDate(data);

            // 2. Tính lại thời hạn
            int currentDuration = _calculateMonthsDifference(
              currentStartDate,
              currentEndDate,
            );

            //Xác định giá trị hiển thị (Ưu tiên biến tạm -> API)
            // Lưu ý: data.tienPhong và data.tienCoc là String từ API
            String displayTienPhong = _tempTienPhong ?? data.tienPhong;
            String displayTienCoc = _tempTienCoc ?? data.tienCoc;
            // --- UI HIỂN THỊ DỮ LIỆU ---
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- PHẦN 1: THÔNG TIN CHUNG ---
                  _buildSectionHeader("Thông tin"),

                  // Người tạo / Chủ nhà
                  _buildInputGroup(
                    label: "Đại diện cho thuê *",
                    value:
                        _nameTanentDisplayController.text.isNotEmpty
                            ? _nameTanentDisplayController.text
                            : "Chưa chọn",
                    hasArrow: true,
                    onTap: () async {
                      // 1. Mở màn hình chọn người
                      final result = await getIt<AppRouter>().push(
                        const SelectTanentContract(),
                      );

                      // 2. Xử lý kết quả trả về
                      if (result != null && result is Map<String, dynamic>) {
                        setState(() {
                          // a. Cập nhật thông tin text hiển thị Đại diện
                          _selectedTanentId = result['idNguoiThue'];
                          _nameTanentDisplayController.text =
                              result['ten'] ?? '';

                          // b. Tạo model người thuê mới từ dữ liệu chọn
                          final newTenant = TenantDetailContractModel(
                            idNguoiThue: result['idNguoiThue'],
                            tenNguoiThue: result['ten'] ?? '',
                            soDienThoai:
                                result['sdt'], // Đảm bảo lấy đúng key SĐT từ màn hình chọn
                          );

                          // --- ĐOẠN QUAN TRỌNG: THAY THẾ DANH SÁCH ---

                          // Bước 1: Xóa sạch danh sách cũ (Xóa Huy đi)
                          _currentTenants.clear();

                          // Bước 2: Thêm người mới vào (Thêm Phạm Thị D)
                          _currentTenants.add(newTenant);
                        });
                      }
                    },
                  ),

                  // Phòng & Tòa nhà (Model: tenPhong, tenToaNha)
                  _buildInputGroup(
                    label: "Phòng",
                    value: "${data.tenPhong} - ${data.tenToaNha}",
                    hasBorder: true,
                  ),

                  // Địa chỉ (Model: diaChiToaNha)
                  if (data.diaChiToaNha.isNotEmpty)
                    _buildInputGroup(
                      label: "Địa chỉ",
                      value: data.diaChiToaNha,
                      hasBorder: true,
                    ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Thời hạn *"),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // --- Ô 1: CHỌN NGÀY BẮT ĐẦU ---
                            Expanded(
                              child: _buildDateBox(
                                DateFormat(
                                  'dd-MM-yyyy',
                                ).format(currentStartDate),
                                onTap: () {
                                  _showIOSDatePicker(
                                    context,
                                    initialDate: currentStartDate,
                                    onConfirm: (pickedDate) {
                                      setState(() {
                                        _tempNgayBatDau = pickedDate;

                                        // Logic phụ: Nếu chọn ngày bắt đầu > ngày kết thúc hiện tại
                                        // thì tự động đẩy ngày kết thúc lên (ví dụ +12 tháng) hoặc giữ nguyên để user tự sửa.
                                        // Ở đây mình giữ nguyên logic tính toán, user sẽ thấy thời hạn bị âm hoặc 0 và tự sửa ngày kết thúc.
                                      });
                                    },
                                  );
                                },
                              ),
                            ),

                            const SizedBox(width: 16),

                            // --- Ô 2: CHỌN NGÀY KẾT THÚC ---
                            Expanded(
                              child: _buildDateBox(
                                DateFormat('dd-MM-yyyy').format(currentEndDate),
                                onTap: () {
                                  _showIOSDatePicker(
                                    context,
                                    initialDate: currentEndDate,
                                    // Giới hạn không cho chọn ngày kết thúc nhỏ hơn ngày bắt đầu
                                    // minimumDate: currentStartDate,
                                    onConfirm: (pickedDate) {
                                      setState(() {
                                        _tempNgayKetThuc = pickedDate;
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 5),

                        // Hiển thị thời hạn được tính toán lại tự động
                        Text(
                          "(Thời hạn: $currentDuration tháng)",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Ngày tính tiền (Model không có field này riêng, dùng ngayBatDau làm mặc định)
                  _buildInputGroup(
                    label: "Ngày bắt đầu tính tiền *",
                    value: formatDate(data.ngayBatDau),
                    isDate: true,
                  ),

                  // Kỳ thanh toán (Model: kyThanhToan - String)
                  _buildInputGroup(
                    label: "Kỳ thanh toán tiền phòng *",
                    value: data.kyThanhToan, // Ví dụ: "1 tháng" hoặc "1"
                    hasArrow: true,
                  ),
                  const SizedBox(height: 10),

                  // --- PHẦN 2: TÀI CHÍNH ---
                  _buildSectionHeader("Tiền phòng"),
                  // Tiền phòng (Model: tienPhong - String)
                  _buildInputGroup(
                    label: "Tiền phòng *",
                    value: formatCurrency(displayTienPhong),
                    hasBorder: true,
                    onTap: () {
                      _showCurrencyInputDialog(
                        context,
                        title: "Nhập tiền phòng",
                        currentValue: displayTienPhong,
                        onConfirm: (newValue) {
                          setState(() {
                            _tempTienPhong =
                                newValue; // Lưu giá trị mới (ví dụ: "4500000")
                          });
                        },
                      );
                    },
                  ),
                  // Tiền cọc (Model: tienCoc - String)
                  _buildInputGroup(
                    label: "Tiền cọc *",
                    value: formatCurrency(displayTienCoc),
                    hasBorder: false,
                    onTap: () {
                      _showCurrencyInputDialog(
                        context,
                        title: "Nhập tiền cọc",
                        currentValue: displayTienCoc,
                        onConfirm: (newValue) {
                          setState(() {
                            _tempTienCoc = newValue;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 10),

                  // --- PHẦN 3: NGƯỜI THUÊ (Model: listNguoiThue) ---
                  _buildSectionHeader("Người thuê", hasAddButton: true),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildTenantList(_currentTenants),
                  ),

                  _buildSectionHeader('Điều khoản'),
                  _buildInputGroup(
                    label: "",
                    value: 'Điều khoản hợp đồng',
                    hasArrow: true,
                  ),
                  const SizedBox(height: 20),
                  // === PHẦN 6: ẢNH HỢP ĐỒNG ===
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Ảnh hợp đồng (${_selectedImages.length}/10 ảnh)', // Hiển thị số lượng
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            // Nút bấm thêm ảnh
                            InkWell(
                              // Nếu chưa đủ 10 ảnh thì hiện bảng chọn, đủ rồi thì thôi
                              onTap:
                                  _selectedImages.length < 10
                                      ? () =>
                                          _showImageSourceActionSheet(context)
                                      : null,
                              child: Icon(
                                Icons.add_circle,
                                // Đổi màu icon thành xám nếu đã đủ 10 ảnh
                                color:
                                    _selectedImages.length < 10
                                        ? Colors.green
                                        : Colors.grey,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Khung hiển thị ảnh
                        Container(
                          padding: const EdgeInsets.all(12),
                          height: 130, // Chiều cao cố định
                          width: double.infinity, // Full chiều ngang
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
                          // Logic hiển thị: Nếu list rỗng -> Hiện chữ "Trống", Nếu có ảnh -> Hiện ListView
                          child:
                              _selectedImages.isEmpty
                                  ? const Center(
                                    child: Text(
                                      'Dữ liệu trống',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  )
                                  : ListView.separated(
                                    scrollDirection:
                                        Axis.horizontal, // Trượt ngang
                                    itemCount: _selectedImages.length,
                                    separatorBuilder:
                                        (ctx, index) =>
                                            const SizedBox(width: 12),
                                    itemBuilder: (context, index) {
                                      return Stack(
                                        children: [
                                          // Ảnh thumbnail
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.file(
                                              File(_selectedImages[index].path),
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          // Nút Xóa (Dấu X ở góc)
                                          Positioned(
                                            right: 0,
                                            top: 0,
                                            child: InkWell(
                                              onTap: () => _removeImage(index),
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  color: Colors.black54,
                                                  shape: BoxShape.circle,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                  // --- BUTTON HÀNH ĐỘNG ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        // Xử lý logic Update tại đây
                        // 1. Lấy data gốc từ State (để phòng hờ các trường null)
                        final originalData =
                            context
                                .read<ListContractCubit>()
                                .state
                                .detailContractModel;

                        if (originalData != null) {
                          // 2. Tạo Payload
                          Map<String, dynamic> payload = prepareUpdatePayload(
                            originalData,
                          );

                          // 3. In ra kiểm tra (Debug)
                          print(
                            "---------------- PAYLOAD UPDATE ----------------",
                          );
                          print(payload);

                          // 4. Gọi Cubit để gửi lên API
                          context.read<ListContractCubit>().updateContract(
                            widget.idHopDong,
                            payload,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Lưu thay đổi",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- WIDGET CON: DANH SÁCH NGƯỜI THUÊ ---
  Widget _buildTenantList(List<TenantDetailContractModel> tenants) {
    if (tenants.isEmpty) {
      return const Center(
        child: Text("Chưa có người thuê", style: TextStyle(color: Colors.grey)),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children:
          tenants.map((tenant) {
            return Stack(
              children: [
                Container(
                  width: 100,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      const CircleAvatar(
                        backgroundColor: Color(0xFFEEEEEE),
                        radius: 25,
                        child: Icon(Icons.person, color: Colors.grey, size: 30),
                      ),
                      const SizedBox(height: 8),
                      // Tên người thuê (Model: tenNguoiThue)
                      Text(
                        tenant.tenNguoiThue,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // SĐT người thuê (Model: soDienThoai)
                      Text(
                        tenant.soDienThoai ?? "Không có SĐT",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.green,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
    );
  }

  // --- CÁC WIDGET STYLE (Giữ nguyên) ---
  Widget _buildSectionHeader(String title, {bool hasAddButton = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return RichText(
      text: TextSpan(
        text: text.replaceAll(" *", ""),
        style: const TextStyle(color: Colors.black87, fontSize: 16),
        children: [
          if (text.contains("*"))
            const TextSpan(text: " *", style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildInputGroup({
    required String label,
    required String value,
    bool hasArrow = false,
    bool isDate = false,
    bool hasBorder = true,
    VoidCallback? onTap, // Tham số nhận hàm callback
  }) {
    // Bọc InkWell ở ngoài cùng để bắt sự kiện click cho toàn bộ hàng
    return InkWell(
      onTap: onTap, // Gọi hàm callback khi nhấn
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel(label),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasArrow)
                  const Icon(Icons.chevron_right, color: Colors.grey),
                if (isDate)
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.grey,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (hasBorder)
              const Divider(height: 12, thickness: 0.5, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDateBox(String date, {VoidCallback? onTap}) {
    return GestureDetector(
      // Hoặc InkWell
      onTap: onTap,
      child: Container(
        // Thêm màu nền hoặc trang trí nếu cần để người dùng biết là bấm được
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(date, style: const TextStyle(fontSize: 16)),
            const Icon(
              Icons.calendar_today_outlined,
              color: Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
