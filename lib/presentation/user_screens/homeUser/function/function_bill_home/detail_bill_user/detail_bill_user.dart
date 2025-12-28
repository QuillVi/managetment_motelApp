import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:motelapp/data/models/User_model/bill_user_model.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/User_cubit/bill_user/bill_user_cubit.dart';
import 'package:motelapp/logic/cubits/User_cubit/bill_user/bill_user_state.dart';
import 'package:motelapp/router/app_router.dart';

class DetailBillUser extends StatefulWidget {
  final int idHoaDon;
  const DetailBillUser({super.key, required this.idHoaDon});

  @override
  State<DetailBillUser> createState() => _DetailBillUserState();
}

class _DetailBillUserState extends State<DetailBillUser> {
  late final TextEditingController _noteController;
  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    context.read<BillUserCubit>().loadDetailBillUser(widget.idHoaDon);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // --- Helpers để định dạng dữ liệu ---
  String _formatCurrency(double amount) {
    // Định dạng tiền tệ Việt Nam
    final format = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  String _formatMonthYear(DateTime? date) {
    if (date == null) return "N/A";
    return DateFormat('MM-yyyy').format(date);
  }

  String _formatFullDate(DateTime? date) {
    if (date == null) return "N/A";
    return DateFormat('dd-MM-yyyy').format(date);
  }

  /// Hiển thị Dialog (Pop-up) thanh toán
  void _showPaymentDialog(BuildContext context, DetailBillUserModel bill) {
    // Helper format tiền
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 20,
          ),

          // Nội dung chính
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Tiêu đề và Số tiền
              const Text(
                "Quét mã để thanh toán",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                currencyFormatter.format(bill.tongHopTien),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 20),

              // 2. Hình ảnh QR Code
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Image.asset(
                      'lib/assets/images/qr.jpg', // Đường dẫn ảnh QR của bạn
                      width: 220,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 220,
                          height: 220,
                          color: Colors.grey[100],
                          alignment: Alignment.center,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, color: Colors.grey),
                              SizedBox(height: 4),
                              Text(
                                "Lỗi ảnh QR",
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    // Gợi ý nội dung chuyển khoản
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "Nội dung: ${bill.tenPhong} - T${bill.ngayThang?.month ?? ''}",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue[800],
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. Nút Đóng (Chỉ đóng dialog, không xử lý logic)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // Chỉ đóng dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    side: BorderSide(color: Colors.grey[300]!),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Đóng"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Màu nền xám nhạt để các khối màu trắng nổi bật
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: BlocConsumer<BillUserCubit, BillUserState>(
        listener: (context, state) {
          // Tự động cập nhật Ghi chú khi dữ liệu được tải
          if (state.status == BillUserStatus.loaded &&
              state.detailBillUser != null) {
            _noteController.text = state.detailBillUser!.ghiChuHoaDon ?? '';
          }
        },
        builder: (context, state) {
          // 1. Trạng thái Đang tải
          if (state.status == BillUserStatus.loading ||
              state.status == BillUserStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Trạng thái Lỗi
          if (state.status == BillUserStatus.error) {
            return Center(
              child: Text(
                'Đã xảy ra lỗi: ${state.errorMessage ?? "Không xác định"}',
              ),
            );
          }

          // 3. Trạng thái Tải thành công
          if (state.status == BillUserStatus.loaded &&
              state.detailBillUser != null) {
            // Lấy dữ liệu bill từ state
            final bill = state.detailBillUser!;

            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildTopInfo(bill), // <-- Truyền bill
                  const SizedBox(height: 8),
                  _buildCostDetails(bill), // <-- Truyền bill
                  _buildButtonSection(bill),
                  const SizedBox(height: 8),
                  _buildServicesSection(bill), // <-- Truyền bill
                  const SizedBox(height: 8),
                  _buildNotesSection(bill), // <-- Truyền bill
                  const SizedBox(height: 20),
                ],
              ),
            );
          }

          // Trạng thái dự phòng
          return const Center(child: Text('Không tìm thấy dữ liệu hoá đơn.'));
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    // 1. Lắng nghe trạng thái và lấy DetailBillModel
    final billState = context.watch<BillUserCubit>().state;
    final DetailBillUserModel? bill = billState.detailBillUser;

    // Xử lý khi dữ liệu chưa được tải
    if (bill == null) {
      return AppBar(
        title: const Text(
          "Hoá đơn",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            getIt<AppRouter>().pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined, color: Colors.grey),
            onPressed: null, // Vô hiệu hóa khi chưa có dữ liệu
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.grey),
            onPressed: null, // Vô hiệu hóa
          ),
        ],
      );
    }

    // 2. Xác định trạng thái thanh toán để chọn template PDF
    final bool isPaidOrOverdue =
        bill.trangThaiHoaDon == 'Đã thanh toán' ||
        bill.trangThaiHoaDon == 'Quá hạn';

    // 3. Xây dựng AppBar
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () {
          getIt<AppRouter>().pop();
        },
      ),
      title: const Text(
        "Hoá đơn",
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
        // <<< LOGIC NÚT 1: XEM TRƯỚC HÓA ĐƠN
        // IconButton(
        //   icon: const Icon(Icons.receipt_long_outlined, color: Colors.orange),
        //   tooltip: "Xem trước hóa đơn",
        //   onPressed: () {},
        // ),
        // <<< LOGIC NÚT 2: CHIA SẺ PDF
        IconButton(
          icon: const Icon(Icons.share_outlined, color: Colors.orange),
          tooltip: "Chia sẻ nhanh",
          onPressed: () async {},
        ),
      ],
    );
  }

  /// Xây dựng khối thông tin trên cùng (Mã HĐ, Ngày, Địa điểm...)
  Widget _buildTopInfo(DetailBillUserModel bill) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "#${bill.idHoadon}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Text(
                    _formatMonthYear(bill.ngayThang),
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[700]),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.home_outlined,
            "${bill.tenPhong} - ${bill.tenToanha}",
          ),
          _buildInfoRow(
            Icons.edit_outlined,
            "Hạn thanh toán: ${_formatFullDate(bill.hanThanhToan)}",
          ),
        ],
      ),
    );
  }

  /// Widget phụ trợ cho các hàng thông tin (Icon + Text)
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20.0, color: Colors.grey[400]),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 11, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  /// Xây dựng khối chi tiết chi phí (Tiền phòng, dịch vụ, cọc...)
  Widget _buildCostDetails(DetailBillUserModel bill) {
    // <-- Nhận bill
    // --- Thêm logic cho Đã trả/Còn lại ---
    double daTra = 0.0;
    double conLai = bill.tongHopTien;

    // Logic suy luận: Nếu API trả về "Đã thanh toán"
    // (Bạn hãy thay "Đã thanh toán" bằng chuỗi chính xác từ API của bạn)
    if (bill.trangThaiHoaDon == 'Đã thanh toán') {
      daTra = bill.tongHopTien;
      conLai = 0.0;
    }
    // --- Hết logic ---

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // <-- Dữ liệu động
          _buildCostRow("Tiền phòng", _formatCurrency(bill.giaPhong)),
          // <-- Dữ liệu động
          _buildCostRow("Tiền dịch vụ", _formatCurrency(bill.tongTienDichVu)),
          // <-- Dữ liệu động
          _buildCostRow("Tiền cọc hợp đồng", _formatCurrency(bill.tienDatCoc)),
          const Divider(height: 24),
          // <-- Dữ liệu động
          _buildCostRow(
            "Tổng",
            _formatCurrency(bill.tongHopTien),
            isBold: true,
          ),
          // <-- Dữ liệu động (từ logic)
          _buildCostRow("Đã trả", _formatCurrency(daTra), isBold: true),
          // <-- Dữ liệu động (từ logic)
          _buildCostRow(
            "Còn lại",
            _formatCurrency(conLai),
            amountColor: conLai > 0 ? Colors.red : Colors.black,
            isBold: true,
          ),
        ],
      ),
    );
  }

  /// Widget phụ trợ cho các hàng chi phí (Label + Amount)
  Widget _buildCostRow(
    String label,
    String amount, {
    Color amountColor = Colors.black,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              color: amountColor,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// Xây dựng nút hành động
  /// Logic: Chỉ hiển thị nút "Thanh toán" nếu trạng thái là "Chưa thanh toán"
  /// Các trạng thái khác (Đã thanh toán, Quá hạn...) thì ẩn đi.
  Widget _buildButtonSection(DetailBillUserModel bill) {
    // 1. Kiểm tra trạng thái
    final String status = bill.trangThaiHoaDon;

    // 2. Nếu KHÔNG PHẢI là "Chưa thanh toán", thì trả về Widget rỗng (ẩn đi)
    if (status != 'Chưa thanh toán') {
      return const SizedBox.shrink();
    }

    // 3. Nếu là "Chưa thanh toán", hiển thị Container chứa nút Thanh toán
    return Container(
      padding: const EdgeInsets.all(16.0),
      // Tạo bóng đổ nhẹ phía trên nút cho đẹp (tùy chọn)
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // Gọi hàm hiển thị Dialog thanh toán
            _showPaymentDialog(context, bill);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // Màu xanh chủ đạo
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              vertical: 14,
            ), // Tăng độ cao nút xíu cho dễ bấm
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: const Text(
            "Thanh toán",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  /// Xây dựng phần Dịch vụ (Thanh tiêu đề xanh + danh sách)
  Widget _buildServicesSection(DetailBillUserModel bill) {
    return Column(
      children: [
        // Thanh tiêu đề "Dịch vụ"
        Container(
          width: double.infinity,
          color: Colors.green.shade100,
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Dịch vụ",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
        ),

        // --- Nội dung dịch vụ (điện) ---
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Hàng #1: điện (kwh) - Đây là dữ liệu tĩnh
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  radius: 14,
                  child: const Text("#1", style: TextStyle(fontSize: 12)),
                ),
                title: const Text(
                  "Tổng các dịch vụ", // Đổi tên cho rõ nghĩa
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              //Hàng #4: Đơn giá (Tĩnh - vì không có trong API)
              _buildServiceCostRow("Đơn giá", "3.500 đ"),
              const SizedBox(height: 8),

              // Hàng #5: Thành tiền
              _buildServiceCostRow(
                "Thành tiền",
                _formatCurrency(bill.tongTienDichVu), // <-- Dữ liệu động
                isTotal: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper cho "Đơn giá" và "Thành tiền"
  Widget _buildServiceCostRow(
    String label,
    String amount, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.green[700] : Colors.black,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.green[700] : Colors.black,
          ),
        ),
      ],
    );
  }

  /// Xây dựng phần Ghi chú
  Widget _buildNotesSection(DetailBillUserModel bill) {
    // <-- Nhận bill
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ghi chú', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
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
              controller: _noteController, // <-- Dùng controller
              readOnly: true, // <-- Đặt là true nếu chỉ muốn hiển thị
              // readOnly: false, // <-- Đặt là false nếu muốn cho phép sửa
              maxLines: 3,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                filled: true,
                fillColor: Colors.white,
                hintText: 'Không có ghi chú',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Đặt class này bên trong file UI của bạn, bên dưới class _DetailBillState
class _PaymentDialogContent extends StatefulWidget {
  final DetailBillUserModel bill;

  const _PaymentDialogContent({super.key, required this.bill});

  @override
  _PaymentDialogContentState createState() => _PaymentDialogContentState();
}

class _PaymentDialogContentState extends State<_PaymentDialogContent> {
  // Mặc định chọn Chuyển khoản để hiện QR luôn cho tiện (tùy bạn chọn)
  String _selectedMethod = "Chuyển khoản";
  late String _selectedPayer;
  final DateTime _selectedDate = DateTime.now();

  // Helper định dạng tiền
  String _formatCurrency(double amount) {
    final format = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '',
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  @override
  void initState() {
    super.initState();
    _selectedPayer = widget.bill.ten;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWarningNote(),
          const SizedBox(height: 20),

          // --- 1. Hiển thị số tiền ---
          Center(
            child: Column(
              children: [
                const Text(
                  "Tổng thanh toán",
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  _formatCurrency(widget.bill.tongHopTien),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // --- 2. Khu vực hiển thị QR Code (MỚI) ---
          // Chỉ hiện khi chọn phương thức là "Chuyển khoản"
          if (_selectedMethod == "Chuyển khoản")
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Load ảnh từ assets
                    Image.asset(
                      'lib/assets/images/qr.jpg', // Đường dẫn đúng như bạn khai báo
                      width: 200, // Kích thước QR
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey[200],
                          child: const Center(child: Text("Lỗi tải ảnh QR")),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Quét mã để thanh toán",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

          // --- 3. Các thông tin chọn ---
          _buildDialogRow(
            label: "Phương thức",
            value: _selectedMethod,
            trailing: const Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: Colors.grey,
            ),
            onTap: _showPaymentMethodSheet, // Gọi hàm mở bottom sheet
          ),

          Divider(height: 1, color: Colors.grey[200]), // Dòng kẻ ngăn cách

          _buildDialogRow(
            label: "Ngày thanh toán",
            value: _formatDate(_selectedDate),
            trailing: const Icon(
              Icons.calendar_today,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () {
              // TODO: Logic chọn ngày
            },
          ),

          // ... Các phần upload ảnh và ghi chú giữ nguyên ...
          const SizedBox(height: 16),
          _buildImagePickerSection(),
          const SizedBox(height: 24),
          _buildNotesInputSection(),
          const SizedBox(height: 24),

          // Nút xác nhận thanh toán
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // Logic gọi API thanh toán (như code cũ)
                // context.read<BillUserCubit>().processPayment(...)
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Đã thanh toán",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Hàm chọn phương thức thanh toán ---
  void _showPaymentMethodSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  "Chọn phương thức",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_2, color: Colors.blue),
              title: const Text("Chuyển khoản (QR Code)"),
              onTap: () {
                setState(() {
                  _selectedMethod = "Chuyển khoản";
                });
                Navigator.pop(sheetContext);
              },
            ),
            ListTile(
              leading: const Icon(Icons.money, color: Colors.green),
              title: const Text("Tiền mặt"),
              onTap: () {
                setState(() {
                  _selectedMethod = "Tiền mặt";
                });
                Navigator.pop(sheetContext);
              },
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  // --- Các hàm helper (sao chép từ câu trả lời trước) ---
  Widget _buildWarningNote() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        "Lưu ý: nếu số tiền thanh toán < tổng tiền hóa đơn, số tiền còn lại sẽ chuyển thành khoản nợ, và có thể tra cứu ở mục sổ nợ",
        style: TextStyle(color: Colors.orange[800], fontSize: 13),
      ),
    );
  }

  Widget _buildDialogRow({
    required String label,
    required String value,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
                const SizedBox(width: 8),
                trailing,
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogRowUser({
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Ảnh giao dịch (tối đa 10 ảnh)",
              style: TextStyle(fontSize: 16),
            ),
            InkWell(
              onTap: () {
                // TODO: Xử lý chọn ảnh
              },
              child: const CircleAvatar(
                radius: 14,
                backgroundColor: Colors.green,
                child: Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            "Dữ liệu trống",
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Ghi chú", style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Nhập ghi chú cho giao dịch",
            fillColor: Colors.grey[100],
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
