import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/models/stake_model.dart';
import 'package:motelapp/logic/cubits/home/stake_home/stake_cubit.dart';
import 'package:motelapp/logic/cubits/home/stake_home/stake_state.dart';

class SelectRoomStake extends StatefulWidget {
  const SelectRoomStake({super.key});

  @override
  State<SelectRoomStake> createState() => _SelectRoomStakeState();
}

class _SelectRoomStakeState extends State<SelectRoomStake>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Gọi API load danh sách phòng phân loại theo cọc
    context.read<ContentStakeCubit>().loadSelectRoomStake();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: const SizedBox.shrink(),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Chọn phòng',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.green,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              dividerHeight: 0,
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              indicatorWeight: 3.0,
              tabs: const [
                Tab(text: 'Chưa có cọc'), // Tab 0
                Tab(text: 'Đã có cọc'), // Tab 1
              ],
            ),
          ),
        ),
      ),
      body: BlocBuilder<ContentStakeCubit, StakeState>(
        builder: (context, state) {
          // 1. Loading
          if (state.status == StakeStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error
          if (state.status == StakeStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 8),
                  Text('Lỗi: ${state.error}'),
                  TextButton(
                    onPressed: () {
                      context.read<ContentStakeCubit>().loadSelectRoomStake();
                    },
                    child: const Text("Thử lại"),
                  ),
                ],
              ),
            );
          }

          // 3. Loaded
          if (state.status == StakeStatus.loaded &&
              state.selectRoomStake != null) {
            final data = state.selectRoomStake!;

            // Lấy 2 danh sách từ API
            final listChuaCo = data.chuaCoCoc;
            final listDaCo = data.daCoCoc;

            // Lọc theo từ khóa tìm kiếm (Local search)
            final filteredChuaCo = listChuaCo.where(_checkSearch).toList();
            final filteredDaCo = listDaCo.where(_checkSearch).toList();

            return TabBarView(
              controller: _tabController,
              children: [
                // Tab 0: Chưa có cọc (Có thể chọn để tạo mới)
                _buildRoomList(filteredChuaCo, canSelect: true),

                // Tab 1: Đã có cọc (Chỉ xem, hoặc chọn nếu logic cho phép cọc chồng)
                // Thường thì phòng đang có cọc sẽ không cho cọc tiếp -> canSelect = false hoặc tùy logic
                _buildRoomList(filteredDaCo, canSelect: false),
              ],
            );
          }

          return const Center(child: Text('Không có dữ liệu phòng'));
        },
      ),
    );
  }

  // Logic tìm kiếm local
  bool _checkSearch(RoomStakeItem room) {
    if (_searchQuery.isEmpty) return true;
    final query = _searchQuery.toLowerCase();
    return room.tenPhong.toLowerCase().contains(query) ||
        room.tenToanha.toLowerCase().contains(query);
  }

  Widget _buildRoomList(List<RoomStakeItem> rooms, {required bool canSelect}) {
    return Column(
      children: [
        // Ô tìm kiếm
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm tên phòng, tòa nhà...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: EdgeInsets.zero,
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
        ),

        // Danh sách
        Expanded(
          child:
              rooms.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Không tìm thấy phòng phù hợp',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                  : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: rooms.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildRoomItem(rooms[index], canSelect);
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildRoomItem(RoomStakeItem room, bool canSelect) {
    // Xác định màu và chữ cho Tag trạng thái
    String statusText;
    Color statusColor;
    Color statusBgColor;

    switch (room.trangThaiCoc) {
      case 'DangCho':
        statusText = 'Đang chờ';
        statusColor = Colors.orange;
        statusBgColor = Colors.orange.shade50;
        break;
      case 'DaKyHopDong':
        statusText = 'Đã ký HĐ';
        statusColor = Colors.blue;
        statusBgColor = Colors.blue.shade50;
        break;
      case 'KhachHuy':
        statusText = 'Khách hủy';
        statusColor = Colors.red;
        statusBgColor = Colors.red.shade50;
        break;
      case 'QuaHan':
        statusText = 'Quá hạn';
        statusColor = Colors.grey;
        statusBgColor = Colors.grey.shade200;
        break;
      default: // 'ChuaCo' hoặc null
        statusText = 'Trống';
        statusColor = Colors.green;
        statusBgColor = Colors.green.shade50;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap:
            canSelect
                ? () {
                  // Trả dữ liệu về màn hình AddStake
                  final result = {
                    'id': room.idPhong,
                    'name': '${room.tenPhong} - ${room.tenToanha}',
                    // 'priceRoom': ... (API mới chưa trả về giá, có thể update sau)
                    // 'depositRoom': ... (API mới chưa trả về tiền cọc mặc định)
                  };
                  Navigator.pop(context, result);
                }
                : null, // Nếu không được chọn thì disable click
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon nhà
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.home_work, color: Colors.blue),
              ),
              const SizedBox(width: 16),

              // Thông tin chính
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.tenPhong,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      room.tenToanha,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      room.diaChi.isNotEmpty ? room.diaChi : 'Chưa có địa chỉ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Tag trạng thái
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
