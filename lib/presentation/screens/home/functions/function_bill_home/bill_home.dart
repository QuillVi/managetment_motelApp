import 'package:flutter/material.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/presentation/screens/home/functions/function_bill_home/make_bill/make_bill.dart';
import 'package:motelapp/router/app_router.dart';

class BillHome extends StatefulWidget {
  const BillHome({super.key});

  @override
  State<BillHome> createState() => _BillHomeState();
}

class _BillHomeState extends State<BillHome> with TickerProviderStateMixin {
  late TabController _monthTabController;
  late List<String> monthLabels;
  late int currentMonthIndex;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    currentMonthIndex = now.month - 1;

    monthLabels = List.generate(12, (index) {
      return index == currentMonthIndex
          ? 'Tháng này'
          : '${(index + 1).toString().padLeft(2, '0')}-${now.year}';
    });

    _monthTabController = TabController(
      length: 12,
      vsync: this,
      initialIndex: currentMonthIndex,
    );
  }

  @override
  void dispose() {
    _monthTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              centerTitle: true,
              title: const Text(
                'Hoá đơn',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.filter_alt_outlined,
                    color: Colors.orange,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.black),
                  onPressed: () {},
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: TabBar(
                  isScrollable: true,
                  controller: _monthTabController,
                  indicatorColor: Colors.green,
                  labelColor: Colors.green,
                  unselectedLabelColor: Colors.black54,
                  dividerHeight: 0,
                  tabs: monthLabels.map((label) => Tab(text: label)).toList(),
                ),
              ),
            ),
            body: TabBarView(
              controller: _monthTabController,
              children: List.generate(12, (monthIndex) {
                return Column(
                  children: [
                    const TabBar(
                      isScrollable: true,
                      indicatorColor: Colors.green,
                      labelColor: Colors.green,
                      unselectedLabelColor: Colors.black,
                      dividerHeight: 0,
                      tabs: [
                        Tab(text: 'Chưa tạo hóa đơn  1'),
                        Tab(text: 'Chưa thanh toán  0'),
                        Tab(text: 'Quá hạn  0'),
                        Tab(text: 'Đã thanh toán  0'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: List.generate(4, (statusIndex) {
                          if (monthIndex == currentMonthIndex &&
                              statusIndex == 0) {
                            return _buildInvoiceList();
                          } else {
                            return _buildEmptyTab();
                          }
                        }),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          Positioned(
            bottom: 84,
            right: 24,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceList() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm theo tên',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                getIt<AppRouter>().push(MakeBill());
              },
              child: Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.home_outlined),
                  title: const Text('số 1 - vi'),
                  subtitle: const Text('huy'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'ĐÃ THUÊ',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTab() {
    return const Center(
      child: Text(
        'Không có dữ liệu',
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }
}
