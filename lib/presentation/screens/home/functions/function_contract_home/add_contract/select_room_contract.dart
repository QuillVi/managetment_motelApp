import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/models/room_model.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/tanent_room_cubit.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/tanent_room_state.dart';

class SelectRoomContract extends StatefulWidget {
  const SelectRoomContract({super.key});

  @override
  State<SelectRoomContract> createState() => _SelectRoomContractState();
}

class _SelectRoomContractState extends State<SelectRoomContract>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });

    // //load cubit list room select problem
    context.read<TanentRoomCubit>().loadSelectRoomIDManager();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox.shrink(),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Chọn phòng', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
        // Tab Bar bên dưới AppBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Column(
            children: [
              // Tab bar (Đã có hợp đồng / Chưa có hợp đồng)
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.green, // Màu của thanh indicator
                labelColor: Colors.black, // Màu chữ của tab đang chọn
                unselectedLabelColor: Colors.grey, // Màu chữ của tab không chọn
                dividerHeight: 0,
                labelStyle: const TextStyle(fontSize: 16),
                indicatorWeight: 3.0,
                tabs: const [
                  Tab(text: 'Chưa có hợp đồng'),
                  Tab(text: 'Đã có hợp đồng'),
                ],
              ),
            ],
          ),
        ),
      ),
      // Nội dung chính của màn hình
      body: BlocBuilder<TanentRoomCubit, TanentRoomState>(
        builder: (context, state) {
          // 1. Trạng thái Loading
          if (state.status == TanentRoomStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Trạng thái Error
          if (state.status == TanentRoomStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 8),
                  Text('Lỗi: ${state.errorMessage}'),
                  TextButton(
                    onPressed: () {
                      context.read<TanentRoomCubit>().loadSelectRoomIDManager();
                    },
                    child: const Text("Thử lại"),
                  ),
                ],
              ),
            );
          }

          // 3. Trạng thái Loaded
          if (state.status == TanentRoomStatus.loaded &&
              state.selectRoomIDManaget != null) {
            final allRooms = state.selectRoomIDManaget!;

            // --- LOGIC LỌC DỮ LIỆU ---

            // Lọc cho Tab 1: Đang hoạt động
            final roomsWithContract =
                allRooms.where((room) {
                  final matchStatus = room.trangThaiHopDong == 'DangHoatDong';
                  final matchSearch = _checkSearch(room);
                  return matchStatus && matchSearch;
                }).toList();

            // Lọc cho Tab 2: Các trạng thái khác (Chưa có HĐ, Đã thanh lý...)
            final roomsWithoutContract =
                allRooms.where((room) {
                  final matchStatus = room.trangThaiHopDong != 'DangHoatDong';
                  final matchSearch = _checkSearch(room);
                  return matchStatus && matchSearch;
                }).toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildRoomListView(roomsWithoutContract, hasContract: true),
                _buildRoomListView(roomsWithContract, hasContract: false),
              ],
            );
          }

          return const Center(child: Text('Không có dữ liệu phòng'));
        },
      ),
    );
  }

  // Hàm phụ để kiểm tra tìm kiếm
  bool _checkSearch(SelectRoomIDManagetModel room) {
    if (_searchQuery.isEmpty) return true;
    final query = _searchQuery.toLowerCase();
    return (room.tenPhong.toLowerCase().contains(query)) ||
        (room.tenToaNha.toLowerCase().contains(query));
  }

  Widget _buildRoomListView(
    List<SelectRoomIDManagetModel> rooms, {
    required bool hasContract,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          // Ô tìm kiếm
          TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm tên phòng, tòa nhà...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (q) {
              setState(() {
                _searchQuery = q;
              });
            },
          ),
          const SizedBox(height: 16),

          // Danh sách phòng
          if (rooms.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  hasContract
                      ? 'Chưa có phòng nào đang thuê'
                      : 'Không có phòng trống nào',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  return _buildRoomItemView(
                    rooms[index],
                    hasContract: hasContract,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRoomItemView(
    SelectRoomIDManagetModel room, {
    required bool hasContract,
  }) {
    // Sử dụng thuộc tính từ model mới (camelCase)
    final roomName = '${room.tenPhong} - ${room.tenToaNha}';
    final address =
        room.diaChiToaNha.isNotEmpty
            ? room.diaChiToaNha
            : 'Chưa cập nhật địa chỉ';

    // Logic hiển thị Tag trạng thái
    String tagText;
    Color tagColor;

    if (room.trangThaiHopDong == 'DangHoatDong') {
      tagText = 'Đang thuê';
      tagColor = Colors.green;
    } else {
      // Hiển thị trạng thái thực tế (Trống, Đã thanh lý...)
      tagText = room.trangThaiPhong;
      tagColor = Colors.grey;
      if (room.trangThaiPhong == 'Trống') tagColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Trả dữ liệu về màn hình trước
          final String displayName = '${room.tenPhong} - ${room.tenToaNha}';

          print('--- DEBUG ROOM INFO ---');
          print('Selected Room: ${room.idPhong} - $displayName');
          print('Giá phòng (gia_phong): ${room.giaPhong}'); // Đổi label rõ ràng
          print(
            'Tiền cọc (tien_dat_coc): ${room.tienDatCoc}',
          ); // Đổi label rõ ràng
          print('-----------------------');

          // 2. Đóng gói dữ liệu trả về
          final Map<String, dynamic> result = {
            'id': room.idPhong,
            'name': displayName,
            'priceRoom': room.giaPhong,
            'depositRoom': room.tienDatCoc,
          };

          Navigator.pop(context, result);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Thông tin bên trái
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.home_work_outlined,
                        size: 20,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          roomName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          address,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tag trạng thái bên phải
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: tagColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: tagColor),
              ),
              child: Text(
                tagText,
                style: TextStyle(
                  fontSize: 12,
                  color: tagColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
