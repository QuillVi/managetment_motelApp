import 'package:flutter/material.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/presentation/screens/home/functions/function_stake_home/detail_stake/detail_stake.dart';
import 'package:motelapp/router/app_router.dart';

class StakeHome extends StatefulWidget {
  const StakeHome({super.key});

  @override
  State<StakeHome> createState() => _StakeHomeState();
}

class _StakeHomeState extends State<StakeHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Cọc giữ chỗ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: const BackButton(color: Colors.black),
        actions: const [
          Icon(Icons.filter_alt_outlined, color: Colors.orange),
          SizedBox(width: 16),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),

          /// Thống kê trạng thái
          _buildSummaryStatus(),

          /// Tabs
          const SizedBox(height: 12),
          const _TabRow(),

          /// Ô tìm kiếm
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo số hoá đơn, phòng...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// Danh sách cọc giữ chỗ
          Expanded(child: _buildDepositCard()),
        ],
      ),
    );
  }

  /// Widget: Thống kê trạng thái cọc
  Widget _buildSummaryStatus() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFDFF5DC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            _SummaryItem(
              title: 'Đang chờ',
              value: '0 cọc - 0 đ',
              color: Colors.green,
            ),
            _SummaryItem(
              title: 'Quá hạn',
              value: '1 cọc - 3.000.000 đ',
              color: Colors.red,
            ),
            _SummaryItem(
              title: 'Khách huỷ cọc',
              value: '0 cọc - 0 đ',
              color: Colors.orange,
            ),
            _SummaryItem(
              title: 'Đã tạo hợp đồng',
              value: '0 cọc - 0 đ',
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  /// Widget: Card item cọc giữ chỗ
  Widget _buildDepositCard() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        GestureDetector(
          onTap: () {
            getIt<AppRouter>().push(DetailStake());
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Tên người
                  const Text(
                    'vi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  /// Phòng
                  Row(
                    children: const [
                      Icon(Icons.home_outlined, size: 18, color: Colors.grey),
                      SizedBox(width: 6),
                      Text('số 1 - vi'),
                    ],
                  ),
                  const SizedBox(height: 6),

                  /// Ngày hẹn vào
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 6),
                          Text('Ngày hẹn vào'),
                        ],
                      ),
                      Text(
                        '23-03-2025',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// Giá tiền
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '3.000.000 đ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget: Một mục thống kê nhỏ
class _SummaryItem extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Widget: Tabs (Chờ phòng - Quá hạn - Khách huỷ - Đã tạo...)
class _TabRow extends StatelessWidget {
  const _TabRow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: DefaultTabController(
        length: 4,
        child: TabBar(
          indicatorColor: Colors.green,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          isScrollable: true,
          tabs: [
            Tab(text: 'Chờ phòng'),
            Tab(text: 'Quá hạn'),
            Tab(text: 'Khách huỷ cọc'),
            Tab(text: 'Đã tạo hợp đồng'),
          ],
        ),
      ),
    );
  }
}
