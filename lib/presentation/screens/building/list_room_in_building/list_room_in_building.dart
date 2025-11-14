import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/models/room_model.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/building/detail_building_cubit.dart';
import 'package:motelapp/logic/cubits/building/detail_building_state.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/room_in_building_cubit.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/room_in_building_state.dart';
import 'package:motelapp/presentation/screens/building/building_screen.dart';
import 'package:motelapp/presentation/screens/building/list_room_in_building/create_room.dart';
import 'package:motelapp/presentation/screens/building/list_room_in_building/detail_room_in_building/detail_room_in_building.dart';
import 'package:motelapp/presentation/screens/buttonNavicationBar/buttonNavicationBar.dart';
import 'package:motelapp/router/app_router.dart';

class ListRoomInBuilding extends StatefulWidget {
  final int buildingId;
  final String buildingName;
  const ListRoomInBuilding({
    super.key,
    required this.buildingId,
    required this.buildingName,
  });

  @override
  State<ListRoomInBuilding> createState() => _ListRoomInBuildingState();
}

enum RoomFilterStatus { all, rented, available }

class _ListRoomInBuildingState extends State<ListRoomInBuilding> {
  final TextEditingController _searchController = TextEditingController();
  // Định nghĩa các trạng thái lọc

  String _searchQuery = '';
  List<RoomModel> _allRooms = []; // List<RoomModel>

  List<RoomModel> _filteredRooms = [];

  bool _isDataInitialized = false;

  // Biến lưu trữ giá trị lọc hiện tại
  RoomFilterStatus _currentStatusFilter = RoomFilterStatus.all;
  double _currentMinPrice = 0;
  double _currentMaxPrice = 100000000; // Sẽ được cập nhật từ API
  double _maxPriceFromData = 100000000; // Giá tối đa thực tế từ API

  /// HÀM LỌC TỔNG HỢP (THAY THẾ _filterRoomsByName)
  void _applyFilters() {
    List<RoomModel> temp = _allRooms; // Luôn bắt đầu từ danh sách gốc

    // 1. Lọc theo tên (từ ô tìm kiếm)
    // Đảm bảo _searchQuery được cập nhật trong onChanged
    if (_searchQuery.isNotEmpty) {
      temp =
          temp.where((room) {
            return room.tenPhong.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
          }).toList();
    }

    // 2. Lọc theo trạng thái (từ dialog)
    switch (_currentStatusFilter) {
      case RoomFilterStatus.rented: // Đã thuê
        // Dựa trên dữ liệu API: so_nguoi_thue > 0
        temp = temp.where((room) => room.soNguoiThue > 0).toList();
        break;
      case RoomFilterStatus.available: // Trống
        // Dựa trên dữ liệu API: so_nguoi_thue == 0
        temp = temp.where((room) => room.soNguoiThue == 0).toList();
        break;
      case RoomFilterStatus.all: // Tất cả
      default:
        // Không lọc theo trạng thái
        break;
    }

    // 3. Lọc theo giá (từ dialog)
    temp =
        temp.where((room) {
          // Đảm bảo giaPhong là kiểu double/int
          return room.giaPhong >= _currentMinPrice &&
              room.giaPhong <= _currentMaxPrice;
        }).toList();

    // Cập nhật UI
    setState(() {
      _filteredRooms = temp;
    });
  }

  /// Hiển thị Bảng lọc (Modal Bottom Sheet)
  void _showFilterDialog() {
    // Biến tạm thời để lưu trữ lựa chọn BÊN TRONG dialog
    // Chúng chỉ cập nhật state chính khi người dùng nhấn "Áp dụng"
    RoomFilterStatus tempStatus = _currentStatusFilter;
    double tempMinPrice = _currentMinPrice;
    double tempMaxPrice = _currentMaxPrice;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép dialog có thể cuộn và cao
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Dùng StatefulBuilder để UI bên trong dialog
        // (như Radio, Slider) có thể tự cập nhật
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Chỉ chiếm chiều cao cần thiết
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Tiêu đề Dialog ---
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Bộ lọc",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // --- 1. Lọc theo Trạng thái ---
                  const Text(
                    "Trạng thái phòng",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  // Các lựa chọn cho trạng thái
                  RadioListTile<RoomFilterStatus>(
                    title: const Text("Tất cả"),
                    value: RoomFilterStatus.all,
                    groupValue: tempStatus,
                    activeColor: Colors.green, // Màu khi được chọn
                    onChanged: (value) {
                      setDialogState(() {
                        tempStatus = value!;
                      });
                    },
                  ),
                  RadioListTile<RoomFilterStatus>(
                    title: const Text("Đã cho thuê"),
                    value: RoomFilterStatus.rented,
                    groupValue: tempStatus,
                    activeColor: Colors.green,
                    onChanged: (value) {
                      setDialogState(() {
                        tempStatus = value!;
                      });
                    },
                  ),
                  RadioListTile<RoomFilterStatus>(
                    title: const Text("Phòng trống"),
                    value: RoomFilterStatus.available,
                    groupValue: tempStatus,
                    activeColor: Colors.green,
                    onChanged: (value) {
                      setDialogState(() {
                        tempStatus = value!;
                      });
                    },
                  ),
                  const Divider(height: 24),

                  // --- 2. Lọc theo Giá ---
                  Text(
                    "Khoảng giá (đơn vị: đ)",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Hiển thị giá trị đang chọn
                  Text(
                    "${tempMinPrice.toStringAsFixed(0)}đ - ${tempMaxPrice.toStringAsFixed(0)}đ",
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  // Thanh trượt chọn khoảng giá
                  RangeSlider(
                    values: RangeValues(tempMinPrice, tempMaxPrice),
                    min: 0, // Giá thấp nhất là 0
                    max: _maxPriceFromData, // Giá cao nhất lấy từ API
                    divisions: 50, // Chia thanh trượt ra 50 nấc
                    activeColor: Colors.green,
                    labels: RangeLabels(
                      tempMinPrice.toStringAsFixed(0),
                      tempMaxPrice.toStringAsFixed(0),
                    ),
                    onChanged: (RangeValues values) {
                      setDialogState(() {
                        tempMinPrice = values.start;
                        tempMaxPrice = values.end;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // --- 3. Nút Áp dụng ---
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Màu nút
                      foregroundColor: Colors.white, // Màu chữ
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Áp dụng",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      // Cập nhật state chính của Widget
                      setState(() {
                        _currentStatusFilter = tempStatus;
                        _currentMinPrice = tempMinPrice;
                        _currentMaxPrice = tempMaxPrice;
                      });

                      // --- QUAN TRỌNG ---
                      // Gọi hàm lọc tổng để cập nhật UI
                      _applyFilters();
                      // -----------------

                      Navigator.pop(context); // Đóng dialog// Đóng dialog
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Gọi API khi mở màn hình
    context.read<RoomInBuildingCubit>().loadRoomsInBuilding(widget.buildingId);

    context.read<DetailBuildingCubit>().loadBuildingDetail(widget.buildingId);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              shadowColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () {
                  getIt<AppRouter>().push(const Buttonnavicationbar(index: 1));
                },
              ),
              centerTitle: true,
              title: Column(
                children: [
                  Text(
                    widget.buildingName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.filter_alt_outlined,
                    color: Colors.orange,
                  ),
                  onPressed: () {
                    _showFilterDialog();
                  },
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
                tabs: const [
                  Tab(text: 'Danh sách phòng'),
                  Tab(text: 'Chi tiết'),
                ],
              ),
            ),

            body: TabBarView(
              children: [_buildRoomCard(), _buildDetailBuildingCard()],
            ),
          ),

          Positioned(
            bottom: 60,
            right: 24,
            child: GestureDetector(
              onTap: () {
                getIt<AppRouter>().push(
                  CreateRoom(
                    buildingId: widget.buildingId,
                    buildingName: widget.buildingName,
                  ),
                );
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
    String? statusDeposit,
    String? statusRented,
    VoidCallback? onTap, //  thêm vào
  }) {
    return GestureDetector(
      onTap: onTap, // gọi callback thay vì fix cứng Navigator
      child: Container(
        margin: const EdgeInsets.all(4.0),
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
                if (statusDeposit != null && statusDeposit.isNotEmpty)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: _statusTag(statusDeposit, Colors.blue),
                  ),
                if (statusRented != null && statusRented.isNotEmpty)
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

  /// Hàm xây dựng danh sách phòng dưới dạng lưới có thể cuộn (dữ liệu từ Cubit)
  Widget _buildRoomCard() {
    return BlocBuilder<RoomInBuildingCubit, RoomInBuildingState>(
      builder: (context, state) {
        if (state.status == RoomInBuildingStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == RoomInBuildingStatus.error) {
          // Hiển thị thông báo lỗi nếu có
          print("Error: ${state.error}");
          return Center(child: Text("Lỗi: ${state.error}"));
        }

        if (state.status == RoomInBuildingStatus.loaded && state.data != null) {
          if (!_isDataInitialized) {
            _allRooms = state.data!;
            _filteredRooms =
                _allRooms; // Ban đầu, danh sách lọc = danh sách gốc
            _isDataInitialized = true;
          }

          //final rooms = state.data!; // List<RoomModel>

          return Column(
            children: [
              // Ô tìm kiếm
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Tìm kiếm theo tên phòng...',
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                                _applyFilters(); // Gọi hàm lọc với query rỗng
                              },
                            )
                            : null,
                  ),

                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    _applyFilters();
                  },
                ),
              ),
              // Lưới hiển thị phòng
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: _filteredRooms.length,
                  itemBuilder: (context, index) {
                    final room = _filteredRooms[index];
                    return _buildSingleRoomCard(
                      roomNumber: room.tenPhong,
                      price: "${room.giaPhong.toStringAsFixed(0)} đ",
                      tenants: room.soNguoiThue,
                      contracts: 1, // nếu API có hợp đồng thì thay vào đây
                      warnings: 0, // nếu API có cảnh báo thì thay vào đây
                      statusDeposit: room.tienDatCoc > 0 ? "Đã cọc" : null,
                      statusRented: room.soNguoiThue > 0 ? "ĐÃ THUÊ" : null,
                      onTap: () {
                        print("Clicked room id: ${room.idPhong}");
                        print("Clicked room id: ${room.tenPhong}");
                        getIt<AppRouter>().push(
                          DetailRoomInBuilding(
                            roomId: room.idPhong,
                            roomName: room.tenPhong,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        }

        return const SizedBox(); // Trạng thái initial
      },
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

  Widget _buildDetailBuildingCard() {
    return BlocBuilder<DetailBuildingCubit, DetailBuildingState>(
      builder: (context, state) {
        if (state.status == DetailBuildingStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == DetailBuildingStatus.failure) {
          return Center(child: Text("Lỗi: ${state.error}"));
        }

        if (state.status == DetailBuildingStatus.success &&
            state.data != null) {
          final building = state.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vị trí
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 18, color: Colors.grey),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        building.diachi_toanha, // từ API
                        style: const TextStyle(color: Colors.grey),
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
                    children: [
                      InfoColumn(
                        title: "Số phòng",
                        value: building.soPhong.toString(),
                      ),
                      InfoColumn(
                        title: "Số người thuê",
                        value: building.soNguoiThue.toString(),
                      ),
                      InfoColumn(
                        title: "Số tầng",
                        value: building.soTang.toString(),
                      ),
                      InfoColumn(
                        title: "Phí thuê nhà",
                        value: "${building.phiThueNha} ₫",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Thời gian
                Container(
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TimeRow(
                        label: "Mở - đóng cửa",
                        value: "${building.moCua} - ${building.dongCua}",
                      ),
                      TimeRow(
                        label: "Ngày chốt tiền",
                        value: building.ngayChotTien.toString(),
                      ),
                      TimeRow(
                        label: "Chuyển báo trước",
                        value: building.chuyenBaoTruoc.toString(),
                      ),
                      TimeRow(
                        label: "Thời gian nộp tiền",
                        value: building.thoiGianNopTien.toString(),
                        bold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Mô tả
                const Text(
                  "Mô tả",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
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
                  child: Text(building.moTa ?? "Chưa có mô tả"),
                ),
                const SizedBox(height: 24),

                // --- Quản lý tòa nhà (tạm hardcode nếu API chưa có) ---
                const Text(
                  "Quản lý toà nhà",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 120,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4),
                        ],
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(radius: 20, child: Icon(Icons.person)),
                          SizedBox(height: 8),
                          Text(
                            building.quanly?.ten ?? "Chưa có",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            building.quanly?.sdt ?? "Chưa có",
                            style: TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // --- Dịch vụ có phí (tạm hardcode nếu API chưa có) ---
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Dịch vụ có phí",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: List.generate(building.dichvu!.length, (index) {
                        final service = building.dichvu![index];
                        return Center(
                          child: ServiceCard(
                            iconPath: service.icon!,
                            title: service.ten_dichvu!,
                            price: service.phi_dichvu!.toString(),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),

                const SizedBox(height: 24),

                // --- Dịch vụ miễn phí (chưa có API) ---
                const Text(
                  "Dịch vụ miễn phí",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Dữ liệu trống",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // --- Tiện ích toà nhà  ---
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tiện ích toà nhà",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    (building.tien_ich_toanha == null ||
                            building.tien_ich_toanha!.isEmpty)
                        ? const Text(
                          "Dữ liệu trống",
                          style: TextStyle(color: Colors.grey),
                        )
                        : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children:
                                building.tien_ich_toanha!.map((item) {
                                  return Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                      horizontal: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.green),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          item,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                  ],
                ),

                const SizedBox(height: 20),

                // --- Lưu ý cho người thuê ---
                const Text(
                  "Lưu ý cho người thuê",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
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
                  child: Text(building.luu_y_cho_nguoi_thue ?? "Chưa có lưu ý"),
                ),
                const SizedBox(height: 24),

                // --- Ghi chú cho hoá đơn ---
                const Text(
                  "Ghi chú cho hoá đơn",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
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
                  child: Text(building.ghi_chu_hoa_don ?? "Chưa có ghi chú"),
                ),
                const SizedBox(height: 24),

                // --- Nút Xoá tòa nhà ---
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

        return const SizedBox.shrink();
      },
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
