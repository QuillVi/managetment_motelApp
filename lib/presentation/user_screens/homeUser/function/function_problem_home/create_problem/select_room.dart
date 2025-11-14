import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/models/room_model.dart';
import 'package:motelapp/logic/cubits/home/problem_home/select_room_problem_cubit.dart';
import 'package:motelapp/logic/cubits/home/problem_home/select_room_problem_state.dart';

class SelectRoom extends StatefulWidget {
  const SelectRoom({super.key});

  @override
  State<SelectRoom> createState() => _SelectRoomState();
}

class _SelectRoomState extends State<SelectRoom>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

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
    context.read<SelectRoomProblemCubit>().loadListRoomProblem();
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
                  Tab(text: 'Đã tạo hợp đồng'),
                  Tab(text: 'Chưa tạo hợp đồng'),
                ],
              ),
            ],
          ),
        ),
      ),
      // Nội dung chính của màn hình
      body: BlocBuilder<SelectRoomProblemCubit, SelectRoomProblemState>(
        builder: (context, state) {
          // 1. Xử lý trạng thái Loading và Error chung
          if (state.status == SelectRoomProblemStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status == SelectRoomProblemStatus.error) {
            print('Lỗi: ${state.errorMessage}');
            return Center(child: Text('Lỗi: ${state.errorMessage}'));
          }

          // 2. Lọc dữ liệu khi đã Loaded
          final allRooms = state.selectRoomProblem ?? [];

          final roomsWithContract =
              allRooms
                  .where((room) => room.trang_thai_coc == 'Đã tạo hợp đồng')
                  .toList();

          final roomsWithoutContract =
              allRooms
                  .where((room) => room.trang_thai_coc != 'Chưa tạo hợp đồng')
                  .toList();

          // 3. Trả về TabBarView với dữ liệu đã lọc
          return TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Đã tạo hợp đồng
              _buildRoomListTab(
                rooms: roomsWithContract,
                emptyMessage: 'Không có phòng đã tạo hợp đồng',
              ),

              // Tab 2: Chưa tạo hợp đồng (Đang chờ, Đã hủy)
              _buildRoomListTab(
                rooms: roomsWithoutContract,
                emptyMessage: 'Không có phòng nào đang chờ cọc hoặc đã hủy',
              ),
            ],
          );
        },
      ),
    );
  }

  /// Widget con để hiển thị danh sách phòng (bao gồm tìm kiếm và ListView)
  Widget _buildRoomListTab({
    required List<ListRoomProblemModel> rooms,
    required String emptyMessage,
  }) {
    // Giả sử bạn sẽ implement search sau,
    // hiện tại chúng ta hiển thị danh sách gốc
    final filteredRooms = rooms;

    if (filteredRooms.isEmpty) {
      return Center(child: Text(emptyMessage));
    }

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm theo tên',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (q) {
              // TODO: Implement search logic here or via Cubit
            },
          ),
          const SizedBox(height: 16),
          // List phòng chiếm phần còn lại
          Expanded(
            child: ListView.builder(
              itemCount: filteredRooms.length,
              itemBuilder: (context, index) {
                final item = filteredRooms[index];
                // Sử dụng lại widget card của bạn
                return _buildContractRoomsView(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractRoomsView(ListRoomProblemModel room) {
    // 🚀 LOGIC MỚI ĐỂ XÁC ĐỊNH TRẠNG THÁI
    final String statusText;
    final Color statusColor;

    switch (room.trang_thai_coc) {
      case 'Đã tạo hợp đồng':
        statusText = 'Đã có HĐ';
        statusColor = Colors.green;
        break;
      case 'Đang chờ':
        statusText = 'Đang chờ';
        statusColor = Colors.orange;
        break;
      case 'Khách hủy cọc':
        statusText = 'Đã hủy';
        statusColor = Colors.red;
        break;
      default:
        statusText = 'Không rõ';
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final roomName =
              '${room.ten_phong ?? 'Không tên'} - ${room.ten_toanha ?? 'Không rõ tòa'}';
          print(
            'Người dùng đã chọn phòng: id=${room.id_phong}, name=$roomName',
          );
          Navigator.pop(context, {'id': room.id_phong, 'name': roomName});
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              // Thêm Expanded để tránh lỗi overflow nếu tên quá dài
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Phòng
                  Row(
                    children: [
                      Icon(Icons.home_outlined, size: 18, color: Colors.grey),
                      SizedBox(width: 6),
                      Flexible(
                        // Thêm Flexible
                        child: Text(
                          '${room.ten_phong} - ${room.ten_toanha}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  /// Địa chỉ
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 6),
                      Flexible(
                        // Thêm Flexible
                        child: Text(
                          room.dia_chi ?? 'Chưa có địa chỉ',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 🚀 CẬP NHẬT BADGE TRẠNG THÁI
            Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
              ), // Đổi sang left padding
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1), // Dùng màu động
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: statusColor), // Dùng màu động
                ),
                child: Text(
                  statusText, // Dùng text động
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor, // Dùng màu động
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
