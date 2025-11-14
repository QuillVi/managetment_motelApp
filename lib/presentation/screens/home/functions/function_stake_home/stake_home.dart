import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:motelapp/data/models/stake_model.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/home/stake_home/stake_cubit.dart';
import 'package:motelapp/logic/cubits/home/stake_home/stake_state.dart';
import 'package:motelapp/presentation/screens/buttonNavicationBar/buttonNavicationBar.dart';
import 'package:motelapp/presentation/screens/home/functions/function_stake_home/detail_stake/detail_stake.dart';
import 'package:motelapp/router/app_router.dart';
import 'package:provider/provider.dart';

// Model Tổng hợp để đơn giản hóa việc truyền dữ liệu vào Widget Thống kê
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

class StakeHome extends StatefulWidget {
  const StakeHome({super.key});

  @override
  State<StakeHome> createState() => _StakeHomeState();
}

class _StakeHomeState extends State<StakeHome> {
  // --- Hàm tiện ích cho UI ---

  String _formatCurrency(String? amountString) {
    if (amountString == null || amountString.isEmpty) return '0';

    final cleanString = amountString.split('.').first;
    final amount = int.tryParse(cleanString) ?? 0;

    final formatted = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return formatted;
  }

  String _formatCurrencyCard(String amount) {
    try {
      // Chuyển string tiền có dấu .00 thành double
      double value = double.tryParse(amount) ?? 0.0;
      // Format thành chuỗi có dấu phân cách hàng nghìn
      final formatter = NumberFormat('#,##0', 'vi_VN');
      return '${formatter.format(value)} đ';
    } catch (e) {
      return '$amount đ';
    }
  }

  StakeModel? _findStakeByStatus(List<StakeModel> stakes, String status) {
    try {
      return stakes.firstWhere((e) => e.trangThaiCoc == status);
    } catch (e) {
      return null;
    }
  }

  // Hàm tính toán và tạo ra Model Tổng hợp (StakeSummary) từ List API
  StakeSummary _calculateSummary(List<StakeModel> stakes) {
    final dangCho = _findStakeByStatus(stakes, 'Đang chờ');
    final quaHan = _findStakeByStatus(stakes, 'Quá hạn');
    final huyCoc = _findStakeByStatus(stakes, 'Khách huỷ cọc');
    final daTaoHD = _findStakeByStatus(stakes, 'Đã tạo hợp đồng');

    String getValue(StakeModel? stake) {
      if (stake == null) {
        return '0 cọc - 0 đ';
      }
      final count = stake.soLuongCoc ?? 0;
      final tien = _formatCurrency(stake.tongTienCoc);
      return '$count cọc - $tien đ';
    }

    return StakeSummary(
      dangChoValue: getValue(dangCho),
      quaHanValue: getValue(quaHan),
      huyCocValue: getValue(huyCoc),
      daTaoHDValue: getValue(daTaoHD),
    );
  }

  // ---------------------------------------------------------------------

  /// Danh sách các trạng thái THEO ĐÚNG THỨ TỰ CỦA TAB
  final List<String> _tabStatuses = const [
    'Đang chờ',
    'Quá hạn',
    'Khách hủy cọc',
    'Đã tạo hợp đồng',
  ];

  int _findInitialTabIndex(List<StakeModel> stakes) {
    // Lặp qua danh sách trạng thái ưu tiên
    for (int i = 0; i < _tabStatuses.length; i++) {
      final status = _tabStatuses[i];

      try {
        // Tìm bản ghi thống kê tương ứng
        final summary = stakes.firstWhere(
          (stake) => stake.trangThaiCoc == status,
        );

        // Nếu tìm thấy và có dữ liệu, trả về index của tab đó
        if (summary.soLuongCoc > 0) {
          return i;
        }
      } catch (e) {
        // .firstWhere ném lỗi nếu không tìm thấy, chúng ta bỏ qua và tiếp tục
      }
    }

    // Nếu không có tab nào có dữ liệu, trả về tab đầu tiên (index 0)
    return 0;
  }

  @override
  void initState() {
    super.initState();

    //goi api load stake khi vào màn hình
    context.read<StakeCubit>().loadStake();

    //goi api khi load content stake khi vào màn hình
    context.read<ContentStakeCubit>().loadContentStake();
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

          body: BlocBuilder<StakeCubit, StakeState>(
            builder: (context, state) {
              if (state.status == StakeStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state.status == StakeStatus.error) {
                return Center(
                  child: Text(
                    'Lỗi: ${state.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              } else if (state.status == StakeStatus.loaded &&
                  state.dataStake != null) {
                final List<StakeModel> stakes = state.dataStake!;

                final int initialTabIndex = _findInitialTabIndex(stakes);

                if (stakes.isEmpty) {
                  return const Center(
                    child: Text('Không có dữ liệu thống kê nào.'),
                  );
                }

                // Bọc toàn bộ phần nội dung thay đổi bằng DefaultTabController
                return DefaultTabController(
                  length: 4, // Số lượng tab
                  initialIndex: initialTabIndex, // Chỉ mục tab khởi tạo
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      /// Thống kê trạng thái
                      _buildSummaryStatus(stakes),

                      const SizedBox(height: 12),

                      /// Tabs (TabBar)
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
                            Tab(text: 'Khách huỷ cọc'),
                            Tab(text: 'Đã tạo hợp đồng'),
                          ],
                        ),
                      ),

                      Expanded(
                        child: TabBarView(
                          children: [
                            // Tab 1: Chờ phòng
                            // Truyền trạng thái cọc cần lọc vào
                            _buildTabContent('Chờ phòng'),
                            // Tab 2: Quá hạn
                            _buildTabContent('Quá hạn'),
                            // Tab 3: Khách huỷ cọc
                            _buildTabContent('Khách huỷ cọc'),
                            // Tab 4: Đã tạo hợp đồng
                            _buildTabContent('Đã tạo hợp đồng'),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
        Positioned(
          bottom: 84,
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

  Widget _buildTabContent(String requiredStatus) {
    return BlocBuilder<ContentStakeCubit, StakeState>(
      builder: (context, state) {
        if (state.status == StakeStatus.loading) {
          // Hiển thị loading chỉ cho nội dung tab
          return const Center(child: CircularProgressIndicator());
        } else if (state.status == StakeStatus.error) {
          return Center(
            child: Text(
              'Lỗi: ${state.error}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          );
        } else if (state.status == StakeStatus.loaded &&
            state.dataContentStake != null) {
          // Lọc dữ liệu theo trạng thái
          final filteredStakes =
              state.dataContentStake!
                  .where((stake) => stake.trangThaiCoc == requiredStatus)
                  .toList();

          if (filteredStakes.isEmpty) {
            return Center(child: Text('Không có dữ liệu'));
          }

          return Column(
            children: [
              // Khoảng cách 8pt theo yêu cầu
              const SizedBox(height: 8),

              /// Ô tìm kiếm
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo số hoá đơn, phòng...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Truyền dữ liệu đã lọc vào widget hiển thị card
              Expanded(child: _buildDepositCard(filteredStakes)),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }

  /// Widget: Card item cọc giữ chỗ
  // Cập nhật hàm để nhận vào danh sách ContentStakeModel
  Widget _buildDepositCard(List<ContentStakeModel> stakes) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: stakes.length,
      itemBuilder: (context, index) {
        final stake = stakes[index];
        return GestureDetector(
          onTap: () {
            // Điều hướng đến chi tiết cọc giữ chỗ
            // Thay DetailStake() bằng Route cần thiết
            // getIt<AppRouter>().push(DetailStake(stakeId: stake.idNguoiThue));
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
                  /// Tên người
                  Row(
                    children: [
                      const Icon(Icons.person, size: 18, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        stake.ten ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  /// Phòng
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

                  /// Ngày hẹn vào (ngay_batdau)
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
                          Text('Ngày bắt đầu'),
                        ],
                      ),
                      Text(
                        stake.ngayBatdau ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// Giá tiền (tien_coc)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      _formatCurrencyCard(
                        stake.tienCoc ?? '',
                      ), // Sử dụng hàm format
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

  /// Widget: Thống kê trạng thái cọc
  Widget _buildSummaryStatus(List<StakeModel> stakes) {
    final dangCho = _findStakeByStatus(stakes, 'Đang chờ');
    final quaHan = _findStakeByStatus(stakes, 'Quá hạn');
    final huyCoc = _findStakeByStatus(stakes, 'Khách huỷ cọc');
    final daTaoHD = _findStakeByStatus(stakes, 'Đã tạo hợp đồng');

    // 2. Hàm tiện ích để hiển thị giá trị
    String getValue(StakeModel? stake) {
      if (stake == null) {
        return '0 cọc - 0 đ';
      }
      final count = stake.soLuongCoc ?? 0;
      final tien = _formatCurrency(stake.tongTienCoc);
      return '$count cọc - $tien đ';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFDFF5DC),
          borderRadius: BorderRadius.circular(12),
        ),
        // SỬ DỤNG INTRINSICHEIGHT ĐỂ VERTICAL DIVIDER CÓ CHIỀU CAO CHÍNH XÁC
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Cột 1 (Đã thêm Expanded)
              Expanded(
                child: Column(
                  children: [
                    _SummaryItem(
                      title: 'Đang chờ',
                      value: getValue(dangCho),
                      color: Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _SummaryItem(
                      title: 'Khách huỷ cọc',
                      value: getValue(huyCoc),
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),

              // Đường phân cách dọc
              const VerticalDivider(
                color: Colors.black26,
                thickness: 1,
                width: 24,
                indent: 8,
                endIndent: 8,
              ),

              // Cột 2 (Đã thêm Expanded)
              Expanded(
                child: Column(
                  children: [
                    _SummaryItem(
                      title: 'Quá hạn',
                      value: getValue(quaHan),
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    _SummaryItem(
                      title: 'Đã tạo hợp đồng',
                      value: getValue(daTaoHD),
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
