import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:motelapp/data/models/bill_model.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/home/bill_home/bill_cubit.dart';
import 'package:motelapp/logic/cubits/home/bill_home/bill_state.dart';
import 'package:motelapp/presentation/screens/home/functions/function_bill_home/bill_home.dart';
import 'package:motelapp/presentation/screens/home/functions/function_bill_home/detail_bill/bill_preview_screen.dart';
import 'package:motelapp/presentation/screens/home/functions/function_bill_home/detail_bill/pdf_service.dart';
import 'package:motelapp/router/app_router.dart';
import 'package:printing/printing.dart';

class DetailBill extends StatefulWidget {
  final int idHoaDon;
  const DetailBill({super.key, required this.idHoaDon});

  @override
  State<DetailBill> createState() => _DetailBillState();
}

class _DetailBillState extends State<DetailBill> {
  late final TextEditingController _noteController;
  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    context.read<BillCubit>().LoadDetailBill(widget.idHoaDon);
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
  void _showPaymentDialog(BuildContext context, DetailBillModel bill) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
          contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),

          // --- Tiêu đề (Thanh toán + Nút X) ---
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Thanh toán",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.grey[600]),
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // Đóng dialog
                },
              ),
            ],
          ),

          // --- NỘI DUNG MỚI ---
          // Chỉ cần gọi Widget Stateful của bạn ở đây
          content: _PaymentDialogContent(bill: bill),
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
      body: BlocConsumer<BillCubit, BillState>(
        listener: (context, state) {
          // Tự động cập nhật Ghi chú khi dữ liệu được tải
          if (state.status == BillStatus.loaded &&
              state.detailBillModel != null) {
            _noteController.text = state.detailBillModel!.ghiChuHoaDon ?? '';
          }
        },
        builder: (context, state) {
          // 1. Trạng thái Đang tải
          if (state.status == BillStatus.loading ||
              state.status == BillStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Trạng thái Lỗi
          if (state.status == BillStatus.error) {
            return Center(
              child: Text(
                'Đã xảy ra lỗi: ${state.errorMessage ?? "Không xác định"}',
              ),
            );
          }

          // 3. Trạng thái Tải thành công
          if (state.status == BillStatus.loaded &&
              state.detailBillModel != null) {
            // Lấy dữ liệu bill từ state
            final bill = state.detailBillModel!;

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
    final billState = context.watch<BillCubit>().state;
    final DetailBillModel? bill = billState.detailBillModel;

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
            getIt<AppRouter>().push(const BillHome());
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
          getIt<AppRouter>().push(const BillHome());
        },
      ),
      title: const Text(
        "Hoá đơn",
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
        // <<< LOGIC NÚT 1: XEM TRƯỚC HÓA ĐƠN
        IconButton(
          icon: const Icon(Icons.receipt_long_outlined, color: Colors.orange),
          tooltip: "Xem trước hóa đơn",
          onPressed: () {
            // Mở màn hình xem trước PDF
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (ctx) =>
                        BillPreviewScreen(bill: bill, isPaid: isPaidOrOverdue),
              ),
            );
          },
        ),
        // <<< LOGIC NÚT 2: CHIA SẺ PDF
        IconButton(
          icon: const Icon(Icons.share_outlined, color: Colors.orange),
          tooltip: "Chia sẻ nhanh",
          onPressed: () async {
            // Logic chia sẻ nhanh mà bạn đã viết
            try {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đang tạo PDF để chia sẻ...')),
              );

              final pdfBytes = await generateBillPdf(
                bill: bill,
                isPaid: isPaidOrOverdue,
              );

              await Printing.sharePdf(
                bytes: pdfBytes,
                filename: 'hoa_don_${bill.idHoadon}.pdf',
              );
            } catch (e) {
              print('Error sharing PDF: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lỗi khi chia sẻ PDF: ${e.toString()}')),
              );
            }
          },
        ),
      ],
    );
  }

  /// Xây dựng khối thông tin trên cùng (Mã HĐ, Ngày, Địa điểm...)
  Widget _buildTopInfo(DetailBillModel bill) {
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
  Widget _buildCostDetails(DetailBillModel bill) {
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

  /// Xây dựng các nút hành động (Thanh toán, Sửa, Xoá)
  /// dựa trên trạng thái hoá đơn
  Widget _buildButtonSection(DetailBillModel bill) {
    // Lấy trạng thái từ model
    final String status = bill.trangThaiHoaDon;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Builder(
        builder: (context) {
          // Dùng switch-case để xử lý các trạng thái
          switch (status) {
            // --- Kịch bản 1: Chưa thanh toán ---
            case 'Chưa thanh toán':
              return Column(
                children: [
                  // Nút 1: Thanh toán (Nút chính, màu xanh)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Xử lý sự kiện "Thanh toán"
                        _showPaymentDialog(context, bill);
                      },
                      child: const Text(
                        "Thanh toán",
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Màu chính
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Hàng 2: Chỉnh sửa và Xoá (Nút phụ, viền)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // TODO: Xử lý sự kiện "Chỉnh sửa"
                          },
                          child: const Text("Chỉnh sửa"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            side: const BorderSide(color: Colors.orange),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {},
                          child: const Text("Xoá"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red[400],
                            side: BorderSide(color: Colors.red[400]!),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );

            // --- Kịch bản 2: Quá hạn hoặc Đã thanh toán ---
            case 'Quá hạn':
            case 'Đã thanh toán':
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // 1. Lấy Cubit và ScaffoldMessenger
                    final billCubit = context.read<BillCubit>();
                    final scaffoldMessenger = ScaffoldMessenger.of(context);

                    // 2. Lấy ID hóa đơn
                    final int hoaDonId = bill.idHoadon;

                    // 3. Gọi Cubit để thực hiện logic "Hoàn tác"
                    try {
                      await billCubit.revertPayment(hoaDonId);

                      // 4. Hiển thị thông báo thành công
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text("Xóa hóa đơn thành công!"),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } catch (e) {
                      // 5. Hiển thị lỗi nếu API thất bại
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text('Hoàn tác thất bại: ${e.toString()}'),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: const Text("Xoá", style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400], // Màu đỏ
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              );

            // --- Mặc định (cho các trạng thái khác) ---
            default:
              // Không hiển thị nút nào
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  /// Xây dựng phần Dịch vụ (Thanh tiêu đề xanh + danh sách)
  Widget _buildServicesSection(DetailBillModel bill) {
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
  Widget _buildNotesSection(DetailBillModel bill) {
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
  final DetailBillModel bill;

  const _PaymentDialogContent({Key? key, required this.bill}) : super(key: key);

  @override
  _PaymentDialogContentState createState() => _PaymentDialogContentState();
}

class _PaymentDialogContentState extends State<_PaymentDialogContent> {
  // --- Biến trạng thái để lưu trữ lựa chọn ---
  String _selectedMethod = "Tiền mặt";
  late String _selectedPayer;
  DateTime _selectedDate = DateTime.now(); // Lấy ngày hiện tại

  // Helper để định dạng tiền tệ
  String _formatCurrency(double amount) {
    final format = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '',
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  // Helper để định dạng ngày
  String _formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  @override
  void initState() {
    super.initState();
    // Khởi tạo tên người nộp tiền từ bill model
    _selectedPayer = widget.bill.ten;
  }

  @override
  Widget build(BuildContext context) {
    // --- Đây là code nội dung Dialog từ trước, đã được cập nhật ---
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWarningNote(),
          const SizedBox(height: 20),
          Center(
            child: Text(
              _formatCurrency(widget.bill.tongHopTien),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildDialogRow(
            label: "Ngày thanh toán",
            value: _formatDate(_selectedDate), // <-- Dùng biến trạng thái
            trailing: Icon(
              Icons.calendar_today_outlined,
              size: 14,
              color: Colors.grey[500],
            ),
            onTap: () {
              // TODO: Thêm logic chọn ngày
            },
          ),
          _buildDialogRow(
            label: "Phương thức\nthanh toán",
            value: _selectedMethod, // <-- Dùng biến trạng thái
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey[500],
            ),
            onTap: () {
              // --- GỌI BOTTOM SHEET TỪ ĐÂY ---
              _showPaymentMethodSheet();
            },
          ),
          _buildDialogRowUser(
            label: "Người nộp tiền",
            value: _selectedPayer, // <-- Dùng biến trạng thái
          ),
          const SizedBox(height: 16),
          _buildImagePickerSection(),
          const SizedBox(height: 24),
          _buildNotesInputSection(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // 1. Lấy các đối tượng cần thiết TRƯỚC KHI đóng dialog
                final billCubit = context.read<BillCubit>();
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context); // Lưu lại Navigator

                // 2. Lấy ID hóa đơn VÀ phương thức thanh toán
                final int hoaDonId = widget.bill.idHoadon;
                final String phuongThuc = _selectedMethod; // <-- THÊM DÒNG NÀY

                // 3. Đóng dialog thanh toán
                if (navigator.canPop()) {
                  navigator.pop();
                }

                // 4. Gọi Cubit để xử lý thanh toán
                try {
                  // Gọi hàm processPayment với 2 tham số
                  await billCubit.processPayment(
                    hoaDonId,
                    phuongThuc,
                  ); // <-- SỬA DÒNG NÀY

                  // 5. Hiển thị thông báo thành công
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text("Thanh toán thành công!"),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  // 6. Hiển thị thông báo lỗi nếu có
                  print('Thanh toán thất bại: ${e.toString()}');
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Thanh toán thất bại: ${e.toString()}'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text("Thanh toán", style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Màu chính
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HÀM MỚI ĐỂ HIỂN THỊ BOTTOM SHEET ---
  void _showPaymentMethodSheet() {
    // 'context' ở đây là context của _PaymentDialogContentState,
    // nó có thể hiển thị bottom sheet trên toàn màn hình.
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      builder: (sheetContext) {
        return Wrap(
          children: [
            ListTile(
              title: const Center(
                child: Text(
                  "Tiền mặt",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              onTap: () {
                // Cập nhật trạng thái và đóng sheet
                setState(() {
                  _selectedMethod = "Tiền mặt";
                });
                Navigator.pop(sheetContext); // Đóng Bottom Sheet
              },
            ),
            Divider(height: 0.5, color: Colors.grey[200]),
            ListTile(
              title: const Center(
                child: Text(
                  "Chuyển khoản",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              onTap: () {
                // Cập nhật trạng thái và đóng sheet
                setState(() {
                  _selectedMethod = "Chuyển khoản";
                });
                Navigator.pop(sheetContext); // Đóng Bottom Sheet
              },
            ),
            // Thêm một khoảng đệm an toàn ở dưới
            SizedBox(height: MediaQuery.of(sheetContext).padding.bottom + 50),
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
