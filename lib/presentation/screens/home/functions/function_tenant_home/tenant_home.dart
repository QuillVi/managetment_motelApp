import 'package:flutter/material.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/presentation/screens/home/functions/function_tenant_home/detail_tenant/detail_tenant.dart';
import 'package:motelapp/router/app_router.dart';

class TenantHome extends StatefulWidget {
  const TenantHome({super.key});

  @override
  State<TenantHome> createState() => _TenantHomeState();
}

class _TenantHomeState extends State<TenantHome>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> myTabs = const [
    Tab(text: 'Đã có phòng'),
    Tab(text: 'Chưa có phòng'),
    Tab(text: 'Đã thanh lý'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: myTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            leading: const BackButton(color: Colors.black),
            title: const Text(
              'Người thuê',
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
              tabs: myTabs,
            ),
            actions: [
              IconButton(
                onPressed: () {
                  // Help icon action
                },
                icon: const Icon(Icons.help_outline, color: Colors.orange),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Tìm kiếm theo tên, sđt, phòng, toà nhà...',
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    ListView(children: [_buildTenantCard()]),
                    const Center(child: Text('Chưa có phòng')),
                    const Center(child: Text('Đã thôi')),
                  ],
                ),
              ),
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
}

Widget _buildTenantCard() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 14, offset: Offset(0, 6)),
      ],
    ),
    child: ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        backgroundColor: Colors.grey,
        child: Icon(Icons.person, color: Colors.white),
      ),
      title: const Text('huy', style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: const Text('số 1 - vi'),
      trailing: const Text('404640464', style: TextStyle(color: Colors.green)),
      onTap: () {
        getIt<AppRouter>().push(const DetailTenant());
      },
    ),
  );
}
