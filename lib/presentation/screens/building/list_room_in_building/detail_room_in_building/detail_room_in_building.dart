import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/detail_room_cubit.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/detail_room_state.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/tanent_room_cubit.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/tanent_room_state.dart';
import 'package:motelapp/presentation/screens/building/list_room_in_building/detail_room_in_building/add_tanent_room.dart';
import 'package:motelapp/presentation/screens/building/list_room_in_building/detail_room_in_building/detail_tanent_in_room/detail_tanent_in_room.dart';
import 'package:motelapp/presentation/screens/home/functions/function_contract_home/add_contract/add_contract.dart';
import 'package:motelapp/router/app_router.dart';

class DetailRoomInBuilding extends StatefulWidget {
  final int roomId;
  final String roomName;
  const DetailRoomInBuilding({
    super.key,
    required this.roomId,
    required this.roomName,
  });

  @override
  State<DetailRoomInBuilding> createState() => _DetailRoomInBuildingState();
}

class _DetailRoomInBuildingState extends State<DetailRoomInBuilding>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    context.read<DetailRoomCubit>().loadRoomDetail(widget.roomId);

    context.read<TanentRoomCubit>().loadTanentRoom(widget.roomId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Hàm hiển thị showModalBottomSheet
  Future<dynamic> _onShowOptionTanent(int idNguoiDung) {
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
                  getIt<AppRouter>().push(
                    DetailTanentInRoom(
                      // Truyền id người dùng tĩnh để test
                      idNguoiThue: idNguoiDung,
                    ),
                  );
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

  // Hàm hiển thị Popup xác nhận (để bên ngoài widget build)
  void _showConfirmContractDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Center(
              child: Text(
                "Xác nhận",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            content: const Text(
              "Phòng chưa có hợp đồng, bạn cần tạo hợp đồng để thêm người thuê.",
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.spaceAround,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Huỷ", style: TextStyle(color: Colors.green)),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx); // Tắt cái popup xác nhận trước

                  // 2. Dùng await để đợi kết quả trả về từ màn hình AddContract
                  // Lưu ý: Nếu bạn dùng AppRouter thì cũng tương tự: final result = await getIt<AppRouter>().push(...)
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddContract(),
                    ),
                  );

                  // 3. Kiểm tra nếu kết quả trả về là true (tức là tạo thành công)
                  if (result == true) {
                    // Kiểm tra context còn tồn tại không để tránh lỗi
                    if (!context.mounted) return;

                    // 4. Gọi lại hàm load API trong Cubit để làm mới danh sách
                    context.read<TanentRoomCubit>().loadTanentRoom(
                      widget.roomId,
                    );
                  }
                },
                child: const Text(
                  "Tạo hợp đồng",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
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
        title: Text(
          widget.roomName,
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
    return BlocBuilder<DetailRoomCubit, DetailRoomState>(
      builder: (context, state) {
        if (state.status == DetailRoomStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == DetailRoomStatus.failure) {
          return Center(child: Text("Lỗi: ${state.error}"));
        }

        if (state.status == DetailRoomStatus.success && state.data != null) {
          final room = state.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: Colors.grey.shade400,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: Text(
                      room.trangThai,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  room.giaPhong.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
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
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Diện tích',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${room.dienTich.toString()} m²',
                            style: TextStyle(color: Colors.red),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Phòng ngủ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            room.phongNgu.toString(),
                            style: TextStyle(color: Colors.red),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Số người thuê',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            room.soNguoiThue.toString(),
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Tầng',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            room.soTang.toString(),
                            style: TextStyle(color: Colors.red),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Phòng khách',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            room.phongKhach.toString(),
                            style: TextStyle(color: Colors.red),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Đặt cọc',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            room.tienDatCoc.toString(),
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'HỢP ĐỒNG #${room.hopdong?.idHopDong ?? "Chưa có hợp đồng"}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bắt đầu ${room.hopdong?.ngayBatDau != null ? DateFormat('dd-MM-yyyy').format(DateTime.parse(room.hopdong!.ngayBatDau)) : ''} trong [${room.hopdong?.thoiHan} tháng]',
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                            onPressed: () {},
                            child: const Text('Chỉnh sửa'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () {},
                            child: const Text('Xoá'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: () {},
                            child: const Text('Thanh lý'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16),
                      Text(
                        'Dịch vụ có phí',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        children: List.generate(room.dichvu!.length, (index) {
                          final serviceroom = room.dichvu![index];
                          return Center(
                            child: ServiceCard(
                              iconPath: serviceroom.icon!,
                              title: serviceroom.ten_dichvu,
                              price: serviceroom.phi_dichvu.toString(),
                            ),
                          );
                        }),
                      ),

                      SizedBox(height: 16),
                      Text(
                        'Dịch vụ miễn phí',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Dữ liệu trống',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Tiện ích phòng',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            (room.tienIchPhong.split(','))
                                .map(
                                  (e) => Container(
                                    width: 90, // cố định chiều rộng
                                    height: 40, // cố định chiều cao
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      e.trim(),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                      ),

                      SizedBox(height: 16),
                      Text(
                        'Nội thất',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Chip(
                        label: Text(room.noiThat),
                        backgroundColor: Colors.green.shade100,
                        side: BorderSide.none, // bỏ border
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            8,
                          ), // tuỳ chỉnh bo góc
                        ),
                      ),

                      SizedBox(height: 16),
                      Text(
                        'Mô tả phòng (dùng cho dãy phòng)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 100,
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
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
                        child: Text(
                          room.moTaPhong ?? "Chưa có mô tả cho phòng",
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Lưu ý cho người thuê phòng',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 100,
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
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
                        child: Text(
                          room.luuYChoNguoiThuePhong ??
                              "Chưa có lưu ý cho người thuê",
                        ),
                      ),
                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }

  Widget _buildRoomTanents() {
    return BlocBuilder<TanentRoomCubit, TanentRoomState>(
      builder: (context, state) {
        if (state.status == TanentRoomStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == TanentRoomStatus.error) {
          return Center(child: Text("Lỗi: ${state.errorMessage}"));
        }
        if (state.status == TanentRoomStatus.loaded && state.tanent != null) {
          final tanentList = state.tanent!;

          return Stack(
            children: [
              // Danh sách người thuê
              ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: tanentList.length,
                itemBuilder: (context, index) {
                  final tanent = tanentList[index];
                  print('ten nguoi thue id: ${tanent.idNguoiThue}');
                  print('ten nguoi thue: ${tanent.idNguoiThue}');
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
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
                      title: Text(
                        tanent.tenNguoiThue ?? 'Chưa có tên',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Phòng ${tanent.tenPhong ?? ""}'),
                      trailing: Text(
                        tanent.soDienThoai ?? 'Chưa có số điện thoại',
                        style: TextStyle(color: Colors.green),
                      ),
                      onTap: () {
                        // Xử lý khi người dùng nhấn vào thẻ người thuê
                        _onShowOptionTanent(tanent.idNguoiThue);
                      },
                    ),
                  );
                },
              ),
              // Nút thêm mới
              Positioned(
                bottom: 60,
                right: 24,
                child: GestureDetector(
                  onTap: () {
                    // --- LOGIC KIỂM TRA DỮ LIỆU Ở ĐÂY ---

                    if (tanentList.isEmpty) {
                      // CASE 1: API trả về [], chưa có người thuê
                      // -> Hiện Popup yêu cầu tạo hợp đồng
                      _showConfirmContractDialog(context);
                    } else {
                      // CASE 2: API có dữ liệu
                      // -> Chuyển màn hình thêm người thuê
                      getIt<AppRouter>().push(
                        AddTanentRoom(
                          roomId: widget.roomId,
                          roomName: widget.roomName,
                        ),
                      );
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
        return const Center(child: Text("Chưa có người thuê nào"));
      },
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

class ServiceCard extends StatelessWidget {
  final String iconPath; // đường dẫn icon trong assets
  final String title;
  final String price;

  const ServiceCard({
    super.key,
    required this.iconPath,
    required this.title,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: 106,
        width: 120, // thêm width để hiển thị đều hơn
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "lib/assets/icons/$iconPath",
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Hiển thị icon mặc định khi không tìm thấy file
                      return Image.asset(
                        "lib/assets/icons/default.png",
                        width: 20,
                        height: 20,
                        fit: BoxFit.contain,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: const TextStyle(color: Colors.red, fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
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
