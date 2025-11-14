import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Nếu text mới rỗng, trả về giá trị rỗng
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Xoá tất cả ký tự không phải là số (bao gồm cả dấu chấm cũ)
    String newText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Nếu không còn số nào, trả về rỗng
    if (newText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Parse số
    final number = int.tryParse(newText);

    if (number == null) {
      // Nếu không parse được, giữ giá trị cũ
      return oldValue;
    }

    // Định dạng số với locale 'vi_VN' (dùng dấu chấm)
    final formatter = NumberFormat.decimalPattern('vi_VN');
    final newString = formatter.format(number);

    // Trả về TextEditingValue mới với text đã định dạng
    // và đặt con trỏ ở cuối
    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}
