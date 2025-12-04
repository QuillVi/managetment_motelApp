import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:motelapp/data/models/stake_model.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/home/stake_home/stake_cubit.dart';
import 'package:motelapp/logic/cubits/home/stake_home/stake_state.dart';
import 'package:motelapp/presentation/screens/buttonNavicationBar/buttonNavicationBar.dart';
import 'package:motelapp/presentation/screens/home/functions/function_stake_home/add_stake/add_stake.dart';
import 'package:motelapp/presentation/screens/home/functions/function_stake_home/detail_stake/detail_stake.dart';
import 'package:motelapp/router/app_router.dart';

class StakeHome extends StatefulWidget {
  const StakeHome({super.key});

  @override
  State<StakeHome> createState() => _StakeHomeState();
}

class _StakeHomeState extends State<StakeHome> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  // --- HELPER: Hàm chuyển đổi Enum API sang Tiếng Việt hiển thị ---
  String _mapStatusToVN(String? apiStatus) {
    switch (apiStatus) {
      case 'DangCho':
        return 'Đang chờ';
      case 'QuaHan':
        return 'Quá hạn';
      case 'KhachHuy':
        return 'Khách hủy cọc';
      case 'DaKyHopDong':
        return 'Đã tạo hợp đồng';
      default:
        return 'Khác';
    }
  }

  // --- 1. Hàm tính toán Summary (Cập nhật logic mapping) ---
  StakeSummary _calculateSummaryFromList(List<ContentStakeModel> list) {
    Map<String, int> counts = {
      'DangCho': 0,
      'QuaHan': 0,
      'KhachHuy': 0,
      'DaKyHopDong': 0,
    };
    Map<String, double> amounts = {
      'DangCho': 0.0,
      'QuaHan': 0.0,
      'KhachHuy': 0.0,
      'DaKyHopDong': 0.0,
    };

    for (var item in list) {
      // Lấy trạng thái từ API (DangCho, QuaHan...)
      String status = item.trangThai ?? '';

      // Parse tiền
      double money =
          double.tryParse((item.tienCoc ?? '0').replaceAll(',', '')) ?? 0.0;

      if (counts.containsKey(status)) {
        counts[status] = (counts[status] ?? 0) + 1;
        amounts[status] = (amounts[status] ?? 0.0) + money;
      }
    }

    String format(double n) => NumberFormat('#,##0', 'vi_VN').format(n);

    return StakeSummary(
      dangChoValue:
          '${counts['DangCho']} cọc - ${format(amounts['DangCho']!)} đ',
      quaHanValue: '${counts['QuaHan']} cọc - ${format(amounts['QuaHan']!)} đ',
      huyCocValue:
          '${counts['KhachHuy']} cọc - ${format(amounts['KhachHuy']!)} đ',
      daTaoHDValue:
          '${counts['DaKyHopDong']} cọc - ${format(amounts['DaKyHopDong']!)} đ',
    );
  }

  String _formatCurrencyCard(String amount) {
    try {
      double value = double.tryParse(amount.replaceAll(',', '')) ?? 0.0;
      final formatter = NumberFormat('#,##0', 'vi_VN');
      return '${formatter.format(value)} đ';
    } catch (e) {
      return '$amount đ';
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<ContentStakeCubit>().loadContentStake();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text(
              'Cọc giữ chỗ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () => getIt<AppRouter>().push(Buttonnavicationbar()),
            ),
            actions: const [
              Icon(Icons.filter_alt_outlined, color: Colors.orange),
              SizedBox(width: 16),
            ],
          ),
          body: BlocBuilder<ContentStakeCubit, StakeState>(
            builder: (context, state) {
              // DEBUG STATUS
              print("Current State in Home: ${state.status}");

              // 1. TRƯỜNG HỢP LOADING (Ưu tiên cao nhất)
              // Chỉ hiện loading xoay to đùng nếu CHƯA CÓ dữ liệu
              if (state.status == StakeStatus.loading &&
                  state.dataContentStake == null) {
                return const Center(child: CircularProgressIndicator());
              }

              // 2. TRƯỜNG HỢP ERROR
              if (state.status == StakeStatus.error &&
                  state.dataContentStake == null) {
                return Center(child: Text('Lỗi: ${state.error}'));
              }

              // 3. TRƯỜNG HỢP CÓ DỮ LIỆU (HIỆN DANH SÁCH)
              // SỬA Ở ĐÂY: Không check status == loaded nữa, mà check data != null
              // Điều này giúp hiển thị danh sách ngay cả khi status là 'deleteSuccess'
              if (state.dataContentStake != null) {
                final fullList = state.dataContentStake!;

                if (fullList.isEmpty) {
                  return const Center(
                    child: Text('Chưa có cọc nào. Bấm nút + để thêm mới.'),
                  );
                }

                final StakeSummary summaryData = _calculateSummaryFromList(
                  fullList,
                );

                return DefaultTabController(
                  length: 4,
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      _buildSummaryStatus(summaryData),
                      const SizedBox(height: 12),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: TabBar(
                          indicatorColor: Colors.green,
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.grey,
                          dividerHeight: 0,
                          isScrollable: true,
                          tabs: [
                            Tab(text: 'Chờ phòng'),
                            Tab(text: 'Quá hạn'),
                            Tab(text: 'Khách hủy cọc'),
                            Tab(text: 'Đã tạo hợp đồng'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildTabContent(fullList, 'DangCho'),
                            _buildTabContent(fullList, 'QuaHan'),
                            _buildTabContent(fullList, 'KhachHuy'),
                            _buildTabContent(fullList, 'DaKyHopDong'),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              // 4. FALLBACK (QUAN TRỌNG):
              // Nếu trạng thái là Initial hoặc khác, vẫn hiện Loading thay vì màn hình trắng
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),

        // Nút Floating Action Button (FAB) tự chế
        Positioned(
          bottom: 84,
          right: 24,
          child: GestureDetector(
            onTap: () async {
              // Thêm async/await nếu muốn reload sau khi thêm mới
              final result = await getIt<AppRouter>().push(AddStake());
              if (result == true && context.mounted) {
                context.read<ContentStakeCubit>().loadContentStake();
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

  Widget _buildTabContent(
    List<ContentStakeModel> fullList,
    String requiredApiStatus,
  ) {
    final filteredStakes =
        fullList.where((stake) {
          // 1. Check Status (So sánh mã API)
          String status = stake.trangThai ?? '';
          if (status != requiredApiStatus) return false;

          // 2. Check Search
          if (_searchText.isEmpty) return true;

          String searchLower = _searchText.toLowerCase();
          String tenNguoi = (stake.ten ?? '').toLowerCase();
          String tenPhong = (stake.tenPhong ?? '').toLowerCase();
          String tenToaNha = (stake.tenToanha ?? '').toLowerCase();

          return tenNguoi.contains(searchLower) ||
              tenPhong.contains(searchLower) ||
              tenToaNha.contains(searchLower);
        }).toList();

    return Column(
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchText = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Tìm theo tên khách, tên phòng...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon:
                  _searchText.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchText = '';
                          });
                        },
                      )
                      : null,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (filteredStakes.isEmpty)
          const Expanded(
            child: Center(child: Text('Không tìm thấy dữ liệu phù hợp')),
          ),
        if (filteredStakes.isNotEmpty)
          Expanded(child: _buildDepositCard(filteredStakes)),
      ],
    );
  }

  Widget _buildDepositCard(List<ContentStakeModel> stakes) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: stakes.length,
      itemBuilder: (context, index) {
        final stake = stakes[index];
        return GestureDetector(
          onTap: () async {
            // 1. Chờ kết quả trả về từ DetailStake
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => DetailStake(
                      idStake: stake.idCoc,
                      status: _mapStatusToVN(stake.trangThai),
                    ),
              ),
            );
            print("id coc: ${stake.idCoc}");

            // 2. Debug: In ra để xem có nhận được true không
            print("Kết quả trả về từ Detail: $result");

            // 3. Nếu kết quả là TRUE -> Reload danh sách
            if (result == true) {
              // Kiểm tra context an toàn trước khi gọi Cubit
              if (context.mounted) {
                print("Đang reload danh sách...");
                context.read<ContentStakeCubit>().loadContentStake();
              }
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, size: 18, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        stake.ten ?? 'Tên trống',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.home_outlined,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text('${stake.tenPhong} - ${stake.tenToanha}'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 6),
                          Text('Ngày dự kiến'), // Sửa label cho đúng nghĩa
                        ],
                      ),
                      Text(
                        stake.ngayBatdau ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      _formatCurrencyCard(stake.tienCoc ?? ''),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryStatus(StakeSummary summary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFDFF5DC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _SummaryItem(
                      title: 'Đang chờ',
                      value: summary.dangChoValue,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _SummaryItem(
                      title: 'Khách hủy cọc',
                      value: summary.huyCocValue,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
              const VerticalDivider(
                color: Colors.black26,
                thickness: 1,
                width: 24,
                indent: 8,
                endIndent: 8,
              ),
              Expanded(
                child: Column(
                  children: [
                    _SummaryItem(
                      title: 'Quá hạn',
                      value: summary.quaHanValue,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    _SummaryItem(
                      title: 'Đã tạo hợp đồng',
                      value: summary.daTaoHDValue,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: color),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class StakeSummary {
  final String dangChoValue;
  final String quaHanValue;
  final String huyCocValue;
  final String daTaoHDValue;

  StakeSummary({
    required this.dangChoValue,
    required this.quaHanValue,
    required this.huyCocValue,
    required this.daTaoHDValue,
  });
}
