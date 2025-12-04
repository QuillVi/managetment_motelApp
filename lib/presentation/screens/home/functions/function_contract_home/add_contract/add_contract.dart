import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/home/contract_home/contract_cubit.dart';
import 'package:motelapp/logic/cubits/home/contract_home/contract_state.dart';
import 'package:motelapp/presentation/screens/home/functions/function_contract_home/add_contract/select_room_contract.dart';
import 'package:motelapp/presentation/screens/home/functions/function_contract_home/add_contract/select_tanent_contract.dart';

import 'package:motelapp/router/app_router.dart';

class AddContract extends StatefulWidget {
  const AddContract({super.key});

  @override
  State<AddContract> createState() => _AddContractState();
}

class _AddContractState extends State<AddContract> {
  final TextEditingController _roomPriceController = TextEditingController();
  final TextEditingController _depositController = TextEditingController();

  // Để hiển thị tên ngươi đại diện đã chọn lên UI
  int? _selectedTanentId;
  int? _selectedRoomId;

  String? _selectedRoomName;
  final TextEditingController _nameTanentDisplayController =
      TextEditingController();

  final TextEditingController _roomDisplayController = TextEditingController();

  // Khởi tạo ngày bắt đầu là ngày hiện tại
  DateTime _fromDate = DateTime.now();

  // khởi tạo biến lưu dữ liệu thời hạn thuê
  String _selectedDurationCycle = '1 tháng';

  void _showPaymentDurationCyclePicker() {
    // Tìm vị trí (index) của giá trị hiện tại để cuộn picker tới đó ngay khi mở
    int initialIndex = _paymentCycles.indexOf(_selectedDurationCycle);
    // Biến tạm để lưu giá trị khi người dùng cuộn (chưa bấm Chọn)
    int tempIndex = initialIndex;

    showModalBottomSheet(
      context: context,
      // Cho phép modal đẩy lên cao tùy ý (cần thiết nếu muốn custom height)
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: 300, // Chiều cao của bảng chọn
          color: Colors.white, // Màu nền trắng
          child: Column(
            children: [
              // --- PHẦN THANH TIÊU ĐỀ (Huỷ - Title - Chọn) ---
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Nút Huỷ
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Huỷ',
                        style: TextStyle(color: Colors.green, fontSize: 16),
                      ),
                    ),
                    // Tiêu đề giữa
                    const Text(
                      'Chọn kỳ thanh toán',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // Nút Chọn
                    GestureDetector(
                      onTap: () {
                        // Khi bấm Chọn: Cập nhật biến chính và đóng modal
                        setState(() {
                          _selectedDurationCycle = _paymentCycles[tempIndex];
                        });
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Chọn',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- PHẦN CUỘN CHỌN (CupertinoPicker) ---
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: initialIndex,
                  ),
                  itemExtent: 40, // Chiều cao mỗi dòng chọn
                  onSelectedItemChanged: (int index) {
                    // Chỉ cập nhật biến tạm, chưa cập nhật vào UI chính
                    tempIndex = index;
                  },
                  children:
                      _paymentCycles.map((String item) {
                        return Center(
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // khời tạo biến lưu dữ liệu kỳ hạn thanh toán
  DateTime _paymentTermDate = DateTime.now();

  String _getTodayFormatted() {
    final now = DateTime.now();
    // padLeft(2, '0') để đảm bảo ngày/tháng luôn có 2 chữ số (ví dụ 05 thay vì 5)
    return '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
  }

  // 1. Tạo danh sách kỳ hạn (Ví dụ từ 1 đến 12 tháng)
  final List<String> _paymentCycles = List.generate(
    12,
    (index) => '${index + 1} tháng',
  );

  // 2. Biến lưu giá trị đang chọn (Mặc định là 'Tháng')
  String _selectedPaymentCycle = 'Tháng';

  void _showPaymentCyclePicker() {
    // Tìm vị trí (index) của giá trị hiện tại để cuộn picker tới đó ngay khi mở
    int initialIndex = _paymentCycles.indexOf(_selectedPaymentCycle);
    // Biến tạm để lưu giá trị khi người dùng cuộn (chưa bấm Chọn)
    int tempIndex = initialIndex;

    showModalBottomSheet(
      context: context,
      // Cho phép modal đẩy lên cao tùy ý (cần thiết nếu muốn custom height)
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: 300, // Chiều cao của bảng chọn
          color: Colors.white, // Màu nền trắng
          child: Column(
            children: [
              // --- PHẦN THANH TIÊU ĐỀ (Huỷ - Title - Chọn) ---
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Nút Huỷ
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Huỷ',
                        style: TextStyle(color: Colors.green, fontSize: 16),
                      ),
                    ),
                    // Tiêu đề giữa
                    const Text(
                      'Chọn kỳ thanh toán',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // Nút Chọn
                    GestureDetector(
                      onTap: () {
                        // Khi bấm Chọn: Cập nhật biến chính và đóng modal
                        setState(() {
                          _selectedPaymentCycle = _paymentCycles[tempIndex];
                        });
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Chọn',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- PHẦN CUỘN CHỌN (CupertinoPicker) ---
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: initialIndex,
                  ),
                  itemExtent: 40, // Chiều cao mỗi dòng chọn
                  onSelectedItemChanged: (int index) {
                    // Chỉ cập nhật biến tạm, chưa cập nhật vào UI chính
                    tempIndex = index;
                  },
                  children:
                      _paymentCycles.map((String item) {
                        return Center(
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                        );
                      }).toList(),
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

  int _extractNumber(String value) {
    // Thay thế mọi ký tự không phải số bằng rỗng, sau đó ép kiểu
    String numberString = value.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(numberString) ?? 1; // Mặc định là 1 nếu lỗi
  }

  void _onSubmitCreateContract() {
    // 1. Validate: Kiểm tra bắt buộc
    if (_selectedTanentId == null || _selectedRoomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn Người thuê và Phòng!')),
      );
      return;
    }

    // 2. Tạo Payload khớp với Database `hopdong`
    final Map<String, dynamic> payload = {
      // Cột: id_nguoidung
      'id_nguoidung': _selectedTanentId,

      // Cột: id_phong
      'id_phong': _selectedRoomId,

      // Cột: ngay_batdau (Format chuẩn: YYYY-MM-DD)
      'ngay_batdau': DateFormat('yyyy-MM-dd').format(_fromDate),

      // Cột: thoi_han (Lấy số từ chuỗi "12 tháng" -> 12)
      'thoi_han': _extractNumber(_selectedDurationCycle),

      // Cột: ky_thanh_toan
      'ky_thanhtoan': _selectedPaymentCycle,

      // Cột: tien_phong
      'tien_phong': int.tryParse(_roomPriceController.text) ?? 0,
      // Cột: tien_coc
      'tien_coc': int.tryParse(_depositController.text) ?? 0,
    };

    // 3. Log kiểm tra
    print('--- JSON GỬI ĐI (Khớp Database) ---');
    print(payload);

    // TODO: Gọi API Create Contract tại đây
    context.read<ListContractCubit>().createContract(payload);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ListContractCubit, ListContractState>(
      listener: (context, state) {
        switch (state.status) {
          // --- TRƯỜNG HỢP 1: ĐANG TẠO (HIỆN LOADING) ---
          case ListContractIsActiveStatus.creating:
            showDialog(
              context: context,
              barrierDismissible: false,
              builder:
                  (context) => const Center(child: CircularProgressIndicator()),
            );
            break;

          // --- TRƯỜNG HỢP 2: THÀNH CÔNG ---
          case ListContractIsActiveStatus.createSuccess:
            // Tắt Loading Dialog
            Navigator.of(context).pop();

            // Hiện thông báo
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tạo hợp đồng thành công!'),
                backgroundColor: Colors.green,
              ),
            );

            // Quay lại màn hình trước và báo hiệu reload (true)
            Navigator.pop(context, true);
            break;

          // --- TRƯỜNG HỢP 3: THẤT BẠI ---
          case ListContractIsActiveStatus.createFailure:
            // Tắt Loading Dialog
            Navigator.of(context).pop();

            // Hiện lỗi
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Tạo thất bại'),
                backgroundColor: Colors.red,
              ),
            );
            break;

          default:
            // Các trạng thái khác (loaded, loading danh sách...) không làm gì ở màn hình này
            break;
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
            'Tạo hợp đồng',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // === PHẦN 1: THÔNG TIN ===
              _buildSectionHeader(title: 'Thông tin'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSelectorField(
                      label: 'Đại diện cho thuê',
                      value:
                          _nameTanentDisplayController.text.isNotEmpty
                              ? _nameTanentDisplayController.text
                              : 'Chọn đại diện cho thuê',
                      isPlaceholder: _nameTanentDisplayController.text.isEmpty,
                      isRequired: true,

                      onTap: () async {
                        // Logic chọn phòng thuê (Hiển thị danh sách phòng)
                        final result = await getIt<AppRouter>().push(
                          const SelectTanentContract(),
                        );

                        // Kiểm tra dữ liệu trả về
                        if (result != null && result is Map<String, dynamic>) {
                          setState(() {
                            // Lưu ID để sau này gọi API thêm hợp đồng
                            _selectedTanentId = result['idNguoiThue'];

                            // Lưu Tên để hiển thị lên UI
                            _nameTanentDisplayController.text = result['ten'];
                          });
                        }
                      },
                    ),
                    _buildSelectorField(
                      label: 'Chọn phòng',
                      value:
                          _selectedRoomName != null
                              ? _selectedRoomName!
                              : 'Chọn phòng',

                      isPlaceholder: _selectedRoomName == null,
                      isRequired: true,
                      onTap: () async {
                        // Logic chọn phòng thuê (Hiển thị danh sách phòng)
                        final resultCotract = await getIt<AppRouter>().push(
                          SelectRoomContract(),
                        );

                        // Xử lý dữ liệu trả về
                        if (resultCotract != null &&
                            resultCotract is Map<String, dynamic>) {
                          setState(() {
                            // Cập nhật ID và Tên phòng
                            _selectedRoomId =
                                resultCotract['id']; // Lưu ý key phải khớp với màn hình trước
                            _selectedRoomName = resultCotract['name'];

                            // --- CẬP NHẬT GIÁ VÀ CỌC VÀO Ô INPUT ---

                            // Lấy giá trị chuỗi từ kết quả trả về (vd: "4200000.00")
                            String rawPrice =
                                resultCotract['priceRoom']?.toString() ?? '';
                            String rawDeposit =
                                resultCotract['depositRoom']?.toString() ?? '';

                            // Gán vào Controller để hiển thị lên UI
                            // Logic xử lý cắt đuôi .00 nếu có
                            _roomPriceController.text =
                                (resultCotract['priceRoom']?.toString() ?? '')
                                    .replaceAll('.00', '');
                            _depositController.text =
                                (resultCotract['depositRoom']?.toString() ?? '')
                                    .replaceAll('.00', '');
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Thời hạn (Từ ngày - Đến ngày)
                    _buildLabel('Thời hạn', isRequired: true),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDatePickerField(
                            value: DateFormat('dd-MM-yyyy').format(_fromDate),
                            hintText: '',
                            onTap: () async {
                              // Gọi DatePicker của Flutter
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _fromDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              // Nếu người dùng chọn ngày mới thì cập nhật lại State
                              if (picked != null && picked != _fromDate) {
                                setState(() {
                                  _fromDate = picked;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSelectorDurationField(
                            value: _selectedDurationCycle,
                            isRequired: true,
                            onTap: _showPaymentDurationCyclePicker,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Ngày bắt đầu tính tiền', isRequired: true),
                    const SizedBox(height: 8),
                    _buildDatePickerField(
                      value: DateFormat('dd-MM-yyyy').format(_fromDate),
                      hintText: '',
                    ),
                    _buildSelectorField(
                      label: 'Kỳ thanh toán tiền phòng',
                      value: _selectedPaymentCycle,
                      isRequired: true,
                      // onTap: _showPaymentCyclePicker,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // === PHẦN 2: TIỀN PHÒNG ===
              _buildSectionHeader(title: 'Tiền phòng'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    // Ô nhập Tiền phòng
                    _buildInputField(
                      label: 'Tiền phòng',
                      hintText: 'Tiền phòng 1 tháng',
                      controller: _roomPriceController,
                      isRequired: true,
                      keyboardType: TextInputType.number, // Bàn phím số
                    ),

                    const SizedBox(height: 20), // Khoảng cách giữa 2 ô
                    // Ô nhập Tiền cọc
                    _buildInputField(
                      label: 'Tiền cọc',
                      hintText: 'Nhập tiền cọc',
                      controller: _depositController,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // === PHẦN 5: ĐIỀU KHOẢN ===
              _buildSectionHeader(title: 'Điều khoản'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildSelectorClauseField(
                  value: 'Chọn điều khoản',
                  hasUnderline: true,
                  isPlaceholder: false,
                ),
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
                                  ? () => _showImageSourceActionSheet(context)
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
                                scrollDirection: Axis.horizontal, // Trượt ngang
                                itemCount: _selectedImages.length,
                                separatorBuilder:
                                    (ctx, index) => const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  return Stack(
                                    children: [
                                      // Ảnh thumbnail
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
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
                                            padding: const EdgeInsets.all(4),
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

                    // === NÚT TẠO HỢP ĐỒNG ===
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          _onSubmitCreateContract();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF66BB6A,
                          ), // Màu xanh lá
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Tạo hợp đồng',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- CÁC WIDGET HỖ TRỢ (HELPER WIDGETS) ---

  // 1. Tiêu đề Section (Màu xanh)
  Widget _buildSectionHeader({required String title, Widget? action}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF66BB6A), // Màu xanh giống trong hình
        borderRadius: BorderRadius.only(
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
          if (action != null) action,
        ],
      ),
    );
  }

  // 2. Widget Label (có dấu sao đỏ nếu required)
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

  // 3. Widget chọn (Selector - Text + Icon mũi tên)
  Widget _buildSelectorField({
    required String label,
    required String value,
    bool isRequired = false,
    bool isPlaceholder = false,
    bool hasUnderline = true,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border:
              hasUnderline
                  ? Border(bottom: BorderSide(color: Colors.grey.shade300))
                  : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel(label, isRequired: isRequired),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: isPlaceholder ? Colors.grey : Colors.black87,
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorDurationField({
    required String value,
    bool isRequired = false,
    bool isPlaceholder = false,
    bool hasUnderline = true,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border:
              hasUnderline
                  ? Border(bottom: BorderSide(color: Colors.grey.shade300))
                  : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: isPlaceholder ? Colors.grey : Colors.black87,
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorClauseField({
    required String value,
    bool isPlaceholder = false,
    bool hasUnderline = true,
  }) {
    return InkWell(
      onTap: () {
        // Xử lý sự kiện chọn
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border:
              hasUnderline
                  ? Border(bottom: BorderSide(color: Colors.grey.shade300))
                  : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: isPlaceholder ? Colors.grey : Colors.black87,
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 4. Widget chọn ngày
  Widget _buildDatePickerField({
    String? value,
    required String hintText,
    bool isFullWidth = false,
    VoidCallback? onTap, // <--- Tham số này cần được sử dụng
  }) {
    // Bọc bằng InkWell để bắt sự kiện click
    return InkWell(
      onTap: onTap, // <--- Gán sự kiện click vào đây
      child: Container(
        padding: const EdgeInsets.only(
          bottom: 8,
          top: 8,
        ), // Thêm top 8 cho dễ bấm hơn
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? hintText,
                style: TextStyle(
                  fontSize: 14,
                  color: value != null ? Colors.black87 : Colors.grey,
                ),
              ),
            ),
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

  // 5. Widget nhập liệu (TextField)
  Widget _buildInputField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Phần Nhãn (Label) với dấu sao đỏ
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w600, // Chữ hơi đậm
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red), // Dấu sao màu đỏ
                ),
            ],
          ),
        ),
        const SizedBox(height: 8), // Khoảng cách nhỏ giữa nhãn và ô nhập
        // 2. Phần Ô nhập liệu (TextField)
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 16), // Cỡ chữ khi nhập
          decoration: InputDecoration(
            hintText: hintText, // Dòng chữ gợi ý mờ
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            isDense: true, // Làm cho ô nhập gọn hơn
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            filled: true,
            fillColor: Colors.white,
            // Đường gạch chân khi không focus (màu xám nhạt)
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            // Đường gạch chân khi focus (màu xanh chủ đạo)
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.green, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
