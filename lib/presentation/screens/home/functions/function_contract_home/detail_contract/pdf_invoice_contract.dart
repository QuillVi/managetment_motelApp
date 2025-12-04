import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:motelapp/data/models/contract_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfInvoiceContract {
  // Hàm chính để tạo và hiển thị PDF
  Future<void> printContract(DetailContractModel contract) async {
    // 1. Load Font Tiếng Việt (BẮT BUỘC)
    final fontDataRegular = await rootBundle.load(
      "lib/assets/fonts/Roboto-Regular.ttf",
    );
    final fontDataBold = await rootBundle.load(
      "lib/assets/fonts/Roboto-Bold.ttf",
    );

    final ttfRegular = pw.Font.ttf(fontDataRegular);
    final ttfBold = pw.Font.ttf(fontDataBold);

    // 2. Khởi tạo tài liệu PDF
    final doc = pw.Document();

    // 3. Lấy người đại diện thuê (Người đầu tiên trong danh sách)
    final representative =
        contract.listNguoiThue.isNotEmpty ? contract.listNguoiThue.first : null;

    // 4. Vẽ trang PDF
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40), // Căn lề 4 phía
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- HEADER QUỐC HIỆU ---
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'CỘNG HÒA XÃ HỘI CHỦ NGHĨA VIỆT NAM',
                      style: pw.TextStyle(font: ttfBold, fontSize: 14),
                    ),
                    pw.Text(
                      'Độc lập – Tự do – Hạnh phúc',
                      style: pw.TextStyle(
                        font: ttfRegular,
                        fontSize: 12,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Container(
                      height: 1,
                      width: 100,
                      color: PdfColors.black,
                    ), // Đường gạch chân
                    pw.SizedBox(height: 15),
                    pw.Text(
                      'HỢP ĐỒNG THUÊ PHÒNG TRỌ',
                      style: pw.TextStyle(font: ttfBold, fontSize: 18),
                    ),
                    pw.SizedBox(height: 20),
                  ],
                ),
              ),

              pw.Text(
                'Chúng tôi gồm:',
                style: pw.TextStyle(font: ttfBold, fontSize: 12),
              ),
              pw.SizedBox(height: 10),

              // --- BÊN A (CHỦ NHÀ) ---
              _buildSectionTitle(ttfBold, '1. Đại diện bên cho thuê (Bên A):'),
              _buildInfoRow(ttfRegular, 'Ông/bà:', contract.tenNguoiTao),
              _buildInfoRow(
                ttfRegular,
                'Sinh ngày:',
                _formatDate(contract.ngaySinhChuNha),
              ),
              _buildInfoRow(
                ttfRegular,
                'Nơi đăng ký HK:',
                contract.hkThuongTruChuNha ?? '...',
              ),
              _buildInfoRow(
                ttfRegular,
                'CMND/CCCD số:',
                '${contract.cccdChuNha ?? '...'} cấp ngày ${_formatDate(contract.ngayCapChuNha)} tại ${contract.noiCapChuNha ?? '...'}',
              ),
              _buildInfoRow(
                ttfRegular,
                'Số điện thoại:',
                contract.sdtChuNha ?? '...',
              ),

              pw.SizedBox(height: 15),

              // --- BÊN B (NGƯỜI THUÊ) ---
              _buildSectionTitle(ttfBold, '2. Bên thuê (Bên B):'),
              if (representative != null) ...[
                _buildInfoRow(
                  ttfRegular,
                  'Ông/bà:',
                  representative.tenNguoiThue,
                ),
                _buildInfoRow(
                  ttfRegular,
                  'Sinh ngày:',
                  _formatDate(representative.ngaySinh),
                ),
                _buildInfoRow(
                  ttfRegular,
                  'Nơi đăng ký HK:',
                  representative.hkThuongTru ?? '...',
                ),
                _buildInfoRow(
                  ttfRegular,
                  'Số CMND/CCCD:',
                  '${representative.cccd ?? '...'} cấp ngày ${_formatDate(representative.ngayCap)} tại ${representative.noiCap ?? '...'}',
                ),
                _buildInfoRow(
                  ttfRegular,
                  'Số điện thoại:',
                  representative.soDienThoai ?? '...',
                ),
              ] else ...[
                pw.Text(
                  '(Chưa có thông tin người thuê)',
                  style: pw.TextStyle(font: ttfRegular, color: PdfColors.red),
                ),
              ],

              pw.SizedBox(height: 15),

              // --- NỘI DUNG THỎA THUẬN ---
              pw.Text(
                'Sau khi bàn bạc trên tinh thần dân chủ, hai bên cùng có lợi, cùng thống nhất như sau:',
                style: pw.TextStyle(
                  font: ttfRegular,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
              pw.SizedBox(height: 10),

              // Dòng địa chỉ động
              pw.RichText(
                text: pw.TextSpan(
                  style: pw.TextStyle(font: ttfRegular),
                  children: [
                    const pw.TextSpan(
                      text: 'Bên A đồng ý cho bên B thuê 01 phòng ',
                    ),
                    pw.TextSpan(
                      text: contract.tenPhong,
                      style: pw.TextStyle(font: ttfBold),
                    ),
                    const pw.TextSpan(text: ' tại địa chỉ: '),
                    pw.TextSpan(
                      text: contract.diaChiToaNha,
                      style: pw.TextStyle(font: ttfBold),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 5),
              _buildInfoRow(
                ttfRegular,
                'Giá thuê:',
                '${_formatCurrency(contract.tienPhong)}/tháng',
              ),
              _buildInfoRow(
                ttfRegular,
                'Tiền đặt cọc:',
                _formatCurrency(contract.tienCoc),
              ),
              _buildInfoRow(
                ttfRegular,
                'Hình thức thanh toán:',
                'Theo ${_getKyThanhToan(contract.kyThanhToan)}',
              ),

              pw.SizedBox(height: 10),
              pw.Text('Dịch vụ phòng:', style: pw.TextStyle(font: ttfBold)),
              pw.Bullet(
                text: 'Điện: 3,500đ/kwh tính theo chỉ số công tơ',
                style: pw.TextStyle(font: ttfRegular),
              ),
              pw.Bullet(
                text: 'Nước: 100,000đ/người/tháng',
                style: pw.TextStyle(font: ttfRegular),
              ),

              // Nếu bạn có API dịch vụ thì map vào đây
              pw.SizedBox(height: 10),
              pw.Text(
                'Hợp đồng có giá trị kể từ ngày ${_formatDate(contract.ngayBatDau)} thời hạn ${contract.thoiHan} tháng.',
                style: pw.TextStyle(font: ttfRegular),
              ),

              pw.SizedBox(height: 10),
              pw.Text('TRÁCH NHIỆM CHUNG:', style: pw.TextStyle(font: ttfBold)),
              pw.Text(
                '- Hợp đồng được lập thành 02 bản có giá trị pháp lý như nhau, mỗi bên giữ một bản.',
                style: pw.TextStyle(font: ttfRegular),
              ),

              pw.Spacer(), // Đẩy phần chữ ký xuống dưới cùng nếu còn chỗ trống
              // --- CHỮ KÝ ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Text(
                        'ĐẠI DIỆN BÊN B',
                        style: pw.TextStyle(font: ttfBold),
                      ),
                      pw.Text(
                        '(Ký và ghi rõ họ tên)',
                        style: pw.TextStyle(
                          font: ttfRegular,
                          fontSize: 10,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                      pw.SizedBox(height: 60),
                      pw.Text(
                        representative?.tenNguoiThue ?? '',
                        style: pw.TextStyle(font: ttfBold),
                      ),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text(
                        '.........., ngày ... tháng ... năm ....',
                        style: pw.TextStyle(
                          font: ttfRegular,
                          fontSize: 10,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                      pw.Text(
                        'ĐẠI DIỆN BÊN A',
                        style: pw.TextStyle(font: ttfBold),
                      ),
                      pw.Text(
                        '(Ký và ghi rõ họ tên)',
                        style: pw.TextStyle(
                          font: ttfRegular,
                          fontSize: 10,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                      pw.SizedBox(height: 60),
                      pw.Text(
                        contract.tenNguoiTao,
                        style: pw.TextStyle(font: ttfBold),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // 5. Hiển thị Preview
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'HopDong_${contract.tenPhong}.pdf', // Tên file khi lưu
    );
  }

  // --- CÁC HÀM HELPER ---

  // Helper: Format ngày (yyyy-MM-dd -> dd/MM/yyyy)
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '...';
    try {
      // Xử lý trường hợp API trả về datetime có giờ phút (ví dụ: 2025-11-21T00:00:00Z)
      DateTime date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  // Helper: Format tiền (4000000 -> 4,000,000 đ)
  String _formatCurrency(String value) {
    try {
      final double number = double.parse(value);
      return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(number);
    } catch (e) {
      return '$value đ';
    }
  }

  // Helper: Mapping kỳ thanh toán
  String _getKyThanhToan(String key) {
    switch (key) {
      case 'Thang':
        return 'tháng';
      case 'Quy':
        return 'quý';
      case 'Nam':
        return 'năm';
      default:
        return key;
    }
  }

  // Helper: Widget vẽ dòng thông tin cho gọn code
  pw.Widget _buildInfoRow(pw.Font font, String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 110, // Độ rộng cố định cho nhãn để thẳng hàng
            child: pw.Text(label, style: pw.TextStyle(font: font)),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSectionTitle(pw.Font font, String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 5, bottom: 5),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          font: font,
          fontWeight: pw.FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}
