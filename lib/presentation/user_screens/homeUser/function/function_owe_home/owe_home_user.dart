// File: owe_home.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/models/owe_model.dart';
// Giả định: import cubit và state
import 'package:motelapp/logic/cubits/home/owe_home/owe_cubit.dart';
import 'package:motelapp/logic/cubits/home/owe_home/owe_state.dart';
// Giả định: import file format tiền tệ
import 'package:intl/intl.dart';

// Hàm tiện ích format tiền tệ (cần thêm package:intl vào pubspec.yaml)
String formatCurrency(String amount) {
  try {
    final number = double.parse(amount);
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(number)} đ';
  } catch (e) {
    return amount;
  }
}

class OweHomeUser extends StatefulWidget {
  const OweHomeUser({super.key});

  @override
  State<OweHomeUser> createState() => _OweHomeUserState();
}

class _OweHomeUserState extends State<OweHomeUser> {
  // Gọi API khi khởi tạo State
  @override
  void initState() {
    super.initState();
    // Khởi tạo và gọi data khi bắt đầu
    context.read<OweCubit>().loadOweCollect();
    context.read<OweCubit>().loadOweDoned();
  }

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
          title: const Text(
            'Sổ nợ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_alt_outlined, color: Colors.orange),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.help_outline, color: Colors.orange),
              onPressed: () {},
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.green,
            unselectedLabelColor: Colors.black45,
            indicatorColor: Colors.green,
            indicatorWeight: 2,
            dividerHeight: 0,
            tabs: [Tab(text: 'Nợ cần thu'), Tab(text: 'Đã hoàn thành')],
          ),
        ),
        body: Column(
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
            Expanded(
              // Sử dụng BlocBuilder để hiển thị dữ liệu dựa trên trạng thái Cubit
              child: BlocBuilder<OweCubit, OweState>(
                builder: (context, state) {
                  return TabBarView(
                    children: [
                      // Tab 1: Nợ cần thu
                      _CollectDebtList(data: state.collectDebts),
                      // Tab 2: Đã hoàn thành
                      _DoneDebtList(
                        data: state.doneDebts,
                        status: state.doneStatus,
                        error: state.error,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Widget hiển thị danh sách nợ cần thu ---
class _CollectDebtList extends StatelessWidget {
  final List<OweModel> data;
  const _CollectDebtList({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('Không có khoản nợ nào cần thu.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final owe = data[index];
        // Dùng widget _OweCard để hiển thị dữ liệu
        return _OweCard(owe: owe, isCollectDebt: true);
      },
    );
  }
}

// --- Widget hiển thị danh sách đã hoàn thành ---
// --- Widget hiển thị danh sách đã hoàn thành ---
class _DoneDebtList extends StatelessWidget {
  final List<OweModel> data;
  final OweStatus status; // Thêm trạng thái tải riêng
  final String? error; // Thêm trường lỗi

  const _DoneDebtList({
    required this.data,
    required this.status, // Cập nhật constructor
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    // 1. KIỂM TRA LOADING RIÊNG CHO TAB NÀY
    if (status == OweStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. KIỂM TRA LỖI RIÊNG CHO TAB NÀY
    if (status == OweStatus.error) {
      return Center(
        child: Text('Lỗi tải dữ liệu: ${error ?? 'Không xác định'}'),
      );
    }

    // 3. KIỂM TRA DANH SÁCH RỖNG
    if (data.isEmpty) {
      return const Center(child: Text('Chưa có hóa đơn nào được hoàn thành.'));
    }

    // 4. HIỂN THỊ DỮ LIỆU
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final owe = data[index];
        return _OweCard(owe: owe, isCollectDebt: false);
      },
    );
  }
}

// --- Widget chung cho mỗi item (Card) ---
class _OweCard extends StatelessWidget {
  final OweModel owe;
  final bool isCollectDebt; // true: Nợ cần thu, false: Đã hoàn thành

  const _OweCard({required this.owe, required this.isCollectDebt});

  // Widget hiển thị tag trạng thái hoặc số tiền
  Widget _buildStatusTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Xác định màu và text hiển thị ở góc phải
    String rightText =
        isCollectDebt
            ? formatCurrency(owe.soTienNo ?? '0') // Hiển thị số tiền nợ
            : 'Đã thanh toán';

    Color rightColor = isCollectDebt ? Colors.red : Colors.green;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            // Logic chuyển đến chi tiết hóa đơn
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hàng 1: Tòa nhà, Phòng và Trạng thái/Số tiền
                Row(
                  children: [
                    const Icon(Icons.home, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${owe.tenToaNha} - ${owe.tenPhong}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Hiển thị số tiền nợ (đỏ) hoặc Đã thanh toán (xanh)
                    _buildStatusTag(rightText, rightColor),
                  ],
                ),
                // Hàng 2: Người thuê
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 20,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        owe.tenNguoiThue,
                        style: const TextStyle(color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
