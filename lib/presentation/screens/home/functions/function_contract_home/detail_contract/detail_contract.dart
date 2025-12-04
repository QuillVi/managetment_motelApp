import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // Gợi ý: Dùng để format tiền và ngày tháng
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/home/contract_home/contract_cubit.dart';
import 'package:motelapp/logic/cubits/home/contract_home/contract_state.dart';
import 'package:motelapp/presentation/screens/home/functions/function_contract_home/detail_contract/pdf_invoice_contract.dart';
import 'package:motelapp/presentation/screens/home/functions/function_contract_home/detail_contract/update_contract.dart';
import 'package:motelapp/router/app_router.dart';

class DetailContract extends StatefulWidget {
  final int idHopDong;
  const DetailContract({super.key, required this.idHopDong});

  @override
  State<DetailContract> createState() => _DetailContractState();
}

class _DetailContractState extends State<DetailContract> {
  @override
  void initState() {
    super.initState();
    // Gọi API lấy dữ liệu khi màn hình mở
    context.read<ListContractCubit>().LoadDetailContract(widget.idHopDong);
  }

  // Hàm tiện ích format tiền tệ (Ví dụ: 2000000.00 -> 2,000,000 đ)
  String formatCurrency(String value) {
    try {
      final double number = double.parse(value);
      final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
      return formatter.format(number);
    } catch (e) {
      return '$value đ';
    }
  }

  //Hàm tiện ích chuyển đổi kỳ thanh toán
  String _getTenKyThanhToan(String key) {
    switch (key) {
      case 'Thang':
        return 'tháng';
      case 'Nam':
        return 'năm';
      case 'Quy':
        return 'quý';
      default:
        return key; // Nếu không khớp thì giữ nguyên
    }
  }

  // Hàm hiển thị hộp thoại xác nhận xóa
  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Xác nhận xóa"),
          content: const Text(
            "Bạn có chắc chắn muốn xóa hợp đồng này không?\n\nHành động này không thể hoàn tác và sẽ xóa các hóa đơn chưa thanh toán liên quan.",
          ),
          actions: [
            // Nút Hủy
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
            ),
            // Nút Xóa
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Gọi Cubit để thực hiện API xóa
                // Lưu ý: Đảm bảo bạn đã có hàm deleteContract trong Cubit như các bước trước
                context.read<ListContractCubit>().deleteContract(
                  widget.idHopDong,
                );
              },
              child: const Text("Xóa", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Hàm hiển thị hộp thoại xác nhận thanh lý
  void _showLiquidateConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Xác nhận thanh lý"),
          content: const Text(
            "Bạn muốn kết thúc hợp đồng này ngay bây giờ?\n\n"
            "- Trạng thái sẽ chuyển sang 'Đã thanh lý'.\n"
            "- Phòng sẽ được cập nhật thành 'Trống'.\n"
            "- Các hóa đơn chưa thanh toán sẽ bị hủy.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Đóng dialog

                // Gọi Cubit
                context.read<ListContractCubit>().liquidateContract(
                  widget.idHopDong,
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Text(
                  "Thanh lý ngay",
                  style: TextStyle(color: Colors.white),
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
    return BlocListener<ListContractCubit, ListContractState>(
      listener: (context, state) {
        // --- PHẦN CHO XÓA ---
        // 1. Đang xóa: Hiện loading
        if (state.status == ListContractIsActiveStatus.deleting) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => const Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Xóa thành công
        if (state.status == ListContractIsActiveStatus.deleteSuccess) {
          Navigator.of(context).pop(); // Tắt loading
          //Quay lại màn hình và trả ra tính hiện true để refresh danh sách
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa hợp đồng thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // 3. Xóa thất bại
        if (state.status == ListContractIsActiveStatus.deleteFailure) {
          Navigator.of(context).pop(); // Tắt loading
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text("Lỗi"),
                  content: Text(state.errorMessage ?? "Không thể xóa hợp đồng"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Đóng"),
                    ),
                  ],
                ),
          );
        }

        // --- PHẦN CHO THANH LÝ ---

        // 1. Đang thanh lý: Hiện loading
        if (state.status == ListContractIsActiveStatus.liquidating) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => const Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Thanh lý thành công
        if (state.status == ListContractIsActiveStatus.liquidateSuccess) {
          Navigator.of(context).pop(); // Tắt loading dialog

          // Quan trọng: Trả về TRUE để màn hình danh sách load lại data
          Navigator.of(context).pop(true);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thanh lý hợp đồng thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // 3. Thanh lý thất bại
        if (state.status == ListContractIsActiveStatus.liquidateFailure) {
          Navigator.of(context).pop(); // Tắt loading dialog
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text("Lỗi"),
                  content: Text(state.errorMessage ?? "Thất bại"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Đóng"),
                    ),
                  ],
                ),
          );
        }
      },

      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Chi tiết Hợp đồng',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => getIt<AppRouter>().pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.description_outlined,
                color: Colors.orange,
              ),
              onPressed: () async {
                // 1. Lấy dữ liệu từ State của Cubit hiện tại
                final state = context.read<ListContractCubit>().state;

                // 2. Kiểm tra xem dữ liệu đã load xong chưa
                if (state.detailContractModel != null) {
                  // 3. Gọi service in PDF
                  final pdfService = PdfInvoiceContract();

                  // Hiển thị loading nếu cần (hoặc thư viện printing tự hiện loading)
                  await pdfService.printContract(state.detailContractModel!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đang tải dữ liệu, vui lòng đợi...'),
                    ),
                  );
                }
              },
            ),
            SizedBox(width: 16),
            Icon(Icons.share_outlined, color: Colors.orange),
            SizedBox(width: 16),
          ],
        ),
        body: BlocBuilder<ListContractCubit, ListContractState>(
          builder: (context, state) {
            // 1. Trạng thái Loading
            if (state.status == ListContractIsActiveStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2. Trạng thái Error
            if (state.status == ListContractIsActiveStatus.error) {
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
                    Text('Lỗi: ${state.errorMessage}'),
                    ElevatedButton(
                      onPressed:
                          () => context
                              .read<ListContractCubit>()
                              .LoadDetailContract(widget.idHopDong),
                      child: const Text("Thử lại"),
                    ),
                  ],
                ),
              );
            }

            // 3. Trạng thái Loaded (Có dữ liệu)
            final detail = state.detailContractModel;
            if (detail == null) {
              return const Center(
                child: Text("Không tìm thấy dữ liệu hợp đồng"),
              );
            }

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                /// Mã hợp đồng + ngày bắt đầu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'HĐ #${detail.idHopDong}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF013351),
                      ),
                    ),
                    Text(
                      detail.ngayBatDau, // Bạn có thể format lại ngày nếu cần
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                /// Phòng & Tòa nhà
                Row(
                  children: [
                    const Icon(
                      Icons.home_outlined,
                      size: 20,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${detail.tenPhong} - ${detail.tenToaNha}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                /// Thời hạn
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      size: 20,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Thời hạn: ${detail.thoiHan} tháng',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                /// Người tạo
                Row(
                  children: [
                    const Icon(
                      Icons.account_box_outlined,
                      size: 20,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text('Người tạo: ${detail.tenNguoiTao}'),
                  ],
                ),
                const Divider(height: 24),

                /// Thông tin tài chính
                _infoRow('Tiền phòng', formatCurrency(detail.tienPhong)),
                _infoRow('Tiền cọc', formatCurrency(detail.tienCoc)),
                _infoRow(
                  'Kỳ thanh toán',
                  '1 ${_getTenKyThanhToan(detail.kyThanhToan)}',
                ),

                const SizedBox(height: 16),

                /// Các nút hành động
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _actionButton('Chỉnh sửa', Colors.orange, () async {
                      // Thêm await để đợi màn hình Update đóng lại và nhận kết quả
                      final result = await getIt<AppRouter>().push(
                        UpdateContract(idHopDong: detail.idHopDong),
                      );

                      // Kiểm tra kết quả trả về
                      if (result == true) {
                        print(
                          "Đã nhận tín hiệu update thành công, đang reload...",
                        );

                        // Gọi Cubit để tải lại dữ liệu chi tiết mới nhất
                        if (context.mounted) {
                          context.read<ListContractCubit>().LoadDetailContract(
                            detail.idHopDong,
                          );

                          // Nếu bạn muốn reload cả danh sách bên ngoài luôn (nếu cần thiết):
                          context.read<ListContractCubit>().LoadListContract();
                        }
                      }
                    }),
                    _actionButton('Xoá', Colors.red, () {
                      // gọi hàm hiển thị dialog xác nhận xóa
                      _showDeleteConfirmDialog(context);
                    }),
                    _actionButton('Thanh lý', Colors.green, () {
                      // gọi hàm hiển thị dialog xác nhận thanh lý
                      _showLiquidateConfirmDialog(context);
                    }),
                  ],
                ),

                const SizedBox(height: 24),
                const Divider(height: 24),

                /// Danh sách Người thuê phòng
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Người thuê phòng',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '(${detail.listNguoiThue.length})',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Hiển thị danh sách người thuê động từ mảng listNguoiThue
                if (detail.listNguoiThue.isEmpty)
                  const Text(
                    "Chưa có người thuê",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  )
                else
                  ...detail.listNguoiThue.map((tenant) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[100],
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.person,
                                size: 28,
                                color: Colors.blueGrey,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tenant.tenNguoiThue,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  tenant.soDienThoai ?? 'Chưa có SĐT',
                                  style: const TextStyle(color: Colors.green),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                const SizedBox(height: 24),

                /// Điều khoản
                GestureDetector(
                  onTap: () {
                    // Mở màn hình xem điều khoản chi tiết
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Điều khoản hợp đồng',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: const Size(90, 40), // Đảm bảo nút không quá nhỏ
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }
}
