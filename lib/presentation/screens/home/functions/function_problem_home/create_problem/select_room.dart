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
                  Tab(text: 'Đã có hợp đồng'),
                  Tab(text: 'Chưa có hợp đồng'),
                ],
              ),
            ],
          ),
        ),
      ),
      // Nội dung chính của màn hình
      body: TabBarView(
        controller: _tabController,
        children: [
          // Nội dung Tab 1: Đã có hợp đồng
          BlocBuilder<SelectRoomProblemCubit, SelectRoomProblemState>(
            builder: (context, state) {
              if (state.status == SelectRoomProblemStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state.status == SelectRoomProblemStatus.error) {
                print('Lỗi: ${state.errorMessage}');
                return Center(child: Text('Lỗi: ${state.errorMessage}'));
              } else if (state.status == SelectRoomProblemStatus.loaded &&
                  state.selectRoomProblem != null) {
                final rooms = state.selectRoomProblem!;
                // nếu rỗng -> hiển thị thông báo
                if (rooms.isEmpty) {
                  return const Center(
                    child: Text('Không có phòng đang có hợp đồng'),
                  );
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
                        onChanged: (q) {},
                      ),
                      const SizedBox(height: 16),
                      // List phòng chiếm phần còn lại
                      Expanded(
                        child: ListView.builder(
                          itemCount: rooms.length,
                          itemBuilder: (context, index) {
                            final item = rooms[index];
                            return _buildContractRoomsView(item);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return const Center(
                  child: Text('Không có sự cố nào đang yêu cầu'),
                );
              }
            },
          ),

          // Nội dung Tab 2: Chưa có hợp đồng
          _buildNoContractRoomsView(),
        ],
      ),
    );
  }

  Widget _buildContractRoomsView(ListRoomProblemModel room) {
    final roomName =
        '${room.ten_phong ?? 'Không tên'} - ${room.ten_toanha ?? 'Không rõ tòa'}';
    final address = room.dia_chi ?? 'Không rõ địa chỉ';

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Phòng
                Row(
                  children: [
                    Icon(Icons.home_outlined, size: 18, color: Colors.grey),
                    SizedBox(width: 6),
                    Text(
                      '${room.ten_phong} - ${room.ten_toanha}',
                      style: TextStyle(fontWeight: FontWeight.bold),
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
                    Text(room.dia_chi ?? 'Chưa có địa chỉ'),
                  ],
                ),
              ],
              // Trạng thái hợp đồng
            ),

            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.green),
                ),
                child: const Text(
                  'Đã có HĐ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
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

  // Widget hiển thị danh sách phòng cho Tab 2 (Tạm thời là một Container rỗng)
  Widget _buildNoContractRoomsView() {
    return const Center(
      child: Text(
        'Không có phòng chưa hợp đồng',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  // Widget tạo thẻ thông tin phòng
  Widget _buildRoomCard({
    required String roomName,
    required String address,
    required bool hasContract,
    required bool isRented,
  }) {
    // Màu cho tag "Đã cọc"
    Color depositColor = Colors.blue.shade800;
    // Màu cho tag "Đã thuê"
    Color rentedColor = Colors.red.shade800;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.house_outlined,
                      color: Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      roomName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Tags: Đã cọc & Đã thuê
                Row(
                  children: [
                    if (hasContract) _buildInfoTag('Đã cọc', depositColor),
                    const SizedBox(width: 4),
                    if (isRented) _buildInfoTag('Đã thuê', rentedColor),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  address,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget tạo các tag thông tin (Đã cọc/Đã thuê)
  Widget _buildInfoTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
