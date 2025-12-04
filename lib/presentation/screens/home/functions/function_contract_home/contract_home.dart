import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/models/contract_model.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/home/contract_home/contract_cubit.dart';
import 'package:motelapp/logic/cubits/home/contract_home/contract_state.dart';
import 'package:motelapp/presentation/screens/buttonNavicationBar/buttonNavicationBar.dart';
import 'package:motelapp/presentation/screens/home/functions/function_contract_home/add_contract/add_contract.dart';
import 'package:motelapp/presentation/screens/home/functions/function_contract_home/detail_contract/detail_contract.dart';
import 'package:motelapp/router/app_router.dart';

class ContractHome extends StatefulWidget {
  const ContractHome({super.key});

  @override
  State<ContractHome> createState() => _ContractHomeState();
}

class _ContractHomeState extends State<ContractHome> {
  // 1. Thêm Controller để quản lý ô tìm kiếm
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();

    // //load cubit list contract is active
    context.read<ListContractCubit>().LoadListContract();

    // Lắng nghe sự thay đổi của ô tìm kiếm
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Hàm hỗ trợ lọc theo từ khóa
  bool _matchesSearch(ListContractModel contract) {
    if (_searchText.isEmpty) return true;

    // Kiểm tra các trường muốn tìm kiếm: Số hợp đồng, tên phòng...
    // Lưu ý: Đảm bảo model của bạn có các trường này và không null
    final idCheck =
        contract.id_hopdong?.toString().toLowerCase().contains(_searchText) ??
        false;
    final roomCheck =
        contract.ten_phong?.toLowerCase().contains(_searchText) ?? false;

    return idCheck || roomCheck;
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

            body: Column(
              children: [
                // === PHẦN Ô TÌM KIẾM ===
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.white, // Nền trắng để tách biệt
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      hintText: 'Tìm kiếm theo số HĐ, tên phòng...',
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // === PHẦN DANH SÁCH (Sử dụng Expanded để chiếm phần còn lại) ===
                Expanded(
                  child: BlocBuilder<ListContractCubit, ListContractState>(
                    builder: (context, state) {
                      if (state.status == ListContractIsActiveStatus.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state.status == ListContractIsActiveStatus.error) {
                        return Center(
                          child: Text('Lỗi: ${state.errorMessage}'),
                        );
                      }

                      if ((state.status == ListContractIsActiveStatus.loaded ||
                              state.status ==
                                  ListContractIsActiveStatus.deleteSuccess ||
                              state.status ==
                                  ListContractIsActiveStatus
                                      .liquidateSuccess) &&
                          state.listContractModel != null) {
                        final allContracts = state.listContractModel!;

                        if (allContracts.isEmpty) {
                          return const Center(
                            child: Text('Không có dữ liệu hợp đồng'),
                          );
                        }

                        // 3. Lọc danh sách kết hợp trạng thái AND từ khóa tìm kiếm
                        final activeContracts =
                            allContracts
                                .where(
                                  (c) =>
                                      c.trang_thai == 'DangHoatDong' &&
                                      _matchesSearch(c),
                                )
                                .toList();

                        final expiredContracts =
                            allContracts
                                .where(
                                  (c) =>
                                      c.trang_thai == 'HetHan' &&
                                      _matchesSearch(c),
                                )
                                .toList();

                        final liquidatedContracts =
                            allContracts
                                .where(
                                  (c) =>
                                      c.trang_thai == 'DaThanhLy' &&
                                      _matchesSearch(c),
                                )
                                .toList();

                        return TabBarView(
                          children: [
                            _buildContractListView(
                              contracts: activeContracts,
                              emptyMessage:
                                  _searchText.isNotEmpty
                                      ? 'Không tìm thấy kết quả phù hợp'
                                      : 'Không có hợp đồng đang hoạt động',
                            ),
                            _buildContractListView(
                              contracts: expiredContracts,
                              emptyMessage:
                                  _searchText.isNotEmpty
                                      ? 'Không tìm thấy kết quả phù hợp'
                                      : 'Không có hợp đồng hết hạn',
                            ),
                            _buildContractListView(
                              contracts: liquidatedContracts,
                              emptyMessage:
                                  _searchText.isNotEmpty
                                      ? 'Không tìm thấy kết quả phù hợp'
                                      : 'Không có hợp đồng đã thanh lý',
                            ),
                          ],
                        );
                      }
                      return const Center(
                        child: Text('Không có dữ liệu hợp đồng'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // Nút Floating Action Button (Vẫn giữ nguyên vị trí cũ)
        Positioned(
          bottom: 84,
          right: 24,
          child: GestureDetector(
            onTap: () async {
              // // Chờ kết quả trả về từ màn hình AddContract
              // // Hàm push sẽ ngưng ở đây cho đến khi bên kia gọi Navigator.pop
              // final result = await getIt<AppRouter>().push(AddContract());

              // // Kiểm tra kết quả
              // // Nếu bên kia trả về true (như code chúng ta đã làm ở bước trước)
              // if (result == true) {
              //   // Kiểm tra xem Widget này còn tồn tại trên cây Widget không (để tránh lỗi)
              //   if (!mounted) return;

              //   // Gọi lại hàm load danh sách trong Cubit
              //   context.read<ListContractCubit>().LoadListContract();
              //}

              //test lỗi ko hiển thị dữ liệu sau khi thêm hợp đồng
              // Bằng dòng này:
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddContract()),
              );

              // Sau đó debug xem result có dữ liệu không
              print('DEBUG: Kết quả trả về là: $result');

              if (result == true) {
                if (!mounted) return;
                print('DEBUG: Đang reload danh sách...'); // Log để kiểm tra
                context.read<ListContractCubit>().LoadListContract();
              }
            },
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
      // 1. Chuyển thành async để có thể dùng await
      onTap: () async {
        // 2. Dùng await để đợi màn hình Detail đóng lại và nhận kết quả
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => DetailContract(idHopDong: contract.id_hopdong),
          ),
        );

        // 3. Kiểm tra kết quả trả về
        // Nếu result là true (tức là đã xóa thành công ở màn hình kia)
        if (result == true) {
          // Kiểm tra context còn tồn tại không để tránh lỗi
          if (!context.mounted) return;

          // 4. Gọi Cubit load lại danh sách mới nhất
          context.read<ListContractCubit>().LoadListContract();

          // (Tùy chọn) Hiện thông báo nhỏ
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Đã cập nhật danh sách")),
          );
        }
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
