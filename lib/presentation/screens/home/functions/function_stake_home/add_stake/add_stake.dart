import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:motelapp/data/models/StakeMemberPayload.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/home/stake_home/stake_cubit.dart';
import 'package:motelapp/logic/cubits/home/stake_home/stake_state.dart';
import 'package:motelapp/presentation/screens/home/functions/function_stake_home/add_stake/add_staker.dart';
import 'package:motelapp/presentation/screens/home/functions/function_stake_home/add_stake/select_room_stake.dart';
import 'package:motelapp/router/app_router.dart';

class AddStake extends StatefulWidget {
  const AddStake({super.key});

  @override
  State<AddStake> createState() => _AddStakeState();
}

class _AddStakeState extends State<AddStake> {
  // Controllers
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // State variables (Dữ liệu tạm thời để hiển thị UI)
  String? _selectedRoom;
  DateTime? _selectedDate;
  String? _paymentMethod;

  // Giả lập danh sách người và ảnh (đang để rống để hiện UI giống hình)
  final List<dynamic> _depositors = [];
  final List<dynamic> _images = [];

  // biến lưu ID và tên phòng đã chọn
  int? _selectedRoomId;
  String? _selectedRoomName;
  @override
  void initState() {
    super.initState();
    // Set ngày mặc định là hôm nay nếu muốn giống hình
    _selectedDate = DateTime.now();
  }

  // Hàm format tiền tệ
  String _formatCurrency(String value) {
    if (value.isEmpty) return '';
    final number = double.tryParse(value.replaceAll(',', ''));
    if (number == null) return '';
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  // Hàm chọn ngày
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Thêm biến để kiểm tra trạng thái nhập tiền
  bool _isAmountEntered = false;

  // Hàm xử lý khi nhập tiền
  void _onAmountChanged(String value) {
    // 1. Xóa hết các ký tự không phải số (dấu phẩy, chấm cũ)
    String cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanValue.isEmpty) {
      setState(() {
        _amountController.text = '';
        _isAmountEntered = false; // Đổi về màu xám
      });
      return;
    }

    // 2. Parse sang số double
    double amount = double.tryParse(cleanValue) ?? 0;

    // 3. Format lại có dấu phân cách (dùng locale vi_VN để có dấu chấm)
    // Hoặc dùng en_US để có dấu phẩy tùy ý thích của bạn
    final formatter = NumberFormat('#,###', 'en_US');
    String formatted = formatter.format(amount);

    // 4. Cập nhật lại TextField mà không bị nhảy con trỏ
    setState(() {
      _amountController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(
          offset: formatted.length,
        ), // Đặt con trỏ về cuối
      );
      _isAmountEntered = true; // Đổi sang màu đen
    });
  }

  // Hàm hiển thị Modal chọn phương thức thanh toán
  void _showPaymentMethodPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Để bo góc đẹp
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5), // Màu nền xám nhẹ giống iOS
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Chỉ cao bằng nội dung
              children: [
                // Nút Tiền mặt
                _buildPaymentOption(
                  label: 'Tiền mặt',
                  onTap: () {
                    setState(() {
                      _paymentMethod = 'Tiền mặt';
                    });
                    Navigator.pop(context); // Đóng modal
                  },
                ),
                const SizedBox(height: 12),

                // Nút Chuyển khoản
                _buildPaymentOption(
                  label: 'Chuyển khoản',
                  onTap: () {
                    setState(() {
                      _paymentMethod = 'Chuyển khoản';
                    });
                    Navigator.pop(context);
                  },
                ),

                // Khoảng trống an toàn dưới cùng (cho iPhone X trở lên)
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleCreateStake() {
    // 1. Validate dữ liệu
    if (_amountController.text.isEmpty) {
      _showError("Vui lòng nhập số tiền cọc");
      return;
    }
    if (_selectedRoomId == null) {
      _showError("Vui lòng chọn phòng");
      return;
    }
    if (_selectedDate == null) {
      _showError("Vui lòng chọn ngày dự kiến");
      return;
    }
    if (_paymentMethod == null) {
      _showError("Vui lòng chọn phương thức thanh toán");
      return;
    }
    if (_depositors.isEmpty) {
      _showError("Vui lòng thêm ít nhất 1 người cọc");
      return;
    }

    // 2. Format dữ liệu

    // a. Tiền
    double amount =
        double.tryParse(
          _amountController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;

    // b. Ngày
    String dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    // c. Danh sách người cọc (Bao gồm cả ảnh CMND bên trong)
    List<Map<String, dynamic>> listNguoi =
        _depositors.map((d) {
          // Gọi toMap() để lấy cả trường 'anh_cmnd'
          return (d is StakeMemberPayload)
              ? d.toMap()
              : d as Map<String, dynamic>;
        }).toList();

    // d. Danh sách ảnh giao dịch (Nếu bạn có dùng biến _images ở màn hình chính)
    // Chuyển đổi List<XFile> thành List<String> đường dẫn
    List<String> listAnhGiaoDich =
        _images.map((img) => img.path.toString()).toList();

    // 3. Tạo Payload gửi đi
    final payload = {
      'id_phong': _selectedRoomId,
      'tien_coc': amount,
      'ngay_du_kien_nhan': dateStr,
      'phuong_thuc_thanh_toan': _paymentMethod,
      'ghi_chu': _noteController.text,

      // Danh sách người (đã có ảnh CMND bên trong từng người)
      'danh_sach_nguoi_dat_coc': listNguoi,
    };

    print("Payload tạo cọc: $payload");

    // 4. Gọi Cubit
    context.read<ContentStakeCubit>().createStake(payload);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContentStakeCubit, StakeState>(
      listener: (context, state) {
        // Xử lý Thành công
        if (state.status == StakeStatus.loaded && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Đợi xíu rồi thoát màn hình, trả về true để reload danh sách (nếu cần)
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) Navigator.pop(context, true);
          });
        }

        // Xử lý Lỗi
        if (state.status == StakeStatus.error && state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100], // Màu nền xám nhạt
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: const Text(
            'Thêm cọc giữ chỗ',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // --- KHUNG 1: THÔNG TIN CƠ BẢN ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Nhập số tiền (To, ở giữa)
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color:
                            _isAmountEntered ? Colors.black : Colors.grey[300],
                      ),
                      decoration: InputDecoration(
                        hintText: '0đ',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                      ),
                      // Gọi hàm xử lý format
                      onChanged: _onAmountChanged,
                    ),
                    const SizedBox(height: 20),
                    // Chọn phòng
                    _buildSelectionRow(
                      label: 'Chọn phòng',
                      value: _selectedRoomName,
                      placeholder: 'Chọn phòng',
                      isRequired: true,
                      onTap: () async {
                        // Logic chọn phòng thuê (Hiển thị danh sách phòng)
                        final resultCotract = await getIt<AppRouter>().push(
                          SelectRoomStake(),
                        );

                        // Xử lý dữ liệu trả về
                        if (resultCotract != null &&
                            resultCotract is Map<String, dynamic>) {
                          setState(() {
                            // KIỂM TRA KỸ KEY NÀY: 'id' hay 'id_phong' hay 'roomId'?
                            print("Dữ liệu phòng trả về: $resultCotract");
                            // Cập nhật ID và Tên phòng
                            _selectedRoomId =
                                resultCotract['id']; // Lưu ý key phải khớp với màn hình trước
                            _selectedRoomName = resultCotract['name'];
                          });
                        }
                      },
                    ),
                    const Divider(height: 12, color: Colors.grey),

                    // Thời gian dự kiến vào ở
                    _buildSelectionRow(
                      label: 'Thời gian dự kiến vào ở',
                      value:
                          _selectedDate != null
                              ? DateFormat('dd-MM-yyyy').format(_selectedDate!)
                              : null,
                      placeholder: 'dd-mm-yyyy',
                      isRequired: true,
                      icon: Icons.calendar_today_outlined,
                      onTap: () => _pickDate(context),
                    ),
                    const Divider(height: 12, color: Colors.grey),

                    // Phương thức thanh toán
                    _buildSelectionRow(
                      label: 'Phương thức thanh toán',
                      value: _paymentMethod,
                      placeholder: 'Chọn phương thức thanh toán',
                      isRequired: true,
                      onTap: () {
                        _showPaymentMethodPicker(context);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- KHUNG 2: NGƯỜI ĐẶT CỌC ---
              _buildSectionHeader(
                title: 'Người đặt cọc',
                isRequired: true,
                onAddPressed: () async {
                  // Mở màn hình thêm và CHỜ kết quả
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddStaker()),
                  );

                  // Nếu có kết quả trả về -> Thêm vào list
                  if (result != null && result is StakeMemberPayload) {
                    setState(() {
                      _depositors.add(result);
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              _depositors.isEmpty
                  ? _buildEmptyStateBox("Chưa có thông tin người đặt cọc")
                  : Column(
                    children:
                        _depositors.map((member) {
                          // Ép kiểu về Model
                          final m = member as StakeMemberPayload;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Colors.blueAccent,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        m.ten,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        m.sdt,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Nút xóa người này khỏi danh sách (Option)
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _depositors.remove(member);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
              const SizedBox(height: 10),

              // --- KHUNG 4: GHI CHÚ ---
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Ghi chú',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _noteController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Nhập ghi chú cho hoá đơn',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- BUTTON THÊM ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50), // Màu xanh lá
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    _handleCreateStake();
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
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Widget con: Dòng chọn thông tin (Phòng, Ngày, Thanh toán)
  Widget _buildSelectionRow({
    required String label,
    String? value,
    required String placeholder,
    required VoidCallback onTap,
    bool isRequired = false,
    IconData? icon,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: label,
                style: const TextStyle(color: Colors.black, fontSize: 16),
                children:
                    isRequired
                        ? [
                          const TextSpan(
                            text: ' *',
                            style: TextStyle(color: Colors.red),
                          ),
                        ]
                        : [],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? placeholder,
                    style: TextStyle(
                      fontSize: 16,
                      color: value != null ? Colors.black : Colors.grey[400],
                      fontWeight:
                          value != null ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
                Icon(icon ?? Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget con: Tiêu đề section có nút +
  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onAddPressed,
    bool isRequired = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(
            text: title,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            children:
                isRequired
                    ? [
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red),
                      ),
                    ]
                    : [],
          ),
        ),
        InkWell(
          onTap: onAddPressed,
          child: const Icon(
            Icons.add_circle,
            color: Color(0xFF4CAF50), // Màu xanh lá
            size: 28,
          ),
        ),
      ],
    );
  }

  // Widget con: Khung "Dữ liệu trống"
  Widget _buildEmptyStateBox(String text) {
    return Container(
      width: double.infinity,
      height: 120, // Chiều cao cố định giống hình
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.grey[500], fontSize: 16),
      ),
    );
  }

  // Widget con: Nút chọn trong Modal
  Widget _buildPaymentOption({
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
