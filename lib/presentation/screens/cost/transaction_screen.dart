import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:motelapp/data/models/cost_model.dart';
import 'package:motelapp/logic/cubits/cost/cost_cubit.dart';
import 'package:motelapp/logic/cubits/cost/cost_state.dart';

class TransactionScreen extends StatefulWidget {
  final int transactionId;
  const TransactionScreen({super.key, required this.transactionId});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // Khởi tạo định dạng ngày tháng cho tiếng Việt
    initializeDateFormatting('vi', null);

    //gọi api lấy dữ liệu ở cubit
    context.read<CostCubit>().loadCostDetail(widget.transactionId);
  }

  // Helper để định dạng tiền tệ
  String _formatCurrency(double amount) {
    return NumberFormat("#,##0", "vi_VN").format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Màu nền xám nhạt
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Giao dịch', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.orange),
            onPressed: () {
              // Xử lý sự kiện nhấn nút sửa
            },
          ),
        ],
      ),
      body: BlocBuilder<CostCubit, CostState>(
        builder: (context, state) {
          // 1. Trạng thái Loading
          if (state.status == CostStatus.initial ||
              state.status == CostStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Trạng thái Error
          if (state.status == CostStatus.error) {
            return Center(child: Text(state.errorMessage ?? 'Lỗi tải dữ liệu'));
          }

          // 3. Trạng thái Loaded (Thành công)
          if (state.status == CostStatus.loaded &&
              state.costDetailModel != null) {
            // Lấy dữ liệu chi tiết
            final costDetail = state.costDetailModel!;

            // Trả về UI chính của bạn
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Truyền dữ liệu vào thẻ
                        _buildTransactionCard(costDetail),
                        const SizedBox(height: 24),
                        _buildImageSection(), // Phần này giữ nguyên
                      ],
                    ),
                  ),
                ),
                _buildDeleteButton(), // Nút Xoá giữ nguyên
                const SizedBox(height: 16),
              ],
            );
          }

          // 4. Trạng thái dự phòng
          return const Center(child: Text('Không có dữ liệu chi tiết.'));
        },
      ),
    );
  }

  // ----- Widget nhận vào CostDetailModel -----
  Widget _buildTransactionCard(CostDetailModel costDetail) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Truyền dữ liệu vào header
          _buildDayHeader(costDetail),
          Divider(height: 24, color: Colors.grey.shade300),
          // ----- Dữ liệu động -----
          _buildDetailRow('Nhóm', 'Khoản thu'), // Giữ cố định
          _buildDetailRow('Loại', 'Tiền hóa đơn phòng'), // Giữ cố định
          _buildDetailRow(
            'Thanh toán',
            costDetail.phuongThucThanhToan ?? 'Chưa thanh toán',
          ),
          _buildDetailRow('Hóa đơn', '#${costDetail.idHoaDon}', isLink: true),
          _buildDetailRow(
            'Phòng',
            '${costDetail.tenPhong}, ${costDetail.tenToaNha}',
          ),
          _buildDetailRow('Người nộp tiền', costDetail.tenNguoiThanhToan),
          _buildDetailRow('Ghi chú', costDetail.ghiChuHoaDon ?? '-'),
        ],
      ),
    );
  }

  // ----- Widget nhận vào CostDetailModel -----
  Widget _buildDayHeader(CostDetailModel costDetail) {
    // Parse dữ liệu từ model
    final DateTime date =
        DateTime.tryParse(costDetail.ngayThanhToan) ?? DateTime.now();
    final double dailyTotal = double.tryParse(costDetail.tongHopTien) ?? 0.0;

    return Row(
      children: [
        Text(
          DateFormat('dd').format(date),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE', 'vi').format(date), // Thứ
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              'tháng ${DateFormat('MM yyyy').format(date)}', // Tháng năm
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        const Spacer(),
        Text(
          _formatCurrency(dailyTotal),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ----- Widget này giữ nguyên -----
  Widget _buildDetailRow(String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          Flexible(
            // Thêm Flexible để text không bị tràn
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isLink ? Colors.blue : Colors.black,
                decoration:
                    isLink ? TextDecoration.underline : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----- Widget này giữ nguyên -----
  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ảnh giao dịch',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Center(
            child: Text(
              'Dữ liệu trống',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  // ----- Widget này giữ nguyên -----
  Widget _buildDeleteButton() {
    return Padding(
      // Bọc trong Padding để nút không chạm cạnh
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(8.0), // Bo góc
          border: Border.all(color: Colors.red.shade700, width: 1.5), // Border
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3), // Màu đổ bóng từ màu nút
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4), // Đổ bóng xuống dưới
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8.0),
            onTap: () {
              // Xử lý sự kiện xoá
              print('Nút Xoá được nhấn');
            },
            child: const Center(
              child: Text(
                'Xoá',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
