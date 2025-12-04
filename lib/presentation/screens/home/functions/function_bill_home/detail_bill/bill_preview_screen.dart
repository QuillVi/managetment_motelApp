import 'package:flutter/material.dart';
import 'package:motelapp/presentation/screens/home/functions/function_bill_home/detail_bill/pdf_service.dart';
import 'package:printing/printing.dart'; // <--- 1. Import package printing
import 'package:pdf/pdf.dart';

// 2. Import 2 file của bạn
import 'package:motelapp/data/models/bill_model.dart';

class BillPreviewScreen extends StatelessWidget {
  final DetailBillModel bill;
  final bool isPaid;

  const BillPreviewScreen({
    super.key,
    required this.bill,
    required this.isPaid,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Xem trước Hóa đơn #${bill.idHoadon}')),
      // 3. Dùng Widget PdfPreview
      body: PdfPreview(
        // 4. Chỉ cần truyền hàm generateBillPdf của bạn vào đây
        build:
            (PdfPageFormat format) =>
                generateBillPdf(bill: bill, isPaid: isPaid),
      ),
    );
  }
}
