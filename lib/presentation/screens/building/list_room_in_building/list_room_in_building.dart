import 'package:flutter/material.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/presentation/screens/building/list_room_in_building/detail_room_in_building/detail_room_in_building.dart';
import 'package:motelapp/router/app_router.dart';

class ListRoomInBuilding extends StatefulWidget {
  const ListRoomInBuilding({super.key});

  @override
  State<ListRoomInBuilding> createState() => _ListRoomInBuildingState();
}

class _ListRoomInBuildingState extends State<ListRoomInBuilding> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          shadowColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Column(
            children: [
              const Text('vi', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_alt_outlined, color: Colors.orange),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.edit_square, color: Colors.orange),
              onPressed: () {},
            ),
          ],
          bottom: TabBar(
            labelColor: Colors.green,
            unselectedLabelColor: Colors.black45,
            indicatorColor: Colors.green,
            indicatorWeight: 2,
            dividerHeight: 0,
            tabs: const [Tab(text: 'Danh sách phòng'), Tab(text: 'Chi tiết')],
          ),
        ),

        body: TabBarView(children: [_buildRoomCard(), _buildDetailRoomCard()]),
      ),
    );
  }

  /// Hàm xây dựng một thẻ phòng duy nhất
  Widget _buildSingleRoomCard({
    required String roomNumber,
    required String price,
    required int tenants,
    required int contracts,
    required int warnings,
    String? statusDeposit, // Trạng thái đã cọc (có thể null)
    String? statusRented, // Trạng thái đã thuê (có thể null)
  }) {
    return GestureDetector(
      onTap: () {
        // Điều hướng đến trang chi tiết của phòng cụ thể này
        // Đảm bảo getIt và AppRouter đã được cấu hình đúng
        // Nếu không, bạn có thể thay thế bằng:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DetailRoomInBuilding()),
        );
      },
      child: Container(
        // margin ở đây có thể thay thế bằng padding của GridView hoặc Spacer nếu dùng Wrap
        // Hiện tại dùng margin cho Container con để tạo khoảng cách giữa các item
        margin: const EdgeInsets.all(
          4.0,
        ), // Khoảng cách nhỏ giữa các thẻ trong lưới
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Icon nhà + trạng thái
            Stack(
              children: [
                const Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.home_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                ),
                if (statusDeposit != null &&
                    statusDeposit.isNotEmpty) // Chỉ hiển thị nếu có trạng thái
                  Positioned(
                    top: 0,
                    left: 0,
                    child: _statusTag(statusDeposit, Colors.blue),
                  ),
                if (statusRented != null &&
                    statusRented.isNotEmpty) // Chỉ hiển thị nếu có trạng thái
                  Positioned(
                    top: 0,
                    right: 0,
                    child: _statusTag(statusRented, Colors.red),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              roomNumber,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.groups_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('$tenants'),
                const SizedBox(width: 12),
                const Icon(Icons.receipt_long, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('$contracts'),
                const SizedBox(width: 12),
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text('$warnings'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Hàm xây dựng danh sách phòng dưới dạng lưới có thể cuộn
  Widget _buildRoomCard() {
    // Đây là dữ liệu mẫu. Trong ứng dụng thực tế, bạn sẽ thay thế bằng dữ liệu từ API.
    // Giả sử bạn có 20 phòng để minh họa khả năng cuộn
    final List<Map<String, dynamic>> roomsData = List.generate(
      20, // Số lượng phòng giả định
      (index) => {
        'roomNumber': 'Phòng ${index + 1}',
        'price': '${(3000000 + index * 100000).toStringAsFixed(0)} đ',
        'tenants': index % 3 + 1,
        'contracts': index % 2 + 1,
        'warnings': index % 4,
        'statusDeposit': index % 5 == 0 ? 'Đã cọc' : null,
        'statusRented': index % 3 == 0 ? 'ĐÃ THUÊ' : null,
      },
    );

    return Column(
      // Column để chứa TextField tìm kiếm và GridView các phòng
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Tìm kiếm theo hợp đồng, phòng...',
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        // Expanded giúp GridView chiếm hết chiều cao còn lại của Column
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12), // Padding cho toàn bộ lưới
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 phòng trên mỗi dòng
              crossAxisSpacing: 10.0, // Khoảng cách giữa các cột
              mainAxisSpacing: 10.0, // Khoảng cách giữa các hàng
              childAspectRatio: 0.7, // Tỷ lệ chiều rộng/chiều cao của mỗi item.
              // Bạn có thể điều chỉnh giá trị này (ví dụ: 0.7, 0.75, 0.8)
              // để các thẻ phòng không bị tràn hoặc quá trống.
            ),
            itemCount: roomsData.length, // Số lượng phòng từ dữ liệu
            itemBuilder: (context, index) {
              final room = roomsData[index];
              return _buildSingleRoomCard(
                roomNumber: room['roomNumber'] as String,
                price: room['price'] as String,
                tenants: room['tenants'] as int,
                contracts: room['contracts'] as int,
                warnings: room['warnings'] as int,
                statusDeposit: room['statusDeposit'] as String?,
                statusRented: room['statusRented'] as String?,
              );
            },
          ),
        ),
      ],
    );
  }

  /// Tag trạng thái (giữ nguyên từ code của bạn)
  Widget _statusTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailRoomCard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vị trí
          Row(
            children: const [
              Icon(Icons.location_on, size: 18, color: Colors.grey),
              SizedBox(width: 5),
              Expanded(
                child: Text(
                  "hhhh, Quận 8, Hồ Chí Minh",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Thông tin phòng
          Container(
            decoration: BoxDecoration(
              color: Colors.green[300],
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                InfoColumn(title: "Số phòng", value: "1"),
                InfoColumn(title: "Số người thuê", value: "1"),
                InfoColumn(title: "Số tầng", value: "3"),
                InfoColumn(title: "Phí thuê nhà", value: "3.000.000 ₫"),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Thời gian
          Container(
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
            padding: const EdgeInsets.all(16),
            child: Column(
              children: const [
                TimeRow(label: "Mở - đóng cửa", value: "06:00 - 00:00"),
                TimeRow(label: "Ngày chốt tiền", value: "30 hàng tháng"),
                TimeRow(label: "Chuyển báo trước", value: "25 ngày"),
                TimeRow(
                  label: "Thời gian nộp tiền",
                  value: "Ngày 1 hàng tháng",
                  bold: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Mô tả
          const Text("Mô tả", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            height: 150,
            width: double.infinity,
            padding: const EdgeInsets.all(16),

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
            child: const Text("Vui"),
          ),
          const SizedBox(height: 24),

          // --- Quản lý tòa nhà ---
          const Text(
            "Quản lý toà nhà",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 100,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4),
                  ],
                ),
                child: Column(
                  children: const [
                    CircleAvatar(radius: 20, child: Icon(Icons.person)),
                    SizedBox(height: 8),
                    Text("vi", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("0846941020", style: TextStyle(color: Colors.green)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- Dịch vụ có phí ---
          const Text(
            "Dịch vụ có phí",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ServiceCard(
                icon: Icons.wifi,
                title: "wifi",
                price: "300.000 đ/Người",
              ),
              SizedBox(width: 12),
              ServiceCard(
                icon: Icons.ac_unit,
                title: "Máy lạnh",
                price: "300.000 đ/Phòng",
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- Dịch vụ miễn phí ---
          const Text(
            "Dịch vụ miễn phí",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text("Dữ liệu trống", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),

          // --- Tiện ích tòa nhà ---
          const Text(
            "Tiện ích toà nhà",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text("Dữ liệu trống", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),

          // --- Lưu ý cho người thuê ---
          const Text(
            "Lưu ý cho người thuê",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          // --- Ghi chú cho hoá đơn ---
          const Text(
            "Ghi chú cho hoá đơn",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          // --- Nút Xóa tòa nhà ---
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Thêm logic xóa tòa nhà
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[300],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Xoá toà nhà",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class InfoColumn extends StatelessWidget {
  final String title;
  final String value;

  const InfoColumn({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class TimeRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const TimeRow({
    super.key,
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String price;

  const ServiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: 106,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 30),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(price, style: const TextStyle(color: Colors.red)),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "Tháng",
                  style: TextStyle(color: Colors.white, fontSize: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
