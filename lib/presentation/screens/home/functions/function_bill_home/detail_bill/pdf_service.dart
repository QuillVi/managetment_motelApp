import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:motelapp/data/models/bill_model.dart'; // Giữ nguyên import của bạn
import 'package:flutter/services.dart' show rootBundle;
// BƯỚC 3: Import thư viện chuyển số
// THÊM DÒNG NÀY:
import 'package:number_to_vietnamese_words/number_to_vietnamese_words.dart';

// --- BƯỚC 1: Tải các font cần thiết (Regular và Bold) ---
// Tải font thường (Regular)
// Sửa đường dẫn trong hàm _getVietnameseFontRegular
Future<pw.Font> _getVietnameseFontRegular() async {
  try {
    // SỬA LẠI ĐƯỜNG DẪN Ở ĐÂY
    final fontData = await rootBundle.load(
      'lib/assets/fonts/Roboto-Regular.ttf',
    );
    return pw.Font.ttf(fontData);
  } catch (e) {
    print("LỖI: Không thể tải lib/assets/fonts/Roboto-Regular.ttf. $e");
    return pw.Font.helvetica();
  }
}

// Sửa đường dẫn trong hàm _getVietnameseFontBold
Future<pw.Font> _getVietnameseFontBold() async {
  try {
    // SỬA LẠI ĐƯỜNG DẪN Ở ĐÂY
    final fontData = await rootBundle.load('lib/assets/fonts/Roboto-Bold.ttf');
    return pw.Font.ttf(fontData);
  } catch (e) {
    print("LỖI: Không thể tải lib/assets/fonts/Roboto-Bold.ttf. $e");
    return pw.Font.helveticaBold();
  }
}
// ------------------------------------------------------------

// Hàm Định dạng Ngày An toàn (Giữ nguyên, hàm này đã tốt)
String _formatDateToMonthYear(DateTime? date) {
  if (date == null) {
    return 'XX-XXXX'; // Giá trị mặc định nếu null
  }
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  return '$month-$year';
}

// Hàm chuyển số thành chữ (Đã sửa bằng thư viện)
String convertNumberToVietnamese(double number) {
  final intValue = number.toInt();
  if (intValue == 0) {
    return "KHÔNG ĐỒNG";
  }
  // Thư viện sẽ chuyển, ví dụ: "năm triệu..."
  // .toUpperCase() để thành "NĂM TRIỆU..."
  return "${intValue.toVietnameseWords().toUpperCase()} ĐỒNG";
}

// Hàm này sẽ tạo PDF và trả về dữ liệu Byte
Future<Uint8List> generateBillPdf({
  required DetailBillModel bill,
  required bool isPaid,
}) async {
  // Load CẢ HAI font
  final vietnameseFontRegular = await _getVietnameseFontRegular();
  final vietnameseFontBold = await _getVietnameseFontBold();

  final pdf = pw.Document(
    theme: pw.ThemeData.withFont(
      base: vietnameseFontRegular, // Font thường
      bold: vietnameseFontBold, // Font đậm
    ),
  );

  // --- BƯỚC 2: Sửa lỗi Null Safety cho ngày tháng ---
  // Chuyển đổi String (có thể null) sang DateTime (có thể null)
  // DateTime.tryParse sẽ trả về null nếu String đầu vào là null hoặc không hợp lệ

  final DateTime? date = DateTime.tryParse(bill.ngayThang?.toString() ?? '');

  // Sử dụng hàm helper của bạn để tạo chuỗi ngày tháng an toàn
  final String formattedDate = _formatDateToMonthYear(date);
  // ----------------------------------------------------

  // --- LOGIC LỰA CHỌN TEMPLATE DỰA TRÊN isPaid ---

  if (isPaid) {
    // Template Dạng 2 (Đã thanh toán/Quá hạn)
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          // Truyền ngày tháng đã định dạng vào
          return buildPaidBillTemplate(bill, formattedDate);
        },
      ),
    );
  } else {
    // Template Dạng 1 (Chưa thanh toán)
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          // Truyền ngày tháng đã định dạng vào
          return buildUnpaidBillTemplate(bill, formattedDate);
        },
      ),
    );
  }

  return pdf.save();
}

// Sửa hàm để nhận 'formattedDate'
pw.Widget buildPaidBillTemplate(DetailBillModel bill, String formattedDate) {
  // Kịch bản ĐÃ THANH TOÁN
  return pw.Center(
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'HÓA ĐƠN TIỀN NHÀ: #${bill.idHoadon}',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          'Tháng: $formattedDate', // Sử dụng ngày tháng đã định dạng an toàn
          style: const pw.TextStyle(fontSize: 12),
        ),
        pw.Divider(),

        // Bảng tóm tắt (Mô phỏng)
        pw.Table.fromTextArray(
          headers: ['Dịch vụ', 'Thành tiền'],
          data: <List<String>>[
            ['Tiền phòng', (bill.giaPhong.toStringAsFixed(0))],
            ['Tổng tiền dịch vụ', (bill.tongTienDichVu.toStringAsFixed(0))],
          ],
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          cellAlignment: pw.Alignment.centerRight,
          columnWidths: {0: const pw.FlexColumnWidth(2)},
        ),

        pw.SizedBox(height: 10),
        pw.Text(
          'Tổng tạm tính: ${bill.tongHopTien.toStringAsFixed(0)}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.Text('Tiền cọc hợp đồng: ...'),
        pw.Text(
          'Tổng thanh toán: ${bill.tongHopTien.toStringAsFixed(0)}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.Text('Đã trả: ${bill.tongHopTien.toStringAsFixed(0)}'),
        pw.Text('Còn lại: 0'),
        pw.Text(
          'Bằng chữ: Không',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.red,
          ),
        ),

        pw.SizedBox(height: 20),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('Ngày ... tháng ... năm ...'),
        ),
      ],
    ),
  );
}

// Sửa hàm để nhận 'formattedDate'
pw.Widget buildUnpaidBillTemplate(DetailBillModel bill, String formattedDate) {
  // Kịch bản CHƯA THANH TOÁN
  return pw.Center(
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'HÓA ĐƠN TIỀN NHÀ: #${bill.idHoadon}',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          'Tháng: $formattedDate', // Sử dụng ngày tháng đã định dạng an toàn
          style: const pw.TextStyle(fontSize: 12),
        ),
        pw.Divider(),

        // Bảng tóm tắt (Mô phỏng)
        pw.Table.fromTextArray(
          headers: ['Dịch vụ', 'Thành tiền'],
          data: <List<String>>[
            ['Tiền phòng', (bill.giaPhong.toStringAsFixed(0))],
            ['Tổng tiền dịch vụ', (bill.tongTienDichVu.toStringAsFixed(0))],
          ],
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          cellAlignment: pw.Alignment.centerRight,
          columnWidths: {0: const pw.FlexColumnWidth(2)},
        ),

        pw.SizedBox(height: 10),
        pw.Text(
          'Tổng tạm tính: ${bill.tongHopTien.toStringAsFixed(0)}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.Text('Tiền cọc hợp đồng: ...'),
        pw.Text(
          'Tổng thanh toán: ${bill.tongHopTien.toStringAsFixed(0)}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.Text('Đã trả: 0'),
        pw.Text('Còn lại: ${bill.tongHopTien.toStringAsFixed(0)}'),
        // Hiển thị số tiền bằng chữ (đã sửa)
        pw.Text(
          'Bằng chữ: ${convertNumberToVietnamese(bill.tongHopTien)}',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),

        pw.SizedBox(height: 20),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('Ngày ... tháng ... năm ...'),
        ),
      ],
    ),
  );
}
