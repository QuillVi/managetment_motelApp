import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/models/room_model.dart';
import 'package:motelapp/logic/cubits/home/problem_home/select_room_problem_cubit.dart';
import 'package:motelapp/logic/cubits/home/problem_home/select_room_problem_state.dart';

class SelectRoomBill extends StatefulWidget {
  final int idHoaDon;
  final int idNguoiThue;
  const SelectRoomBill({
    super.key,
    required this.idHoaDon,
    required this.idNguoiThue,
  });

  @override
  State<SelectRoomBill> createState() => _SelectRoomBillState();
}

class _SelectRoomBillState extends State<SelectRoomBill>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  String _searchQuery = '';

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
    context.read<SelectRoomProblemCubit>().loadRoomManaget(widget.idNguoiThue);
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
      body: BlocBuilder<SelectRoomProblemCubit, SelectRoomProblemState>(
        builder: (context, state) {
          if (state.status == SelectRoomProblemStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == SelectRoomProblemStatus.error) {
            return Center(child: Text('Lỗi: ${state.errorMessage}'));
          }

          if (state.status == SelectRoomProblemStatus.loaded &&
              state.selectRoomManaget != null) {
            // 2. Lấy toàn bộ danh sách
            final allRooms = state.selectRoomManaget!;

            // 3. Lọc danh sách cho Tab 1 ("Đã tạo hợp đồng")
            // (Lọc thêm theo text tìm kiếm)
            final roomsWithContract =
                allRooms
                    .where(
                      (room) =>
                          room.trang_thai_coc == 'Đã tạo hợp đồng' &&
                          (room.ten_phong ?? '').toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ),
                    )
                    .toList();

            // 4. Lọc danh sách cho Tab 2 (Các trạng thái khác)
            // (Lọc thêm theo text tìm kiếm)
            final roomsWithoutContract =
                allRooms
                    .where(
                      (room) =>
                          room.trang_thai_coc != 'Đã tạo hợp đồng' &&
                          (room.ten_phong ?? '').toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ),
                    )
                    .toList();

            // 5. Trả về TabBarView với dữ liệu đã lọc
            return TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Đã có hợp đồng
                _buildRoomListView(roomsWithContract, hasContract: true),

                // Tab 2: Chưa có hợp đồng
                _buildRoomListView(roomsWithoutContract, hasContract: false),
              ],
            );
          }

          // Trạng thái mặc định (initial hoặc loaded nhưng null)
          return const Center(child: Text('Không có phòng nào'));
        },
      ),
    );
  }

  Widget _buildRoomListView(
    List<SelectRoomManagetModel> rooms, {
    required bool hasContract,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm theo tên phòng',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (q) {
              // Cập nhật state của query để BlocBuilder lọc lại
              setState(() {
                _searchQuery = q;
              });
            },
          ),
          const SizedBox(height: 16),
          // Kiểm tra nếu danh sách rỗng
          if (rooms.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  hasContract
                      ? 'Không có phòng nào có hợp đồng'
                      : 'Không có phòng nào chưa có hợp đồng',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            // List phòng chiếm phần còn lại
            Expanded(
              child: ListView.builder(
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final item = rooms[index];
                  // Gọi hàm build item (đã sửa lại)
                  return _buildRoomItemView(item, hasContract: hasContract);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRoomItemView(
    SelectRoomManagetModel room, {
    required bool hasContract,
  }) {
    final roomName =
        '${room.ten_phong ?? 'Không tên'} - ${room.ten_toanha ?? 'Không rõ tòa'}';
    final address = room.dia_chi ?? 'Không rõ địa chỉ';

    // Xác định màu sắc và text của tag
    final String tagText;
    final Color tagColor;

    if (hasContract) {
      tagText = 'Đã có HĐ';
      tagColor = Colors.green;
    } else {
      // Lấy trạng thái cọc thực tế từ API (ví dụ: 'Chưa tạo...')
      tagText = room.trang_thai_coc ?? 'Chưa có HĐ';
      tagColor = Colors.grey; // Bạn có thể đổi màu (vd: Colors.orange)
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
          print(
            'Người dùng đã chọn phòng: id=${room.id_phong}, name=$roomName',
          );
          print('Id hợp đồng: ${room.id_hopdong}');
          print('Id hợp đồng: ${room.gia_phong}');

          // Tạo một Map chứa tất cả dữ liệu cần trả về
          final Map<String, dynamic> result = {
            'id': room.id_phong,
            'id_hopdong': room.id_hopdong,
            'name': roomName,
            'price': room.gia_phong,
            'services': room.ds_dichvu, // <-- DÒNG BẠN CẦN THÊM
          };

          // Trả về Map 'result'
          Navigator.pop(context, result);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Phòng
                  Row(
                    children: [
                      Icon(Icons.home_outlined, size: 18, color: Colors.grey),
                      SizedBox(width: 6),
                      // BƯỚC 2: Thêm giới hạn dòng và dấu ... cho Tên phòng
                      Expanded(
                        // Dùng thêm Expanded nhỏ ở đây hoặc Flexible để Text bên trong không bị lỗi
                        child: Text(
                          roomName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1, // Chỉ hiện 1 dòng
                          overflow:
                              TextOverflow.ellipsis, // Hiện dấu ... nếu dài
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
                      // BƯỚC 2: Thêm giới hạn dòng và dấu ... cho Địa chỉ
                      Expanded(
                        child: Text(
                          address,
                          maxLines: 1, // Chỉ hiện 1 dòng
                          overflow:
                              TextOverflow.ellipsis, // Hiện dấu ... nếu dài
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: 8),
            // --- TAG TRẠNG THÁI ĐỘNG ---
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: tagColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: tagColor),
                ),
                child: Text(
                  tagText,
                  style: TextStyle(
                    fontSize: 12,
                    color: tagColor,
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
