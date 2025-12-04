import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/models/lessee_model.dart';

import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/home/tanent_home/lessee_cubit.dart';
import 'package:motelapp/logic/cubits/home/tanent_home/lessee_state.dart';
import 'package:motelapp/presentation/screens/building/list_room_in_building/detail_room_in_building/detail_tanent_in_room/detail_tanent_in_room.dart';
import 'package:motelapp/presentation/screens/home/functions/function_tenant_home/add_tanent/add_tanent.dart';

import 'package:motelapp/router/app_router.dart';

class TenantHome extends StatefulWidget {
  const TenantHome({super.key});

  @override
  State<TenantHome> createState() => _TenantHomeState();
}

class _TenantHomeState extends State<TenantHome>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  //Tạo biến để lưu nội dung tim kiếm
  String _searchText = "";

  final List<Tab> myTabs = const [
    Tab(text: 'Đã có phòng'),
    Tab(text: 'Đã thanh lý'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: myTabs.length, vsync: this);

    //load cubit list tanent
    context.read<LesseeCubit>().loadTanents();
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
            //icon ios arrow back
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
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
                  //lắng nge sự kiến nhập liệu
                  onChanged: (value) {
                    setState(() {
                      _searchText = value.trim().toLowerCase();
                    });
                  },
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
                    // Tab 1: Đã có phòng -> Truyền key 'da_co_phong'
                    _buildListByStatus(context, filterStatus: 'da_co_phong'),

                    // Tab 2: Đã thanh lý -> Truyền key 'da_thanh_ly'
                    _buildListByStatus(context, filterStatus: 'da_thanh_ly'),
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
            onTap: () async {
              // 1. Mở màn hình thêm và CHỜ (await) kết quả trả về
              // Lúc này màn hình Home vẫn đang sống, nhưng bị che đi
              final result = await getIt<AppRouter>().push(const AddTanent());

              // 2. Dòng code này chỉ chạy KHI màn hình AddTanent đã đóng (pop)
              if (result == true) {
                print("Đã thêm thành công, đang tải lại danh sách...");

                // 3. Chủ động gọi load lại dữ liệu vì initState không tự chạy lại
                context.read<LesseeCubit>().loadTanents();
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

  // Hàm Widget tách riêng để tái sử dụng cho cả 2 tab
  // Hàm Widget tách riêng để tái sử dụng cho cả 2 tab
  Widget _buildListByStatus(
    BuildContext context, {
    required String filterStatus,
  }) {
    return BlocBuilder<LesseeCubit, LesseeState>(
      builder: (context, state) {
        // -----------------------------------------------------------
        // TRƯỜNG HỢP 1: ĐÃ CÓ DỮ LIỆU TRONG STATE (HIỂN THỊ DANH SÁCH)
        // -----------------------------------------------------------
        if (state.listLessee != null && state.listLessee!.isNotEmpty) {
          final allLessees = state.listLessee!;

          // --- LOGIC LỌC DỮ LIỆU ---
          final filteredList =
              allLessees.where((item) {
                // 1. Điều kiện Tab
                bool matchStatus = false;
                if (filterStatus == 'da_co_phong') {
                  matchStatus = item.trangThaiHopDong == 'DangHoatDong';
                } else {
                  matchStatus = item.trangThaiHopDong != 'DangHoatDong';
                }

                // 2. Điều kiện Tìm kiếm
                bool matchSearch = true;
                if (_searchText.isNotEmpty) {
                  matchSearch =
                      (item.tenNguoiThue.toLowerCase().contains(_searchText)) ||
                      (item.soDienThoai != null &&
                          item.soDienThoai!.contains(_searchText)) ||
                      (item.tenPhong != null &&
                          item.tenPhong!.toLowerCase().contains(_searchText)) ||
                      (item.tenToaNha != null &&
                          item.tenToaNha!.toLowerCase().contains(_searchText));
                }

                return matchStatus && matchSearch;
              }).toList();

          // --- HIỂN THỊ KẾT QUẢ LỌC ---
          if (filteredList.isEmpty) {
            // Nếu lọc không ra kết quả nào
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 50, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    _searchText.isEmpty
                        ? 'Danh sách trống'
                        : 'Không tìm thấy kết quả',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  // Nếu đang loading ngầm thì hiện thêm cái vòng xoay nhỏ
                  if (state.status == LesseeStatus.loading)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            );
          }

          // Có dữ liệu -> Dùng Stack để hiển thị Loading đè lên nếu cần
          return Stack(
            children: [
              ListView.builder(
                itemCount: filteredList.length,
                padding: const EdgeInsets.only(
                  bottom: 80,
                ), // Tránh nút FloatingButton che
                itemBuilder: (context, index) {
                  return _buildTenantCard(filteredList[index]);
                },
              ),

              // Nếu đang load lại (reload) -> Hiện Loading Overlay ở giữa
              if (state.status == LesseeStatus.loading)
                const Center(child: CircularProgressIndicator()),
            ],
          );
        }
        // -----------------------------------------------------------
        // TRƯỜNG HỢP 2: CHƯA CÓ DỮ LIỆU (NULL HOẶC RỖNG)
        // -----------------------------------------------------------
        // Đang tải lần đầu tiên -> Hiện Loading to
        else if (state.status == LesseeStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        // Gặp lỗi -> Hiện thông báo lỗi + Nút thử lại
        else if (state.status == LesseeStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                const SizedBox(height: 8),
                Text('Lỗi: ${state.errorMessage}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<LesseeCubit>().loadTanents(),
                  child: const Text("Thử lại"),
                ),
              ],
            ),
          );
        }
        // Mặc định: Không có dữ liệu
        else {
          return const Center(child: Text('Chưa có dữ liệu'));
        }
      },
    );
  }

  Widget _buildTenantCard(LesseeModel lessee) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: Colors.grey[300],
          child: const Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          lessee.tenNguoiThue,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          // Đảm bảo null safety khi hiển thị
          '${lessee.tenPhong ?? "N/A"} - ${lessee.tenToaNha ?? "N/A"}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Text(
          lessee.soDienThoai ?? "",
          style: const TextStyle(color: Colors.green),
        ),
        onTap: () {
          getIt<AppRouter>().push(
            DetailTanentInRoom(idNguoiThue: lessee.idNguoiThue),
          );
        },
      ),
    );
  }
}
