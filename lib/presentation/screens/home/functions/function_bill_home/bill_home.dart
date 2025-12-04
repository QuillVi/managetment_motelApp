import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:motelapp/data/models/bill_model.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/home/bill_home/bill_cubit.dart';
import 'package:motelapp/logic/cubits/home/bill_home/bill_state.dart';
import 'package:motelapp/presentation/screens/buttonNavicationBar/buttonNavicationBar.dart';
import 'package:motelapp/presentation/screens/home/functions/function_bill_home/detail_bill/detail_bill.dart';
import 'package:motelapp/presentation/screens/home/functions/function_bill_home/make_bill/make_bill.dart';
import 'package:motelapp/router/app_router.dart';

class BillHome extends StatefulWidget {
  const BillHome({super.key});

  @override
  State<BillHome> createState() => _BillHomeState();
}

class _BillHomeState extends State<BillHome> with TickerProviderStateMixin {
  late TabController _monthTabController;
  late List<String> monthLabels;
  late int currentMonthIndex;

  // Biến để lưu trữ từ khoá tìm kiếm
  String _searchKey = '';

  // Danh sách các trạng thái (phải khớp với các tab)
  final List<String> statusStrings = [
    'Chưa tạo hóa đơn',
    'Chưa thanh toán',
    'Quá hạn', // API của bạn chưa có trạng thái này, nhưng UI có
    'Đã thanh toán',
  ];

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    currentMonthIndex = now.month - 1; // 0-11

    monthLabels = List.generate(12, (index) {
      return index == currentMonthIndex
          ? 'Tháng này'
          : '${(index + 1).toString().padLeft(2, '0')}-${now.year}';
    });

    _monthTabController = TabController(
      length: 12,
      vsync: this,
      initialIndex: currentMonthIndex,
    );

    // Gọi Cubit để tải dữ liệu ngay khi vào màn hình
    context.read<BillCubit>().LoadListBill();
  }

  @override
  void dispose() {
    _monthTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng BlocBuilder để lắng nghe thay đổi trạng thái từ BillCubit
    return BlocBuilder<BillCubit, BillState>(
      builder: (context, state) {
        // 1. Xử lý các trạng thái Loading và Error
        if (state.status == BillStatus.loading) {
          return Scaffold(
            appBar: _buildAppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == BillStatus.error) {
          return Scaffold(
            appBar: _buildAppBar(),
            body: Center(child: Text(state.errorMessage ?? 'Có lỗi xảy ra')),
          );
        }

        // 2. Trạng thái Loaded: Lấy danh sách hóa đơn
        // Nếu state.billModel là null, gán nó bằng một danh sách rỗng
        final allBills = state.billModel ?? [];

        // 3. Xây dựng UI chính khi đã có dữ liệu (hoặc danh sách rỗng)
        return DefaultTabController(
          length: 4, // 4 tab trạng thái
          child: Stack(
            children: [
              Scaffold(
                backgroundColor: Colors.white,
                appBar: _buildAppBar(),
                body: TabBarView(
                  controller: _monthTabController,
                  // Tạo 12 trang (1 trang cho mỗi tháng)
                  children: List.generate(12, (monthIndex) {
                    // LỌC DỮ LIỆU THEO THÁNG
                    // monthIndex là 0-11, DateTime.month là 1-12
                    final int currentMonth = monthIndex + 1;
                    final billsForThisMonth =
                        allBills.where((bill) {
                          // Chuyển đổi 'ngay_thang' (VD: "2023-02-05") sang DateTime
                          // Bọc trong try-catch để tránh lỗi parse
                          try {
                            final billDate = DateTime.parse(
                              bill.ngay_thanh_toan,
                            );
                            return billDate.month == currentMonth;
                          } catch (e) {
                            return false;
                          }
                        }).toList();

                    final List<List<BillModel>> billsByStatus =
                        statusStrings.map((status) {
                          return billsForThisMonth
                              .where(
                                (bill) => bill.trang_thai_hoa_don == status,
                              )
                              .toList();
                        }).toList();

                    // Lấy số lượng cho từng tab trạng thái
                    final List<int> countsByStatus =
                        billsByStatus.map((list) => list.length).toList();

                    // Đây là UI cho 1 trang (1 tháng)
                    return Column(
                      children: [
                        // Tab Bar TRẠNG THÁI (lồng bên trong)
                        TabBar(
                          isScrollable: true,
                          indicatorColor: Colors.green,
                          labelColor: Colors.green,
                          unselectedLabelColor: Colors.black,
                          dividerHeight: 0,
                          tabs: [
                            Tab(
                              text: 'Chưa tạo hóa đơn \t${countsByStatus[0]}',
                            ),
                            Tab(text: 'Chưa thanh toán \t${countsByStatus[1]}'),
                            Tab(text: 'Quá hạn \t\t${countsByStatus[2]}'),
                            Tab(text: 'Đã thanh toán \t${countsByStatus[3]}'),
                          ],
                        ),
                        // Tab View TRẠNG THÁI (lồng bên trong)
                        Expanded(
                          child: TabBarView(
                            children: List.generate(4, (statusIndex) {
                              // Lấy danh sách hóa đơn đã được lọc
                              final filteredBills = billsByStatus[statusIndex];

                              // Nếu không có hóa đơn nào, hiển thị tab trống
                              if (filteredBills.isEmpty) {
                                return _buildEmptyTab();
                              }

                              // ⭐️ ĐIỀU KIỆN HIỂN THỊ CỦA BẠN ⭐️
                              if (statusIndex == 0) {
                                // Tab 0: 'Chưa tạo hóa đơn' (Hình 1)
                                return _buildInvoiceList(filteredBills);
                              } else {
                                // Tab 1, 2, 3: (Hình 2)
                                return _buildDetailedInvoiceList(filteredBills);
                              }
                            }),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
              // Nút Floating Action Button
              if (allBills.isNotEmpty) _buildFloatingActionButton(allBills),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () => getIt<AppRouter>().push(const Buttonnavicationbar()),
      ),
      centerTitle: true,
      title: const Text(
        'Hoá đơn',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black),
          onPressed: () {},
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: TabBar(
          isScrollable: true,
          controller: _monthTabController,
          indicatorColor: Colors.green,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.black54,
          dividerHeight: 0,
          tabs: monthLabels.map((label) => Tab(text: label)).toList(),
        ),
      ),
    );
  }

  // Tách nút FAB ra
  Widget _buildFloatingActionButton(List<BillModel> bills) {
    return Positioned(
      bottom: 84,
      right: 24,
      child: GestureDetector(
        onTap: () {
          getIt<AppRouter>().push(
            MakeBill(
              idHoaDon: bills.last.id_hoadon,
              idNguoiThue: bills.last.id_nguoithue,
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
    );
  }

  // Sửa đổi _buildInvoiceList để nhận vào 1 danh sách
  Widget _buildInvoiceList(List<BillModel> bills) {
    // --- 1. LOGIC LỌC DỮ LIỆU ---
    // Lọc danh sách bills dựa trên từ khóa _searchKey
    final filteredBills =
        bills.where((bill) {
          final keyword = _searchKey.toLowerCase();

          // Lấy các tên cần tìm, chuyển về chữ thường và kiểm tra null
          final tenPhong = bill.ten_phong?.toLowerCase() ?? '';
          final tenToanha = bill.ten_toanha?.toLowerCase() ?? '';
          final tenNguoiThue = bill.ten_nguoithue?.toLowerCase() ?? '';

          // Điều kiện: Từ khóa xuất hiện trong Tên phòng HOẶC Tòa nhà HOẶC Người thuê
          return tenPhong.contains(keyword) ||
              tenToanha.contains(keyword) ||
              tenNguoiThue.contains(keyword);
        }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm theo tên phòng, người thuê...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              // Thêm nút X để xóa nhanh nội dung tìm kiếm
              suffixIcon:
                  _searchKey.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchKey = '';
                          });
                        },
                      )
                      : null,
            ),
            // --- 2. CẬP NHẬT TỪ KHÓA ---
            onChanged: (value) {
              setState(() {
                _searchKey = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // --- 3. HIỂN THỊ DANH SÁCH ĐÃ LỌC ---
          Expanded(
            child:
                filteredBills.isEmpty
                    ? const Center(child: Text("Không tìm thấy kết quả nào"))
                    : ListView.builder(
                      itemCount: filteredBills.length, // Dùng danh sách đã lọc
                      itemBuilder: (context, index) {
                        final bill =
                            filteredBills[index]; // Lấy item từ danh sách đã lọc

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: () {
                              getIt<AppRouter>().push(
                                MakeBill(
                                  idHoaDon: bill.id_hoadon,
                                  idNguoiThue: bill.id_nguoithue,
                                ),
                              );
                            },
                            child: Card(
                              color: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.receipt_long_outlined,
                                ),
                                title: Text(
                                  '${bill.ten_phong} - ${bill.ten_toanha}',
                                ),
                                subtitle: Text(
                                  bill.ten_nguoithue ?? 'Chưa có người thuê',
                                ),

                                trailing: _buildStatusTag(
                                  bill.trang_thai_thue_phong ?? '',
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedInvoiceList(List<BillModel> bills) {
    // Bộ định dạng số tiền
    final formatter = NumberFormat('#,###');

    // --- 1. LOGIC LỌC DỮ LIỆU ---
    // Lọc danh sách bills dựa trên từ khóa _searchKey
    final filteredBills =
        bills.where((bill) {
          final keyword = _searchKey.toLowerCase();

          // Lấy các dữ liệu cần tìm kiếm, chuyển về chữ thường để so sánh
          final idHoaDon = bill.id_hoadon?.toString().toLowerCase() ?? '';
          final tenPhong = bill.ten_phong?.toLowerCase() ?? '';
          final tenToanha = bill.ten_toanha?.toLowerCase() ?? '';

          // Điều kiện: Từ khóa xuất hiện trong ID hóa đơn HOẶC tên phòng HOẶC tên tòa nhà
          return idHoaDon.contains(keyword) ||
              tenPhong.contains(keyword) ||
              tenToanha.contains(keyword);
        }).toList();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Tìm theo số hóa đơn, phòng, tòa nhà...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              // Thêm nút X để xóa nhanh nội dung tìm kiếm (Trải nghiệm người dùng tốt hơn)
              suffixIcon:
                  _searchKey.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchKey = '';
                          });
                        },
                      )
                      : null,
            ),
            // --- 2. CẬP NHẬT TỪ KHÓA KHI NHẬP ---
            onChanged: (value) {
              setState(() {
                _searchKey = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // hiển thị danh sách đã lọc
          Expanded(
            child:
                filteredBills.isEmpty
                    ? const Center(child: Text("Không tìm thấy hóa đơn nào"))
                    : ListView.builder(
                      // Quan trọng: Dùng filteredBills thay vì bills gốc
                      itemCount: filteredBills.length,
                      itemBuilder: (context, index) {
                        final bill = filteredBills[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: () {
                              getIt<AppRouter>().push(
                                DetailBill(idHoaDon: bill.id_hoadon),
                              );
                            },
                            child: Card(
                              color: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '#${bill.id_hoadon ?? 'Chưa lập hóa đơn'}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          '${formatter.format(bill.tong_hop_tien ?? 0)} đ',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 24),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.home_outlined,
                                          color: Colors.grey[700],
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${bill.ten_phong} - ${bill.ten_toanha}',
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Tiền phòng',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        Text(
                                          '${formatter.format(bill.gia_phong ?? 0)} đ',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Tiền dịch vụ',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        Text(
                                          '${formatter.format(bill.tong_tien_dich_vu ?? 0)} đ',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  // Widget helper để hiển thị tag trạng thái
  Widget _buildStatusTag(String status) {
    Color color;
    switch (status) {
      case 'Đang thuê':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(), // Viết hoa cho nhất quán
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Tab rỗng
  Widget _buildEmptyTab() {
    return const Center(
      child: Text(
        'Không có dữ liệu',
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }
}
