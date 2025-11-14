import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:motelapp/data/models/cost_model.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/cost/cost_cubit.dart';
import 'package:motelapp/logic/cubits/cost/cost_state.dart';
import 'package:motelapp/presentation/screens/cost/transaction_screen.dart';
import 'package:motelapp/router/app_router.dart';

class CostScreen extends StatefulWidget {
  const CostScreen({super.key});

  @override
  State<CostScreen> createState() => _CostScreenState();
}

class _CostScreenState extends State<CostScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('vi', null);
    context.read<CostCubit>().LoadListCost();
  }

  String _formatCurrency(double amount) {
    // Dùng NumberFormat đơn giản hơn
    return NumberFormat("#,##0", "vi_VN").format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final List<Tab> monthTabs = [];
    final now = DateTime.now();
    for (int i = 1; i <= 12; i++) {
      if (i == now.month) {
        monthTabs.add(
          const Tab(text: 'Tháng Này'), // Giữ nguyên thay đổi từ lần trước
        );
      } else {
        monthTabs.add(
          Tab(text: DateFormat('MM-yyyy').format(DateTime(now.year, i))),
        );
      }
    }

    return Stack(
      children: [
        DefaultTabController(
          length: monthTabs.length,
          initialIndex: now.month - 1,
          child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'Thu chi', // Cập nhật tiêu đề
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.white,
              centerTitle: true,
              elevation: 0,
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.filter_alt_outlined,
                    color: Colors.orange,
                  ),
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
                      return _buildDataMonth(currentMonth, currentYear);
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
        // // Nút cộng tuỳ chỉnh bằng Positioned
        // Positioned(
        //   bottom: 84,
        //   right: 24,
        //   child: GestureDetector(
        //     onTap: () {
        //       //getIt<AppRouter>().push(const ());
        //     },
        //     child: Container(
        //       width: 60,
        //       height: 60,
        //       decoration: const BoxDecoration(
        //         color: Colors.green,
        //         shape: BoxShape.circle,
        //         boxShadow: [
        //           BoxShadow(
        //             color: Colors.black26,
        //             blurRadius: 8,
        //             offset: Offset(2, 4),
        //           ),
        //         ],
        //       ),
        //       child: const Icon(Icons.add, color: Colors.white, size: 30),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildDataMonth(int month, int year) {
    return BlocBuilder<CostCubit, CostState>(
      builder: (context, state) {
        if (state.status == CostStatus.initial ||
            state.status == CostStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == CostStatus.error) {
          return Center(
            child: Text(state.errorMessage ?? 'Không thể tải dữ liệu'),
          );
        }

        if (state.status == CostStatus.loaded) {
          if (state.costModel == null || state.costModel!.isEmpty) {
            return const Center(child: Text('Không có giao dịch nào'));
          }

          // Lọc danh sách theo tháng
          final List<CostModel> monthlyCosts =
              state.costModel!.where((cost) {
                final paymentDate = DateTime.tryParse(cost.ngayThanhToan);
                if (paymentDate == null) return false;
                return paymentDate.month == month && paymentDate.year == year;
              }).toList();

          if (monthlyCosts.isEmpty) {
            return const Center(child: Text('Không có dữ liệu cho tháng này'));
          }

          // Tính tổng Tiền vào / Tiền ra
          double totalIncome = 0.0;
          double totalOutcome = 0.0; // API của bạn chưa có tiền ra

          for (var cost in monthlyCosts) {
            final amount = double.tryParse(cost.tongThu) ?? 0.0;
            if (amount >= 0) {
              totalIncome += amount;
            } else {
              totalOutcome += amount; // Dành cho tương lai nếu có
            }
          }

          // ----- THAY ĐỔI LỚN: NHÓM GIAO DỊCH THEO NGÀY -----
          final Map<String, List<CostModel>> groupedCosts = {};
          for (var cost in monthlyCosts) {
            // Lấy key là ngày (ví dụ: "2025-11-06")
            final dateKey = cost.ngayThanhToan.split('T')[0];
            if (groupedCosts[dateKey] == null) {
              groupedCosts[dateKey] = [];
            }
            groupedCosts[dateKey]!.add(cost);
          }
          // ----------------------------------------------------

          return Column(
            children: [
              // THAY ĐỔI: Thẻ Tóm tắt (giống ảnh)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow(
                        'Tổng Tiền Cần Thu',
                        totalIncome,
                        Colors.green,
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ),
              // Tab lồng nhau (List/Chart)
              DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      labelColor: Colors.green,
                      unselectedLabelColor: Colors.grey,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorColor: Colors.green,
                      dividerHeight: 0,
                      tabs: const [
                        Tab(icon: Icon(Icons.list)),
                        Tab(icon: Icon(Icons.show_chart)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      // Điều chỉnh chiều cao cho phù hợp
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: TabBarView(
                        children: [
                          // THAY ĐỔI: Trỏ đến Widget danh sách đã nhóm
                          _buildGroupedTransactionList(groupedCosts),
                          Center(
                            child: Text('Biểu đồ hoặc tổng quan tháng $month'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return const Center(child: Text('Trạng thái không xác định'));
      },
    );
  }

  // THAY ĐỔI: Widget mới để xây dựng danh sách đã nhóm
  Widget _buildGroupedTransactionList(
    Map<String, List<CostModel>> groupedCosts,
  ) {
    // Chuyển Map thành List để build
    final sortedEntries =
        groupedCosts.entries.toList()..sort(
          (a, b) => b.key.compareTo(a.key),
        ); // Sắp xếp ngày mới nhất lên trước

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: sortedEntries.length,
      itemBuilder: (context, index) {
        final entry = sortedEntries[index];
        final date = DateTime.parse(entry.key);
        final costsForDay = entry.value;

        // Tính tổng cho ngày này
        final double dailyTotal = costsForDay.fold(0.0, (sum, cost) {
          return sum + (double.tryParse(cost.tongThu) ?? 0.0);
        });

        // --- BẮT ĐẦU THAY ĐỔI ---
        // Bọc mọi thứ trong một Container có shadow
        return Container(
          margin: const EdgeInsets.symmetric(
            vertical: 8.0,
          ), // Khoảng cách giữa các ngày
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0), // Bo góc
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2), // Màu của bóng
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3), // Hướng đổ bóng
              ),
            ],
          ),
          child: Column(
            children: [
              // 1. Header của ngày (Bây giờ nằm trong Container)
              // Chúng ta dùng lại y hệt widget _buildDayHeader của bạn
              _buildDayHeader(date, dailyTotal),

              // Thêm đường kẻ ngang như trong ảnh
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Divider(height: 1, color: Colors.grey.shade300),
              ),

              // 2. Danh sách các giao dịch của ngày đó
              // Dùng Column vì đã ở trong Column rồi
              Column(
                children:
                    costsForDay.map((cost) {
                      // --- BẮT ĐẦU THAY ĐỔI ---
                      // Bọc item bằng InkWell để có thể nhấn
                      return InkWell(
                        onTap: () {
                          getIt<AppRouter>().push(
                            TransactionScreen(transactionId: cost.idHoaDon),
                          );
                        },
                        child: _buildTransactionItem(
                          cost,
                        ), // Widget item của bạn
                      );
                    }).toList(),
              ),
            ],
          ),
        );
        // --- KẾT THÚC THAY ĐỔI ---
      },
    );
  }

  // THAY ĐỔI: Widget mới cho 1 item giao dịch (BỎ CARD)
  Widget _buildTransactionItem(CostModel cost) {
    final double amount = double.tryParse(cost.tongThu) ?? 0.0;

    // THAY ĐỔI: Bỏ Card(), elevation, và margin.
    // Chỉ giữ lại Padding và nội dung bên trong.
    return Padding(
      padding: const EdgeInsets.all(16.0), // Thêm padding cho item
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Tiêu đề (như bạn yêu cầu)
                Text(
                  "Tiền hóa đơn phòng",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),

                // 2. Subtitle (lấy từ code của bạn)
                Text(
                  "${cost.tenPhong}, ${cost.tenToaNha}",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          // 3. Số tiền
          Text(
            _formatCurrency(amount),
            style: const TextStyle(
              color: Colors.black, // Màu đen như trong ảnh
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // THAY ĐỔI: Widget mới cho Header của ngày (Sửa Padding)
  Widget _buildDayHeader(DateTime date, double dailyTotal) {
    return Padding(
      // Sửa Padding từ symmetric(vertical: 8.0) thành EdgeInsets
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
      child: Row(
        children: [
          // Phần ngày tháng
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
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'tháng ${DateFormat('MM yyyy').format(date)}', // Tháng năm
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const Spacer(),
          // Tổng tiền của ngày
          Text(
            _formatCurrency(dailyTotal),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // THAY ĐỔI: Hàm build row cho thẻ tóm tắt (đã sửa)
  Widget _buildSummaryRow(
    String label,
    double? amount,
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
        if (amount != null) // Chỉ hiển thị tiền nếu có
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
}
