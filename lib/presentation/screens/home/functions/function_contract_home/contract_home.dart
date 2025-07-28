import 'package:flutter/material.dart';
import 'package:motelapp/presentation/screens/home/functions/function_contract_home/detail_contract/detail_contract.dart';

class ContractHome extends StatefulWidget {
  const ContractHome({super.key});

  @override
  State<ContractHome> createState() => _ContractHomeState();
}

class _ContractHomeState extends State<ContractHome> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              leading: const BackButton(color: Colors.black),
              centerTitle: true,
              title: const Text(
                'Hợp đồng',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.help_outline, color: Colors.orange),
                  onPressed: () {},
                ),
              ],
              backgroundColor: Colors.white,
              bottom: const TabBar(
                labelColor: Colors.green,
                unselectedLabelColor: Colors.black,
                indicatorColor: Colors.green,
                dividerHeight: 0,
                tabs: [
                  Tab(text: 'Đang hoạt động'),
                  Tab(text: 'Quá hạn'),
                  Tab(text: 'Đã thanh lý'),
                ],
              ),
            ),

            body: TabBarView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ListView.builder(
                    itemCount: 2,
                    itemBuilder: (context, index) {
                      return buildContractCard(context);
                    },
                  ),
                ),
                const Center(child: Text("Chưa có hợp đồng quá hạn")),
                const Center(child: Text("Chưa có hợp đồng thanh lý")),
              ],
            ),
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

  Widget buildContractCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DetailContract()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '#013351',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                children: const [
                  Icon(Icons.home_outlined, size: 18, color: Colors.grey),
                  SizedBox(width: 6),
                  Text('số 1 - vi'),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: const [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 6),
                  Text('Từ 23-03-2025 đến [Chưa xác định thời hạn]'),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: const [
                  Icon(Icons.person_outline, size: 18, color: Colors.grey),
                  SizedBox(width: 6),
                  Text('Người tạo: vi'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContractDetailScreen extends StatelessWidget {
  const ContractDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết hợp đồng')),
      body: const Center(child: Text('Thông tin chi tiết hợp đồng ở đây')),
    );
  }
}
