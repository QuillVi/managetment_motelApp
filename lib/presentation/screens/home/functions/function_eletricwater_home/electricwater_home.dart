import 'package:flutter/material.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/presentation/screens/home/functions/function_eletricwater_home/detail_electricwater/detail_eclectricwater.dart';
import 'package:motelapp/router/app_router.dart';

class ElectricwaterHome extends StatefulWidget {
  const ElectricwaterHome({super.key});

  @override
  State<ElectricwaterHome> createState() => _ElectricwaterHomeState();
}

class _ElectricwaterHomeState extends State<ElectricwaterHome> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          shadowColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Column(
            children: [
              const Text(
                'Chốt dịch vụ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '07-2025',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_today, color: Colors.orange),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.filter_alt_outlined, color: Colors.orange),
              onPressed: () {},
            ),
          ],
          bottom: TabBar(
            labelColor: Colors.green,
            unselectedLabelColor: Colors.black45,
            indicatorColor: Colors.green,
            indicatorWeight: 2,
            dividerHeight: 0,
            tabs: const [Tab(text: 'Chưa chốt'), Tab(text: 'Đã chốt')],
          ),
        ),

        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Tìm kiếm theo tên',
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
                children: [
                  _buildListTab(context),
                  Center(child: Text('Danh sách đã chốt')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const Text(
          'vi (1)',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
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
              getIt<AppRouter>().push(DetailEclectricwater());
            },
            child: Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.home, size: 20, color: Colors.grey),
                        const SizedBox(width: 6),
                        const Text(
                          'số 1  - vi',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        _buildStatusTag('Đã cọc', Colors.blue),
                        const SizedBox(width: 4),
                        _buildStatusTag('ĐÃ THUÊ', Colors.red),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Icon(
                          Icons.location_on_outlined,
                          size: 20,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'hhhh, Quận 8, Hồ Chí Minh',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }
}
