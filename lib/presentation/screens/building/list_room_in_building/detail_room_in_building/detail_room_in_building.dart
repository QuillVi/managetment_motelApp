import 'package:flutter/material.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/presentation/screens/building/list_room_in_building/detail_room_in_building/detail_tanent_in_room/detail_tanent_in_room.dart';
import 'package:motelapp/router/app_router.dart';

class DetailRoomInBuilding extends StatefulWidget {
  const DetailRoomInBuilding({super.key});

  @override
  State<DetailRoomInBuilding> createState() => _DetailRoomInBuildingState();
}

class _DetailRoomInBuildingState extends State<DetailRoomInBuilding>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Khởi tạo
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Hàm hiển thị showModalBottomSheet
  Future<dynamic> _onShowOptionTanent() {
    return showModalBottomSheet(
      context: context,
      builder: (modalContext) {
        // Sử dụng context riêng cho modal
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.orange),
                title: const Text('Chi tiết'),
                onTap: () {
                  Navigator.pop(modalContext);
                  getIt<AppRouter>().push(DetailTanentInRoom());
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Xóa'),
                onTap: () {
                  // Xử lý xóa người thuê
                  getIt<AppRouter>().pop(); // Đóng modal sau khi xóa
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
        title: const Text(
          'số 1',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: const [
          Icon(Icons.add_circle_outline, color: Colors.orange),
          SizedBox(width: 12),
          Icon(Icons.edit, color: Colors.orange),
          SizedBox(width: 12),
        ],
        bottom: TabBar(
          controller: _tabController, // Gán TabController cho TabBar
          labelColor: Colors.green,
          unselectedLabelColor: Colors.black45,
          indicatorColor: Colors.green,
          indicatorWeight: 2,
          dividerHeight: 0,
          tabs: const [Tab(text: 'Thông tin chung'), Tab(text: 'Người thuê')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildRoomDetails(), _buildRoomTanents()],
      ),
    );
  }

  Widget _buildRoomDetails() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            color: Colors.grey.shade400,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Center(
              child: Text(
                'Đang cho thuê',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '3.000.000 đ',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Diện tích',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('15 m²', style: TextStyle(color: Colors.red)),
                    SizedBox(height: 8),
                    Text(
                      'Phòng ngủ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('1', style: TextStyle(color: Colors.red)),
                    SizedBox(height: 8),
                    Text(
                      'Số người tối đa',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('2', style: TextStyle(color: Colors.red)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Tầng', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('1', style: TextStyle(color: Colors.red)),
                    SizedBox(height: 8),
                    Text(
                      'Phòng khách',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('1', style: TextStyle(color: Colors.red)),
                    SizedBox(height: 8),
                    Text(
                      'Đặt cọc',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('2.000.000 đ', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                const Text(
                  'HỢP ĐỒNG #013351',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text('Từ 23-03-2025 đến [Chưa xác định thời hạn]'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: 46,
                      width: 110,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.orange),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () {},
                        child: const Text(
                          'Chỉnh sửa',
                          style: TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 46,
                      width: 110,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () {},
                        child: const Text(
                          'Xóa',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    Container(
                      height: 46,
                      width: 110,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () {},
                        child: const Text(
                          'Thanh lý',
                          style: TextStyle(color: Colors.green, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Đối tượng',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 70),
                    Icon(Icons.circle_outlined),
                    SizedBox(width: 8),
                    Text('Nữ'),
                    SizedBox(width: 16),
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Nam'),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Dịch vụ có phí',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 150,
                  width: double.infinity,
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

                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Dữ liệu trống',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Dịch vụ miễn phí',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 150,
                  width: double.infinity,
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

                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Dữ liệu trống',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Tiện ích phòng',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Chip(
                  label: Text('Khoá từ', style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.green,
                  side: BorderSide.none,
                ),
                SizedBox(height: 16),
                Text('Nội thất', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.circle_outlined),
                        SizedBox(width: 8),
                        Text('Không'),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(width: 16),
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Cơ bản'),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(width: 16),
                        Icon(Icons.circle_outlined),
                        SizedBox(width: 8),
                        Text('Đầy đủ'),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 26),
                Text(
                  'Mô tả phòng (dùng cho dãy phòng)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Container(
                  height: 150,
                  width: double.infinity,
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
                ),
                SizedBox(height: 16),
                Text(
                  'Lưu ý cho người thuê phòng',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Container(
                  height: 150,
                  width: double.infinity,
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
                ),

                const SizedBox(height: 32),
                Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      'Xóa phòng',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomTanents() {
    return Stack(
      children: [
        // Danh sách người thuê
        ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: const Text(
                  'huy',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('số 1 - vi'),
                trailing: const Text(
                  '404640464',
                  style: TextStyle(color: Colors.green),
                ),
                onTap: () {
                  // Xử lý khi người dùng nhấn vào thẻ người thuê
                  _onShowOptionTanent();
                },
              ),
            ),
          ],
        ),
        // Nút thêm mới
        Positioned(
          bottom: 60,
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
}

class RenterCard extends StatelessWidget {
  final String name;
  final String roomInfo;
  final String phone;

  const RenterCard({
    super.key,
    required this.name,
    required this.roomInfo,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const CircleAvatar(radius: 24, backgroundColor: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(roomInfo, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            Text(
              phone,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
