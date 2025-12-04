import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:motelapp/data/models/StakeMemberPayload.dart';
import 'package:motelapp/data/models/stake_model.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/home/stake_home/stake_cubit.dart';
import 'package:motelapp/logic/cubits/home/stake_home/stake_state.dart';
import 'package:motelapp/presentation/screens/home/functions/function_stake_home/add_stake/add_staker.dart';
import 'package:motelapp/presentation/screens/home/functions/function_stake_home/add_stake/select_room_stake.dart';
import 'package:motelapp/router/app_router.dart';

class UpdateStake extends StatefulWidget {
  final int idStake;
  const UpdateStake({super.key, required this.idStake});

  @override
  State<UpdateStake> createState() => _UpdateStakeState();
}

class _UpdateStakeState extends State<UpdateStake> {
  // Controllers
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // State variables
  DateTime? _selectedDate;
  String? _paymentMethod;

  // List người đặt cọc
  final List<dynamic> _depositors = [];
  final List<dynamic> _images = []; // Nếu có xử lý ảnh

  // Biến lưu ID và tên phòng
  int? _selectedRoomId;
  String? _selectedRoomName;

  bool _isAmountEntered = false;

  @override
  void initState() {
    super.initState();
    // 1. Gọi API lấy chi tiết cọc ngay khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContentStakeCubit>().loadDetailStake(widget.idStake);
    });
  }

  // Hàm đổ dữ liệu từ API vào UI
  void _populateData(DetailStakeModel detail) {
    setState(() {
      // 1. Tiền cọc (Format lại tiền)
      if (detail.tienCoc != null) {
        // API trả về string dạng "5000000.00" -> parse double -> format string
        double money = double.tryParse(detail.tienCoc!) ?? 0;
        final formatter = NumberFormat('#,###', 'en_US');
        _amountController.text = formatter.format(money);
        _isAmountEntered = true;
      }

      // 2. Phòng
      _selectedRoomId = detail.idPhong;
      _selectedRoomName = detail.tenPhong;

      // 3. Ngày hẹn (Parse String "yyyy-MM-dd" sang DateTime)
      if (detail.ngayHenVao != null && detail.ngayHenVao!.isNotEmpty) {
        try {
          _selectedDate = DateTime.parse(detail.ngayHenVao!);
        } catch (e) {
          print("Lỗi parse ngày: $e");
          _selectedDate = DateTime.now();
        }
      }

      // 4. Phương thức thanh toán
      _paymentMethod = detail.phuongThucThanhToan;

      // 5. Ghi chú
      _noteController.text = detail.ghiChuCoc ?? '';

      // 6. Danh sách người đặt cọc
      // Cần map từ StakerModel (của API) sang StakeMemberPayload (của UI)
      _depositors.clear();
      if (detail.danhSachNguoiDatCoc.isNotEmpty) {
        for (var staker in detail.danhSachNguoiDatCoc) {
          // Giả sử StakerModel có các field tương ứng
          _depositors.add(
            StakeMemberPayload(
              // Lưu ý: Kiểm tra field trong StakerModel của bạn
              // Ở đây tôi map dựa trên JSON mẫu bạn đưa
              ten: staker.tenNguoiDatCoc ?? '',
              sdt: staker.sdtNguoiDatCoc ?? '',
              cmnd: staker.cmndNguoiDatCoc ?? '',
              email: staker.emailNguoiDatCoc ?? '',
              diaChi: staker.diaChiNguoiDatCoc ?? '',
              anhCmnd:
                  staker.anhCmndNguoiDatCoc != null
                      ? List<String>.from(staker.anhCmndNguoiDatCoc!)
                      : [],
            ),
          );
        }
      }
    });
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

    print("Payload update cọc: $payload");

    // 4. Gọi Cubit update cọc
    context.read<ContentStakeCubit>().updateStake(widget.idStake, payload);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng BlocConsumer để vừa lắng nghe vừa build lại UI khi loading
    return BlocConsumer<ContentStakeCubit, StakeState>(
      listener: (context, state) {
        // 1. Lắng nghe khi load dữ liệu thành công
        if (state.status == StakeStatus.loaded && state.detailStake != null) {
          // Chỉ populate data nếu ID trùng khớp hoặc lần đầu load
          // (Logic đơn giản nhất là cứ có data mới là fill vào)
          _populateData(state.detailStake!);
        }

        //  Lắng nghe khi UPDATE thành công
        if (state.status == StakeStatus.updateSuccess) {
          // Giả sử bạn có status này

          // Hiển thị thông báo thành công
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật thành công!'),
              backgroundColor: Colors.green,
            ),
          );

          // Quay lại màn hình trước (DetailStake) và trả về 'true' để báo hiệu cần reload
          Navigator.of(context).pop(true);
        }

        // 2. Thông báo lỗi nếu có
        if (state.status == StakeStatus.error && state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        // HIỂN THỊ LOADING KHI ĐANG TẢI
        if (state.status == StakeStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(true),
            ),
            centerTitle: true,
            title: const Text(
              'Chi tiết cọc giữ chỗ',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
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
                      // Nhập số tiền
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color:
                              _isAmountEntered
                                  ? Colors.black
                                  : Colors.grey[300],
                        ),
                        decoration: InputDecoration(
                          hintText: '0đ',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: InputBorder.none,
                        ),
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
                      // Thời gian
                      _buildSelectionRow(
                        label: 'Thời gian dự kiến vào ở',
                        value:
                            _selectedDate != null
                                ? DateFormat(
                                  'dd-MM-yyyy',
                                ).format(_selectedDate!)
                                : null,
                        placeholder: 'dd-mm-yyyy',
                        isRequired: true,
                        icon: Icons.calendar_today_outlined,
                        onTap: () => _pickDate(context),
                      ),
                      const Divider(height: 12, color: Colors.grey),
                      // Thanh toán
                      _buildSelectionRow(
                        label: 'Phương thức thanh toán',
                        value: _paymentMethod,
                        placeholder: 'Chọn phương thức thanh toán',
                        isRequired: true,
                        onTap: () => _showPaymentMethodPicker(context),
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
                    // Logic thêm người (giữ nguyên)
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddStaker(),
                      ),
                    );
                    if (result != null && result is StakeMemberPayload) {
                      setState(() {
                        _depositors.add(result);
                      });
                    }
                  },
                ),
                const SizedBox(height: 10),

                // HIỂN THỊ DANH SÁCH NGƯỜI
                _depositors.isEmpty
                    ? _buildEmptyStateBox("Chưa có thông tin người đặt cọc")
                    : Column(
                      children:
                          _depositors.map((member) {
                            // Ép kiểu về Model UI
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

                // --- KHUNG 3: GHI CHÚ ---
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
                      hintText: 'Nhập ghi chú...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // --- BUTTON ---
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed:
                        _handleCreateStake, // Thay bằng hàm update nếu cần
                    child: const Text(
                      'Cập nhật',
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
        );
      },
    );
  }

  // --- CÁC WIDGET CON (Giữ nguyên) ---
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
            color: Color(0xFF4CAF50),
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStateBox(String text) {
    return Container(
      width: double.infinity,
      height: 120,
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
