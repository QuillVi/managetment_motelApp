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
import 'package:motelapp/presentation/screens/home/functions/function_bill_home/update_bill/update_bill.dart';
import 'package:motelapp/router/app_router.dart';
import 'package:printing/printing.dart';

class DetailOwe extends StatefulWidget {
  final int idOwe;
  const DetailOwe({super.key, required this.idOwe});

  @override
  State<DetailOwe> createState() => _DetailOweState();
}

class _DetailOweState extends State<DetailOwe> {
  late final TextEditingController _noteController;
  // 1. Controller cho ô nhập chỉ số điện mới
  late final TextEditingController _electricIndexController;

  // 2. Các biến lưu giá trị tính toán tạm thời (để hiển thị lên UI)
  double _tempElectricCost = 0.0; // Tiền điện đang tính
  double _tempTotalService = 0.0; // Tổng tiền dịch vụ đang tính
  double _tempTotalBill = 0.0; // Tổng thanh toán đang tính
  int _tempConsumption = 0; // Số tiêu thụ đang tính

  double _tempRemaining = 0.0;

  // 3. Biến lưu tổng tiền các dịch vụ KHÁC (trừ điện) để cộng dồn cho nhanh
  double _fixedOtherServicesCost = 0.0;
  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    _electricIndexController = TextEditingController(); // Khởi tạo

    //goi api để load dữ liệu
    context.read<BillCubit>().loadDetailBill(widget.idOwe);
  }

  @override
  void dispose() {
    _noteController.dispose();
    _electricIndexController.dispose(); // Nhớ dispose
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
  void _showPaymentDialog(
    BuildContext context,
    DetailBillModel bill,
    double amountToPay,
    double totalService,
    int? newElectricIndex,
  ) {
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
          content: _PaymentDialogContent(
            bill: bill,
            amountToPay: amountToPay,
            totalService: totalService,
            newElectricIndex: newElectricIndex,
          ),
        );
      },
    );
  }

  void _onElectricIndexChanged(String value, DetailBillModel bill) {
    // 1. Lấy dịch vụ điện gốc để biết đơn giá & chỉ số cũ
    final electricService = bill.chiTietDichVu.firstWhere(
      (s) => s.idDichvu == 1,
      orElse:
          () => ServiceDetailModel(
            idDichvu: 1,
            tenDichvu: 'Điện',
            donVi: '',
            donGia: 0,
            thanhTien: 0,
          ), // Dummy
    );

    // 2. Parse dữ liệu nhập vào
    int newIndex = int.tryParse(value) ?? 0;
    int oldIndex = electricService.chiSoCu ?? 0;
    double price = electricService.donGia;

    // 3. Tính toán
    int consumption = newIndex - oldIndex;
    if (consumption < 0) consumption = 0; // Không cho phép âm

    double newElectricCost = consumption * price;

    // 4. Cập nhật State để UI vẽ lại
    setState(() {
      _tempConsumption = consumption;
      _tempElectricCost = newElectricCost;

      // Gọi hàm tính tổng chung
      _recalculateTotal(bill);
    });
  }

  void _recalculateTotal(DetailBillModel bill) {
    // 1. Tính Tổng dịch vụ mới
    _tempTotalService = _tempElectricCost + _fixedOtherServicesCost;

    // 2. Tính Tổng thanh toán = Tiền phòng (lấy từ bill) + Tổng dịch vụ
    _tempTotalBill = bill.giaPhong + _tempTotalService;

    // 3. Tính Còn lại
    // Ở đây ta dùng biến 'bill' được truyền vào, không dùng 'widget.bill' nữa
    if (bill.trangThaiHoaDon == 'Đã thanh toán') {
      _tempRemaining = 0.0;
    } else {
      _tempRemaining = _tempTotalBill;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Màu nền xám nhạt để các khối màu trắng nổi bật
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: BlocConsumer<BillCubit, BillState>(
        listener: (context, state) {
          if (state.status == BillStatus.loaded &&
              state.detailBillModel != null) {
            final bill = state.detailBillModel!;

            // A. Gán ghi chú
            _noteController.text = bill.ghiChuHoaDon ?? '';

            // B. Tách dịch vụ Điện và Các dịch vụ khác
            ServiceDetailModel? electricService;
            double otherServices = 0.0;

            for (var s in bill.chiTietDichVu) {
              if (s.idDichvu == 1) {
                // Giả sử ID 1 là điện
                electricService = s;
              } else {
                otherServices += s.thanhTien;
              }
            }

            // C. Khởi tạo các biến tính toán
            _fixedOtherServicesCost = otherServices;

            if (electricService != null) {
              // Gán chỉ số mới vào controller (nếu có thì hiện, ko thì để trống hoặc 0)
              _electricIndexController.text =
                  electricService.chiSoMoi?.toString() ?? "";

              // Gán các giá trị tiền ban đầu
              _tempElectricCost = electricService.thanhTien;
              _tempConsumption = electricService.soTieuThu ?? 0;
            } else {
              _tempElectricCost = 0;
            }

            // Tính tổng lần đầu
            _recalculateTotal(bill);
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
    // Lưu ý: Không tính toán cục bộ ở đây nữa, dùng biến State đã tính

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Dòng 1: Tiền phòng (Cố định)
          _buildCostRow("Tiền phòng", _formatCurrency(bill.giaPhong)),

          // Dòng 2: Tiền dịch vụ -> DÙNG BIẾN _tempTotalService
          _buildCostRow("Tiền dịch vụ", _formatCurrency(_tempTotalService)),

          // Dòng 3: Tiền cọc (Tham khảo)
          if (bill.tienDatCoc > 0)
            _buildCostRow(
              "Tiền cọc hợp đồng",
              _formatCurrency(bill.tienDatCoc),
              amountColor: Colors.grey,
            ),

          const Divider(height: 24),

          // Dòng 4: TỔNG -> DÙNG BIẾN _tempTotalBill
          _buildCostRow(
            "Tổng thanh toán",
            _formatCurrency(_tempTotalBill),
            isBold: true,
          ),

          // Dòng 5: CÒN LẠI -> DÙNG BIẾN _tempRemaining
          _buildCostRow(
            "Còn lại",
            _formatCurrency(_tempRemaining),
            amountColor: _tempRemaining > 0 ? Colors.red : Colors.black,
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
                        int? currentInputIndex = int.tryParse(
                          _electricIndexController.text,
                        );

                        // 7. GỌI HÀM HIỂN THỊ VỚI DỮ LIỆU ĐIỆN
                        _showPaymentDialog(
                          context,
                          bill,
                          _tempTotalBill, // Tổng thanh toán (đã tính lại)
                          _tempTotalService, // <--- 3. TRUYỀN BIẾN TỔNG DỊCH VỤ VÀO
                          currentInputIndex,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Màu chính
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Thanh toán",
                        style: TextStyle(fontSize: 16),
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
                            getIt<AppRouter>().push(
                              UpdateBill(
                                idHoaDon: bill.idHoadon,
                                idNguoiThue: bill.idNguoidung,
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            side: const BorderSide(color: Colors.orange),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Chỉnh sửa"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red[400],
                            side: BorderSide(color: Colors.red[400]!),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Xoá"),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400], // Màu đỏ
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text("Xoá", style: TextStyle(fontSize: 16)),
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

  /// Xây dựng phần Dịch vụ (Dynamic List)
  Widget _buildServicesSection(DetailBillModel bill) {
    return Column(
      children: [
        // 1. Thanh tiêu đề "Dịch vụ"
        Container(
          width: double.infinity,
          color: Colors.green.shade100,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Text(
            "Chi tiết dịch vụ",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
        ),

        // 2. Nội dung danh sách dịch vụ
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // --- VÒNG LẶP DUYỆT QUA CÁC DỊCH VỤ ---
              ...bill.chiTietDichVu.map((service) {
                // Kiểm tra nếu là ĐIỆN (ID = 1 hoặc tên chứa chữ Điện)
                // Bạn nên check theo ID cho chính xác nhất
                if (service.idDichvu == 1) {
                  return _buildElectricItem(service, bill);
                } else {
                  return _buildNormalServiceItem(service);
                }
              }),

              const Divider(height: 24, thickness: 1),

              // --- TỔNG TIỀN DỊCH VỤ (Footer) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Tổng tiền dịch vụ",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  // SỬA Ở ĐÂY: Dùng _tempTotalService thay vì bill.tongTienDichVu
                  Text(
                    _formatCurrency(_tempTotalService),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildElectricItem(ServiceDetailModel service, DetailBillModel bill) {
    // 1. Kiểm tra điều kiện cho phép sửa
    bool isEditable = bill.trangThaiHoaDon == 'Chưa thanh toán';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tên dịch vụ + Thành tiền
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.electric_bolt,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    service.tenDichvu,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              // Hiển thị biến tạm tính (_tempElectricCost)
              Text(
                _formatCurrency(_tempElectricCost),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // --- PHẦN INPUT CHỈ SỐ ---
          Row(
            children: [
              // Cột 1: Chỉ số cũ (Luôn luôn ReadOnly)
              Expanded(
                child: _buildReadOnlyInput(
                  label: "Chỉ số cũ",
                  value: service.chiSoCu?.toString() ?? "--",
                ),
              ),
              const SizedBox(width: 16),

              // Cột 2: Chỉ số mới (Thay đổi tùy theo trạng thái)
              Expanded(
                child:
                    isEditable
                        ? _buildEditableNewIndexInput(
                          bill,
                        ) // Nếu chưa thanh toán -> Cho nhập
                        : _buildReadOnlyInput(
                          // Nếu đã thanh toán -> Chỉ xem
                          label: "Chỉ số mới",
                          value: service.chiSoMoi?.toString() ?? "--",
                          isMissing: service.chiSoMoi == null,
                        ),
              ),
            ],
          ),

          // Hiển thị tiêu thụ
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 4.0),
            child: Text(
              "Tiêu thụ: $_tempConsumption ${service.donVi} x ${_formatCurrency(service.donGia)}",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const Divider(height: 24),
        ],
      ),
    );
  }

  // Tách widget nhập liệu ra cho gọn
  Widget _buildEditableNewIndexInput(DetailBillModel bill) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Chỉ số mới",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _electricIndexController,
          keyboardType: TextInputType.number,
          onChanged: (val) => _onElectricIndexChanged(val, bill),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            hintText: "Nhập số",
            filled: true,
            fillColor: Colors.white,
            // Viền cam để người dùng biết là nhập được
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.orange),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.orange),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.orange, width: 2),
            ),
          ),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildNormalServiceItem(ServiceDetailModel service) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0), // Khoảng cách giữa các item
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _getServiceIcon(
                      service.idDichvu,
                    ), // Hàm lấy icon (tùy chọn)
                    color: Colors.blueGrey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(service.tenDichvu, style: const TextStyle(fontSize: 15)),
                ],
              ),
              Text(
                _formatCurrency(service.thanhTien),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          // Đường kẻ mờ ngăn cách các dịch vụ thường
          Divider(height: 16, color: Colors.grey.withOpacity(0.2)),
        ],
      ),
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

  /// Widget tạo ô input chỉ đọc (giả lập TextField nhưng không cho sửa)
  Widget _buildReadOnlyInput({
    required String label,
    required String value,
    bool isMissing = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[100], // Màu nền xám nhẹ biểu thị disabled
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Hàm chọn icon dựa theo ID dịch vụ (Tùy chỉnh theo database của bạn)
  IconData _getServiceIcon(int id) {
    switch (id) {
      case 2:
        return Icons.water_drop; // Nước
      case 3:
        return Icons.wifi; // Internet
      case 4:
        return Icons.motorcycle; // Giữ xe
      case 5:
        return Icons.cleaning_services; // Vệ sinh
      default:
        return Icons.check_circle_outline;
    }
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
  final double amountToPay;
  final double totalService;

  final int? newElectricIndex;

  const _PaymentDialogContent({
    super.key,
    required this.bill,
    required this.amountToPay,
    required this.totalService,
    this.newElectricIndex,
  });

  @override
  _PaymentDialogContentState createState() => _PaymentDialogContentState();
}

class _PaymentDialogContentState extends State<_PaymentDialogContent> {
  // --- Biến trạng thái để lưu trữ lựa chọn ---
  String _selectedMethod = "Tiền mặt";
  late String _selectedPayer;
  DateTime _selectedDate = DateTime.now(); // Lấy ngày hiện tại
  final TextEditingController _noteController = TextEditingController();
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
    _noteController.dispose();
    _selectedPayer = widget.bill.ten;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Text(
              // 3. Hiển thị số tiền được truyền vào
              _formatCurrency(widget.amountToPay),
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

                final int? chiSoDienMoi = widget.newElectricIndex;

                final String ghiChu = _noteController.text;
                // Format ngày thành chuỗi YYYY-MM-DD để gửi lên server
                final String ngayThanhToan = DateFormat(
                  'yyyy-MM-dd',
                ).format(_selectedDate);

                final double tongTienDichVu = widget.totalService;
                final double tongHopTien = widget.amountToPay;

                // ============================================================
                // 🛠 LOG DEBUG: IN DỮ LIỆU ĐẦY ĐỦ
                // ============================================================
                print("\n---------------------------------------------------");
                print("🚀 [CLIENT DEBUG] Bắt đầu quá trình thanh toán:");
                print("   📦 ID Hóa đơn: $hoaDonId");
                print("   📦 Phương thức: $phuongThuc");
                print("   📦 Chỉ số điện mới: $chiSoDienMoi");
                print("   📅 Ngày thanh toán: $ngayThanhToan");
                print("   💰 Tổng tiền dịch vụ: $tongTienDichVu");
                print("   💵 Tổng thanh toán: $tongHopTien");
                print("   📝 Ghi chú: '$ghiChu'");
                print("---------------------------------------------------\n");
                // ============================================================
                // 3. Đóng dialog thanh toán
                if (navigator.canPop()) {
                  navigator.pop();
                }

                // 4. Gọi Cubit để xử lý thanh toán
                try {
                  await billCubit.processPayment(
                    idHoadon: widget.bill.idHoadon,
                    phuongThuc: _selectedMethod,
                    chiSoDienMoi: widget.newElectricIndex,

                    // GỬI THÊM CÁC THAM SỐ MỚI
                    ngayThanhToan: ngayThanhToan,
                    tongTienDichVu: tongTienDichVu,
                    tongHopTien: tongHopTien,
                    ghiChu: ghiChu,
                  );

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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Màu chính
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Thanh toán", style: TextStyle(fontSize: 16)),
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

  Widget _buildNotesInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Ghi chú", style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          controller: _noteController,
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
