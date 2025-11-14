import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MakeBill extends StatefulWidget {
  const MakeBill({super.key});

  @override
  State<MakeBill> createState() => _MakeBillState();
}

class _MakeBillState extends State<MakeBill> {
  String selectedMonthYear = '11-2024';
  DateTime? _paymentDate;
  DateTime? _dueDate;

  void _showDatePicker({
    required DateTime? initialDate,
    required Function(DateTime) onDateSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Chọn ngày', style: TextStyle(fontSize: 16)),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Xong',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initialDate ?? DateTime.now(),
                  maximumDate: DateTime(2100),
                  minimumYear: 2000,
                  onDateTimeChanged: onDateSelected,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMonthYearPicker() {
    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;

    final monthController = FixedExtentScrollController(
      initialItem: currentMonth - 1,
    );
    final yearList = List.generate(10, (index) => 2020 + index);
    final yearController = FixedExtentScrollController(initialItem: 4);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Chọn thời gian',
                      style: TextStyle(fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () {
                        final selected =
                            '${(monthController.selectedItem + 1).toString().padLeft(2, '0')}-${yearList[yearController.selectedItem]}';
                        Navigator.pop(context);
                        setState(() {
                          selectedMonthYear = selected;
                        });
                      },
                      child: const Text(
                        'Chọn',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: monthController,
                        itemExtent: 40,
                        children: List.generate(
                          12,
                          (index) => Center(child: Text('Tháng ${index + 1}')),
                        ),
                        onSelectedItemChanged: (_) {},
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: yearController,
                        itemExtent: 40,
                        children:
                            yearList
                                .map((y) => Center(child: Text('$y')))
                                .toList(),
                        onSelectedItemChanged: (_) {},
                      ),
                    ),
                  ],
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(color: Colors.black),
          title: const Text(
            'Lập hoá đơn',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.green,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            dividerHeight: 0,
            tabs: [Tab(text: 'Theo chu kỳ'), Tab(text: 'Tuỳ chọn thời gian')],
          ),
        ),
        body: TabBarView(
          children: [
            _CreateCycleTab(
              selectedMonthYear: selectedMonthYear,
              onMonthTap: _showMonthYearPicker,
              paymentDate: _paymentDate,
              dueDate: _dueDate,
              onPickPaymentDate: (date) {
                setState(() {
                  _paymentDate = date;
                });
              },
              onPickDueDate: (date) {
                setState(() {
                  _dueDate = date;
                });
              },
              showDatePicker: _showDatePicker,
            ),

            const Center(child: Text('Tuỳ chọn thời gian')),
          ],
        ),
      ),
    );
  }
}

class _CreateCycleTab extends StatelessWidget {
  final String selectedMonthYear;
  final VoidCallback onMonthTap;
  final DateTime? paymentDate;
  final DateTime? dueDate;
  final Function(DateTime) onPickPaymentDate;
  final Function(DateTime) onPickDueDate;
  final void Function({
    required DateTime? initialDate,
    required Function(DateTime) onDateSelected,
  })
  showDatePicker;

  const _CreateCycleTab({
    required this.selectedMonthYear,
    required this.onMonthTap,
    required this.paymentDate,
    required this.dueDate,
    required this.onPickPaymentDate,
    required this.onPickDueDate,
    required this.showDatePicker,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionTitle('Thông tin'),
        _formField(
          'Hoá đơn tiền nhà tháng *',
          selectedMonthYear,
          onTap: onMonthTap,
        ),
        _formField('Chọn phòng *', 'Chọn phòng', isGray: true),
        Row(
          children: [
            Expanded(
              child: _formField(
                'Ngày thanh toán *',
                paymentDate != null ? _formatDate(paymentDate!) : 'Chọn ngày',
                onTap:
                    () => showDatePicker(
                      onDateSelected: onPickPaymentDate,
                      initialDate: paymentDate,
                    ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _formField(
                'Hạn thanh toán *',
                dueDate != null ? _formatDate(dueDate!) : 'Chọn ngày',
                onTap:
                    () => showDatePicker(
                      initialDate: dueDate,
                      onDateSelected: onPickDueDate,
                    ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        _sectionTitle('Tiền phòng'),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _formField(
                'Khoảng thời gian',
                paymentDate != null ? _formatDate(paymentDate!) : 'Chọn ngày',
                onTap:
                    () => showDatePicker(
                      onDateSelected: onPickPaymentDate,
                      initialDate: paymentDate,
                    ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _formField(
                '',
                dueDate != null ? _formatDate(dueDate!) : 'Chọn ngày',
                onTap:
                    () => showDatePicker(
                      initialDate: dueDate,
                      onDateSelected: onPickDueDate,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(child: Text('Tiền Phòng')),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.green),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _sectionTitle('Tiền cọc'),
        const SizedBox(height: 12),
        Row(
          children: [
            const Expanded(child: Text('Tiền cọc hợp đồng')),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.green),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Expanded(child: Text('Tiền cọc giữ chỗ (Đã thanh toán)')),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.green),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
        _sectionTitle('Dịch vụ'),
        // Bạn có thể thêm list dịch vụ tại đây
        const SizedBox(height: 16),
        _sectionTitle('Tổng hợp'),
        const SizedBox(height: 12),

        _summaryRow('Tiền phòng', '0'),

        _summaryRow('Dịch vụ', '0'),
        _summaryRow('Tổng', '0'),
        _summaryRow('Khách trả thêm/phạt', '0'),
        _summaryRow('Cọc hợp đồng', '0'),
        _summaryRow('Cọc giữ chỗ', '0'),
        _summaryRow('Giảm giá', '0', color: Colors.red),
        const Divider(height: 32, thickness: 1),
        _summaryRow('Thanh toán', '0 đ', isTotal: true),
        const SizedBox(height: 16),
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
            maxLines: 3,
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
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {},
            child: const Text(
              'Lập hoá đơn',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.year}';
}

Widget _sectionTitle(String title) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.green.shade400,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
    ),
    child: Text(
      title,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  );
}

Widget _formField(
  String label,
  String value, {
  bool showCalendar = false,
  bool isGray = false,
  VoidCallback? onTap,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 12),
      Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      const SizedBox(height: 4),
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: isGray ? Colors.grey.shade200 : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(color: isGray ? Colors.grey : Colors.black),
              ),
              if (showCalendar)
                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
              if (!showCalendar && onTap != null)
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget _summaryRow(
  String label,
  String value, {
  Color? color,
  bool isTotal = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: color ?? Colors.black,
          ),
        ),
      ],
    ),
  );
}
