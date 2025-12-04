import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/home/stake_home/stake_cubit.dart';
import 'package:motelapp/logic/cubits/home/stake_home/stake_state.dart';
import 'package:motelapp/presentation/screens/home/functions/function_stake_home/detail_staker/detail_staker.dart';
import 'package:motelapp/presentation/screens/home/functions/function_stake_home/update_stake/update_stake.dart';

import 'package:motelapp/router/app_router.dart';

class DetailStake extends StatefulWidget {
  final int idStake;

  final String status;
  const DetailStake({super.key, required this.idStake, required this.status});

  @override
  State<DetailStake> createState() => _DetailStakeState();
}

class _DetailStakeState extends State<DetailStake> {
  @override
  void initState() {
    super.initState();
    context.read<ContentStakeCubit>().loadDetailStake(widget.idStake);
  }

  // Hàm format tiền (ví dụ: 3000000 -> 3.000.000 đ)
  String _formatMoney(String? amount) {
    if (amount == null) return '0 đ';
    try {
      double value = double.tryParse(amount.replaceAll(',', '')) ?? 0;
      return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(value);
    } catch (e) {
      return '$amount đ';
    }
  }

  // Hàm format ngày (2025-12-30 -> 30-12-2025)
  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '...';
    try {
      DateTime dt = DateTime.parse(date);
      return DateFormat('dd-MM-yyyy').format(dt);
    } catch (e) {
      return date;
    }
  }

  // Hàm hiển thị Popup xác nhận
  Future<void> _showConfirmDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Bắt buộc người dùng phải chọn nút
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // Bo tròn góc giống iOS
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
          content: const Text(
            'Bạn chắc chắn rằng khách hàng đã hủy cọc này?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly, // Căn đều 2 nút
          actions: <Widget>[
            // Nút Huỷ
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Đóng popup
              },
              child: const Text(
                'Huỷ',
                style: TextStyle(
                  color: Colors.grey, // Màu xám cho nút hủy
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            // Nút Đồng ý
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Đóng popup trước

                // Sau đó gọi Cubit để thực hiện hủy cọc
                context.read<ContentStakeCubit>().cancelStake(widget.idStake);
              },
              child: const Text(
                'Đồng ý',
                style: TextStyle(
                  color: Colors.green, // Màu xanh lá giống trong ảnh
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContentStakeCubit, StakeState>(
      listener: (context, state) {
        // Xử lý thành công
        if (state.status == StakeStatus.loaded && state.message != null) {
          // 1. Kiểm tra context an toàn
          if (!context.mounted) return;

          String msg = state.message!.toLowerCase();

          // 2. Hiện thông báo
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2), // Hiện trong 2 giây
              behavior: SnackBarBehavior.floating,
            ),
          );

          // 3. Nếu là Hủy hoặc Xóa -> Thoát màn hình và trả về TRUE
          if (msg.contains('hủy') || msg.contains('xóa')) {
            // Đợi 500ms cho người dùng kịp nhìn thấy màu xanh của SnackBar rồi mới thoát
            Future.delayed(const Duration(milliseconds: 500), () {
              if (context.mounted) {
                Navigator.of(context).pop(true); // <--- Trả về true quan trọng
              }
            });
          }
        }
        // -----------------------------------------------------------
        // 1. XỬ LÝ KHI XÓA THÀNH CÔNG (Dùng status mới của bạn)
        // -----------------------------------------------------------
        if (state.status == StakeStatus.deleteSuccess) {
          // Ẩn Loading (nếu có dialog loading đang hiện) hoặc chỉ cần show thông báo

          // Hiển thị thông báo
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa cọc thành công!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Đợi một chút (500ms) để người dùng kịp thấy thông báo rồi mới thoát
          Future.delayed(const Duration(milliseconds: 500), () {
            if (context.mounted) {
              // QUAN TRỌNG: Trả về 'true' để màn hình danh sách biết mà reload
              Navigator.of(context).pop(true);
            }
          });
        }

        // CASE: Lỗi
        if (state.status == StakeStatus.error && state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: const Text(
            'Chi tiết cọc',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        // Sử dụng BlocBuilder để lắng nghe thay đổi trạng thái
        body: BlocBuilder<ContentStakeCubit, StakeState>(
          builder: (context, state) {
            // 1. Trạng thái Loading
            if (state.status == StakeStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2. Trạng thái Lỗi
            if (state.status == StakeStatus.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Lỗi: ${state.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ContentStakeCubit>().loadDetailStake(
                          widget.idStake,
                        );
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            // 3. Trạng thái Loaded (Có dữ liệu)
            if (state.status == StakeStatus.loaded &&
                state.detailStake != null) {
              final detail = state.detailStake!;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // --- Phần 1: Thông tin chung ---
                    const SizedBox(height: 10),
                    Text(
                      _formatMoney(detail.tienCoc),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildInfoRow(
                      Icons.home_outlined,
                      '${detail.tenPhong ?? ''} - ${detail.tenToanha ?? ''}',
                    ),
                    _buildInfoRow(
                      Icons.calendar_today_outlined,
                      'Ngày hẹn vào ${_formatDate(detail.ngayHenVao)}',
                    ),
                    _buildInfoRow(
                      Icons.calendar_month_outlined,
                      'Ngày nhận cọc ${_formatDate(detail.ngayNhanCoc)}',
                    ),
                    _buildInfoRow(
                      Icons.person_outline,
                      'Người nhận tiền: ${detail.tenNguoiNhan ?? '...'}',
                    ),

                    const SizedBox(height: 20),

                    // --- Phần 2: Danh sách người đặt cọc ---
                    _buildSectionContainer(
                      onTap: () {
                        // Xử lý khi nhấn vào khung người đặt cọc (nếu cần)

                        getIt<AppRouter>().push(
                          DetailStaker(
                            idNguoiThue:
                                detail.danhSachNguoiDatCoc.isNotEmpty
                                    ? detail
                                        .danhSachNguoiDatCoc[0]
                                        .idNguoiDatCoc
                                    : 0,
                          ),
                        );
                      },
                      title: 'Người đặt cọc',
                      child:
                          detail.danhSachNguoiDatCoc.isEmpty
                              ? const Text("Chưa có thông tin người đặt cọc")
                              : Column(
                                children:
                                    detail.danhSachNguoiDatCoc.map((nguoi) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12.0,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                ),
                                              ),
                                              child: const CircleAvatar(
                                                radius: 24,
                                                backgroundColor: Colors.grey,
                                                child: Icon(
                                                  Icons.person,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 15),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  nguoi.tenNguoiDatCoc ??
                                                      'Tên không xác định',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  nguoi.sdtNguoiDatCoc ??
                                                      'Không có SĐT',
                                                  style: const TextStyle(
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                              ),
                    ),
                    const SizedBox(height: 20),
                    // --- Phần 3: Ghi chú ---
                    _buildSectionContainer(
                      title: 'Ghi chú',
                      child: Container(
                        height: 120,
                        child: Text(
                          (detail.ghiChuCoc != null &&
                                  detail.ghiChuCoc!.isNotEmpty)
                              ? detail.ghiChuCoc!
                              : 'Không có ghi chú',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height:
                                1.4, // Tăng khoảng cách dòng cho dễ đọc nếu ghi chú dài
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                    // --- Phần 3: Nút hành động ---
                    _buildActionButtons(),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            }

            // Mặc định (khi chưa load)
            return const SizedBox();
          },
        ),
      ),
    );
  }

  // Widget helper tạo dòng thông tin
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[800], fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  // Widget helper tạo khung chứa section
  Widget _buildSectionContainer({
    required String title,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    String currentStatus = widget.status.trim();

    // CASE 1: Hiện 3 nút (Đang chờ, Quá hạn)
    bool showThreeButtons =
        currentStatus == "Đang chờ" ||
        currentStatus == "DangCho" ||
        currentStatus == "Quá hạn" ||
        currentStatus == "QuaHan";

    // CASE 2: Hiện nút Xóa (Khách hủy, Đã tạo HĐ)
    bool showDeleteOnly =
        currentStatus == "Đã tạo hợp đồng" ||
        currentStatus == "DaKyHopDong" ||
        currentStatus.contains("hủy") ||
        currentStatus.contains("huỷ") ||
        currentStatus.contains("KhachHuy");

    if (showThreeButtons) {
      return Column(
        children: [
          // Nút Khách hủy cọc (Giữ nguyên logic cũ hoặc xử lý sau)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB74D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                _showConfirmDialog(context);
              },
              child: const Text(
                'Khách hủy cọc',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Hàng chứa Cập nhật và Xóa
          Row(
            children: [
              // --- NÚT CẬP NHẬT ---
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      final result = await getIt<AppRouter>().push(
                        UpdateStake(idStake: widget.idStake),
                      );
                      if (result == true && context.mounted) {
                        context.read<ContentStakeCubit>().loadDetailStake(
                          widget.idStake,
                        );
                      }
                    },
                    child: const Text(
                      'Cập nhật',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // --- NÚT XÓA (Cần bọc BlocBuilder ở đây) ---
              Expanded(
                child: SizedBox(
                  height: 50,
                  // 1. BỌC BlocBuilder ĐỂ CÓ BIẾN 'state'
                  child: BlocBuilder<ContentStakeCubit, StakeState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF5350),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          // Hiển thị Dialog
                          showDialog(
                            context: context,
                            builder:
                                (dialogContext) => AlertDialog(
                                  title: const Text("Xác nhận xóa"),
                                  content: const Text(
                                    "Bạn có chắc chắn muốn xóa cọc này không? Hành động này không thể hoàn tác.",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () =>
                                              Navigator.of(dialogContext).pop(),
                                      child: const Text("Hủy"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(dialogContext).pop();
                                        // Gọi Cubit xóa
                                        context
                                            .read<ContentStakeCubit>()
                                            .deleteStake(widget.idStake);
                                      },
                                      child: const Text(
                                        "Xóa",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                          );
                        },
                        // 2. GIỜ ĐÃ CÓ state ĐỂ CHECK LOADING
                        child:
                            state.status == StakeStatus.loading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  'Xoá',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else if (showDeleteOnly) {
      // CASE 2: CHỈ HIỆN NÚT XÓA (Cũng cần bọc BlocBuilder)
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: BlocBuilder<ContentStakeCubit, StakeState>(
          builder: (context, state) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF5350),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (dialogContext) => AlertDialog(
                        title: const Text("Xác nhận xóa"),
                        content: const Text(
                          "Bạn có chắc chắn muốn xóa cọc này không?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text("Hủy"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              context.read<ContentStakeCubit>().deleteStake(
                                widget.idStake,
                              );
                            },
                            child: const Text(
                              "Xóa",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                );
              },
              child:
                  state.status == StakeStatus.loading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Text(
                        'Xoá',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            );
          },
        ),
      );
    }

    return const SizedBox();
  }
}
