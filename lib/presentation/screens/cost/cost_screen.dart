import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CostScreen extends StatefulWidget {
  const CostScreen({super.key});

  @override
  State<CostScreen> createState() => _CostScreenState();
}

class _CostScreenState extends State<CostScreen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> transactions = [
    {
      "date": "24",
      "weekday": "Thứ Hai",
      "monthYear": "tháng 3 2025",
      "title": "Trả nợ",
      "room": "số 1 , ví",
      "amount": -3000000.0,
    },
    {
      "date": "23",
      "weekday": "Chủ Nhật",
      "monthYear": "tháng 3 2025",
      "title": "Thu nợ",
      "room": "số 1 , ví",
      "amount": 3000000.0,
    },
    {
      "date": "22",
      "weekday": "Thứ Bảy",
      "monthYear": "tháng 3 2025",
      "title": "Thu nợ",
      "room": "số 1 , ví",
      "amount": 3333333.0,
    },
    {
      "date": "21",
      "weekday": "Thứ Sáu",
      "monthYear": "tháng 3 2025",
      "title": "Tiền cọc phòng",
      "room": "số 1 , ví",
      "amount": 3000000.0,
    },
    {
      "date": "20",
      "weekday": "Thứ Năm",
      "monthYear": "tháng 3 2025",
      "title": "Trả tiền điện",
      "room": "số 2 , ví",
      "amount": -500000.0,
    },
    {
      "date": "19",
      "weekday": "Thứ Tư",
      "monthYear": "tháng 3 2025",
      "title": "Thu tiền nước",
      "room": "số 3 , ví",
      "amount": 200000.0,
    },
  ];

  // Không cần _transactionTypeTabController nữa vì chúng ta sẽ dùng DefaultTabController lồng nhau.
  // late TabController _transactionTypeTabController;

  @override
  void initState() {
    super.initState();
    // Không cần khởi tạo TabController ở đây nữa
    // _transactionTypeTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    // Cũng không cần dispose nữa
    // _transactionTypeTabController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'vi',
      symbol: 'đ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final List<Tab> monthTabs = [];
    final now = DateTime.now();
    for (int i = 1; i <= 12; i++) {
      monthTabs.add(
        Tab(text: DateFormat('MM-yyyy').format(DateTime(now.year, i))),
      );
    }

    final double totalIncome = transactions
        .where((t) => (t["amount"] as num) > 0)
        .fold(0.0, (sum, t) => sum + (t["amount"] as num).toDouble());
    final double totalOutcome = transactions
        .where((t) => (t["amount"] as num) < 0)
        .fold(0.0, (sum, t) => sum + (t["amount"] as num).toDouble());

    return DefaultTabController(
      // DefaultTabController chính cho các tháng
      length: monthTabs.length,
      initialIndex: now.month - 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thu chi', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.filter_alt_outlined, color: Colors.orange),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert, color: Colors.grey),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            labelColor: Colors.green,
            unselectedLabelColor: Colors.black45,
            indicatorColor: Colors.green,
            indicatorWeight: 2,
            dividerHeight: 0,
            tabs: monthTabs,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: List.generate(monthTabs.length, (index) {
                  final currentMonth = index + 1;
                  final currentYear = now.year;
                  // Gọi phương thức _buildDataMonth
                  return _buildDataMonth(currentMonth, currentYear);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataMonth(int month, int year) {
    // Tính toán tổng tiền vào và tiền ra
    // Trong thực tế, bạn sẽ lọc transactions dựa trên month và year
    // hoặc lấy dữ liệu đã được lọc từ một nguồn khác.
    // Ví dụ này đang sử dụng toàn bộ transactions mẫu, bạn sẽ cần điều chỉnh.
    final double totalIncome = transactions
        .where((t) => (t["amount"] as num) > 0)
        .fold(0.0, (sum, t) => sum + (t["amount"] as num).toDouble());

    final double totalOutcome = transactions
        .where((t) => (t["amount"] as num) < 0)
        .fold(0.0, (sum, t) => sum + (t["amount"] as num).toDouble());

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Income/Outcome Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildSummaryRow("Tiền vào", totalIncome, Colors.green),
                  const SizedBox(height: 8),
                  _buildSummaryRow("Tiền ra", totalOutcome.abs(), Colors.red),
                  const Divider(height: 16, thickness: 1, color: Colors.green),
                  _buildSummaryRow(
                    "Tổng",
                    totalIncome + totalOutcome,
                    Colors.green,
                    isBold: true,
                    fontSize: 18,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // DefaultTabController lồng nhau cho các tab loại giao dịch
            DefaultTabController(
              length: 2, // 2 tab: list và icon
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TabBar(
                          isScrollable: true,
                          labelColor: Colors.green,
                          unselectedLabelColor: Colors.grey,
                          indicatorSize: TabBarIndicatorSize.label,
                          indicatorColor: Colors.green,
                          tabs: const [
                            Tab(icon: Icon(Icons.list)),
                            Tab(icon: Icon(Icons.show_chart)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: TabBarView(
                      children: [
                        _buildTransactionList(
                          transactions,
                        ), // Vẫn dùng transactions mẫu, bạn cần lọc theo tháng
                        Center(
                          child: Text('Biểu đồ hoặc tổng quan tháng $month'),
                        ), // Hiển thị tháng
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount,
    Color color, {
    bool isBold = false,
    double fontSize = 16,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
        Text(
          _formatCurrency(amount),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList(
    List<Map<String, dynamic>> transactionsToDisplay,
  ) {
    return ListView.builder(
      physics:
          const NeverScrollableScrollPhysics(), // Vô hiệu hóa cuộn của ListView con
      itemCount: transactionsToDisplay.length,
      itemBuilder: (context, idx) {
        final transaction = transactionsToDisplay[idx];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      transaction["date"].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      transaction["weekday"].toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      transaction["monthYear"].toString(),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction["title"].toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        transaction["room"].toString(),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "${(transaction["amount"] as num) > 0 ? '+' : ''}${_formatCurrency((transaction["amount"] as num).toDouble()).toString()}",
                  style: TextStyle(
                    color:
                        (transaction["amount"] as num) > 0
                            ? Colors.green
                            : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
