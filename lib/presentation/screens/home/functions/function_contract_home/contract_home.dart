import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/models/contract_model.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/home/contract_home/contract_cubit.dart';
import 'package:motelapp/logic/cubits/home/contract_home/contract_state.dart';
import 'package:motelapp/presentation/screens/buttonNavicationBar/buttonNavicationBar.dart';
import 'package:motelapp/presentation/screens/home/functions/function_contract_home/detail_contract/detail_contract.dart';
import 'package:motelapp/router/app_router.dart';

class ContractHome extends StatefulWidget {
  const ContractHome({super.key});

  @override
  State<ContractHome> createState() => _ContractHomeState();
}

class _ContractHomeState extends State<ContractHome> {
  @override
  void initState() {
    super.initState();

    // //load cubit list contract is active
    context.read<ListContractCubit>().LoadListContract();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed:
                    () => getIt<AppRouter>().push(const Buttonnavicationbar()),
              ),
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
                  Tab(text: 'Hết hạn'),
                  Tab(text: 'Đã thanh lý'),
                ],
              ),
            ),

            body: BlocBuilder<ListContractCubit, ListContractState>(
              builder: (context, state) {
                // 1. Trạng thái Loading
                if (state.status == ListContractIsActiveStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2. Trạng thái Error
                if (state.status == ListContractIsActiveStatus.error) {
                  print('Lỗi: ${state.errorMessage}');
                  return Center(child: Text('Lỗi: ${state.errorMessage}'));
                }

                // 3. Trạng thái Loaded
                if (state.status == ListContractIsActiveStatus.loaded &&
                    state.listContractModel != null) {
                  // Lấy danh sách tổng
                  final allContracts = state.listContractModel!;

                  // Nếu danh sách tổng rỗng
                  if (allContracts.isEmpty) {
                    return const Center(
                      child: Text('Không có dữ liệu hợp đồng'),
                    );
                  }

                  // Lọc danh sách cho 3 tab
                  final activeContracts =
                      allContracts
                          .where((c) => c.trang_thai == 'DangHoatDong')
                          .toList();
                  final expiredContracts =
                      allContracts
                          .where((c) => c.trang_thai == 'HetHan')
                          .toList();
                  final liquidatedContracts =
                      allContracts
                          .where((c) => c.trang_thai == 'DaThanhLy')
                          .toList();

                  // Hiển thị TabBarView với 3 danh sách đã lọc
                  return TabBarView(
                    children: [
                      // Tab 1: Đang hoạt động
                      _buildContractListView(
                        contracts: activeContracts,
                        emptyMessage: 'Không có hợp đồng đang hoạt động',
                      ),
                      // Tab 2: Hết hạn
                      _buildContractListView(
                        contracts: expiredContracts,
                        emptyMessage: 'Không có hợp đồng hết hạn',
                      ),
                      // Tab 3: Đã thanh lý
                      _buildContractListView(
                        contracts: liquidatedContracts,
                        emptyMessage: 'Không có hợp đồng đã thanh lý',
                      ),
                    ],
                  );
                }

                // 4. Trạng thái Initial hoặc không có dữ liệu
                return const Center(child: Text('Không có dữ liệu hợp đồng'));
              },
            ),
          ),
        ),
        // ... (Phần Positioned của bạn giữ nguyên) ...
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

  Widget _buildContractListView({
    required List<ListContractModel> contracts,
    required String emptyMessage,
  }) {
    if (contracts.isEmpty) {
      return Center(child: Text(emptyMessage));
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: ListView.builder(
        itemCount: contracts.length,
        itemBuilder: (context, index) {
          final contractItem = contracts[index];
          // SỬA: Đổi tên model ở đây cho khớp
          return buildContractCard(context, contractItem);
        },
      ),
    );
  }

  Widget buildContractCard(BuildContext context, ListContractModel contract) {
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
              // Dữ liệu ĐỘNG: id_hopdong
              Text(
                '#${contract.id_hopdong}', // Giả sử model có trường id_hopdong
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.home_outlined, size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  // Dữ liệu ĐỘNG: ten_phong và ten_toanha
                  Text(
                    '${contract.ten_phong} - ${contract.ten_toanha}',
                  ), // Giả sử model có 2 trường này
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  // Dữ liệu ĐỘNG: ngay_batdau và thoi_han
                  Text(
                    'Từ ${contract.ngay_batdau} [Thời hạn: ${contract.thoi_han} tháng]',
                  ), // Giả sử model có 2 trường này
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 18,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  // Dữ liệu ĐỘNG: ten_nguoidung
                  Text(
                    'Người tạo: ${contract.ten_quanly}',
                  ), // Giả sử model có trường ten_nguoidung
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
