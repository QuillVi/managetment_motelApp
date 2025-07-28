import 'package:flutter/material.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/presentation/screens/home/functions/function_problem_home/detail_problem/detail_problem.dart';
import 'package:motelapp/router/app_router.dart';

class ProblemHome extends StatefulWidget {
  const ProblemHome({super.key});

  @override
  State<ProblemHome> createState() => _ProblemHomeState();
}

class _ProblemHomeState extends State<ProblemHome>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final tabs = const [Tab(text: "Đang yêu cầu"), Tab(text: "Hoàn thành")];

  @override
  void initState() {
    _tabController = TabController(length: tabs.length, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            leading: const BackButton(color: Colors.black),
            title: const Text(
              'Sự cố',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.green,
              unselectedLabelColor: Colors.black45,
              indicatorColor: Colors.green,
              indicatorWeight: 2,
              dividerHeight: 0,
              tabs: tabs,
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              /// Tab: Đang yêu cầu
              ListView(children: [_buildIssueCard()]),

              /// Tab: Hoàn thành
              const Center(child: Text("Chưa có sự cố hoàn thành")),
            ],
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
    );
  }

  Widget _buildIssueCard() {
    return GestureDetector(
      onTap: () {
        getIt<AppRouter>().push(const DetailProblem());
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Tiêu đề và độ ưu tiên
              Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.grey),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Máy lạnh hư',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Cao',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              /// Phòng
              Row(
                children: const [
                  Icon(Icons.home_outlined, size: 18, color: Colors.grey),
                  SizedBox(width: 6),
                  Text('số 1 - vi'),
                ],
              ),
              const SizedBox(height: 6),

              /// Địa chỉ
              Row(
                children: const [
                  Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 6),
                  Text('hhhh, Quận 8, Hồ Chí Minh'),
                ],
              ),
              const SizedBox(height: 6),

              /// Người báo
              Row(
                children: const [
                  Icon(Icons.person, size: 18, color: Colors.grey),
                  SizedBox(width: 6),
                  Text('vi'),
                ],
              ),
              const SizedBox(height: 10),

              /// Ngày
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  '23-03-2025',
                  style: TextStyle(
                    color: Colors.green[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
