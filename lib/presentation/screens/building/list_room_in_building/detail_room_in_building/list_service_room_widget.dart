import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:motelapp/data/models/service_model.dart';
import 'package:motelapp/logic/cubits/building/detail_building_cubit.dart';
import 'package:motelapp/logic/cubits/building/detail_building_state.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/detail_room_cubit.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/detail_room_state.dart';

// === HELPER FUNCTIONS (Giữ nguyên) ===

// Hàm helper để ánh xạ tên icon từ API sang IconData của Flutter
const String _baseIconPath = 'lib/assets/icons/';

// Hàm helper để ánh xạ tên icon từ API sang đường dẫn asset
String _getAssetPathFromAssetName(String apiIconName) {
  final lowerCaseName = apiIconName.toLowerCase();

  // 1. Loại bỏ đuôi file (nếu có, ví dụ: .png, .jpg)
  final baseName = lowerCaseName.split('.').first;

  // 2. Chuẩn hóa tên để khớp với file asset (ví dụ: "icon_dien")
  // Nếu API trả về "icon_dien.png"
  if (baseName.startsWith('icon_')) {
    // Nếu tên đã khớp, ta thử tìm file đó
    final fullPath = '$_baseIconPath$baseName.png';
    // Trong Flutter, không có cách trực tiếp và hiệu quả để kiểm tra
    // sự tồn tại của asset tại runtime. Chúng ta dựa vào quy ước đặt tên.
    return fullPath;
  }

  // Nếu API trả về tên khác, ta thử ánh xạ thủ công:
  if (lowerCaseName.contains('dien')) return '${_baseIconPath}icon_dien.png';
  if (lowerCaseName.contains('nuoc')) return '${_baseIconPath}icon_nuoc.png';
  if (lowerCaseName.contains('wifi')) return '${_baseIconPath}icon_wifi.png';
  if (lowerCaseName.contains('xe')) return '${_baseIconPath}icon_xe.png';

  // 3. Nếu không tìm thấy icon phù hợp theo tên hoặc ánh xạ, trả về default.png
  return '${_baseIconPath}default.png';
}

// Hàm format tiền tệ
String _formatCurrency(String price) {
  try {
    final double value = double.parse(price);
    final formatter = NumberFormat('#,##0', 'vi_VN');
    return '${formatter.format(value)} đ';
  } catch (e) {
    return price;
  }
}

// === DYNAMIC SERVICE ITEM (StatefulWidget) ===

// Chuyển _buildServiceItem thành StatefulWidget để quản lý Checkbox
class ServiceCheckboxItem extends StatefulWidget {
  final ServiceModel service;
  final bool isSelected;
  final Function(ServiceModel service, bool isSelected) onSelectionChanged;
  const ServiceCheckboxItem({
    super.key,
    required this.service,
    required this.isSelected,
    required this.onSelectionChanged,
  });

  @override
  State<ServiceCheckboxItem> createState() => _ServiceCheckboxItemState();
}

class _ServiceCheckboxItemState extends State<ServiceCheckboxItem> {
  // Trạng thái cục bộ cho Checkbox
  // Khởi tạo mặc định là false. Trong thực tế, cần load từ dữ liệu xem dịch vụ có được kích hoạt không.
  late bool _isChecked;

  @override
  void initState() {
    super.initState();
    // Khởi tạo trạng thái dựa trên biến truyền vào từ cha
    _isChecked = widget.isSelected;
  }

  // Cần thêm hàm này để cập nhật UI nếu dữ liệu từ cha thay đổi (ví dụ khi load xong API)
  @override
  void didUpdateWidget(ServiceCheckboxItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      setState(() {
        _isChecked = widget.isSelected;
      });
    }
  }

  // Widget hiển thị dịch vụ, sử dụng UI tương tự _buildServiceItem gốc
  Widget _buildServiceItem({
    required String title,
    required String price,
    required Widget iconWidget,
    required IconData icon,
    required bool isChecked,
    required ValueChanged<bool?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Checkbox(
            value: isChecked,
            onChanged: onChanged,
            activeColor: Colors.green,
            checkColor: Colors.white,
          ),
          SizedBox(width: 20, height: 20, child: iconWidget),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                price,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.service;

    // 1. Lấy đường dẫn asset
    final assetPath = _getAssetPathFromAssetName(service.icon ?? '');
    final formattedPrice = _formatCurrency(service.phiDichVu.toString());

    // 2. Tạo Widget Image.asset
    final iconWidget = Image.asset(
      assetPath,
      width: 30,
      height: 30,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback an toàn nếu đường dẫn asset sai
        return Image.asset(
          '${_baseIconPath}default.png',
          width: 30,
          height: 30,
        );
      },
    );

    return _buildServiceItem(
      title: widget.service.tenDichVu ?? '',
      price: formattedPrice,
      iconWidget: iconWidget,
      icon: Icons.check,
      isChecked: _isChecked,
      onChanged: (bool? newValue) {
        setState(() {
          _isChecked = newValue!;
        });
        widget.onSelectionChanged(widget.service, newValue!);
      },
    );
  }
}
// === SERVICE LIST WIDGET (StatelessWidget) ===

class ListServiceRoomWidget extends StatelessWidget {
  final Function(ServiceModel service, bool isSelected) onServiceChanged;
  const ListServiceRoomWidget({super.key, required this.onServiceChanged});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailRoomCubit, DetailRoomState>(
      builder: (context, state) {
        if (state.status == DetailRoomStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == DetailRoomStatus.success) {
          // 1. Danh sách TẤT CẢ dịch vụ có thể chọn (Master list)
          final List<ServiceModel> allServices = state.services;

          // 2. Danh sách dịch vụ PHÒNG ĐANG DÙNG (Selected list)
          // Lưu ý: Đảm bảo RoomModel của bạn đã map trường 'dichvu' từ JSON trả về
          final List<ServiceModel> currentRoomServices =
              state.roomDetail?.dichvu ?? [];

          if (allServices.isEmpty) {
            return const Text('Tòa nhà chưa có dịch vụ nào.');
          }

          return Column(
            children:
                allServices.map((service) {
                  // 3. LOGIC QUAN TRỌNG: Kiểm tra xem dịch vụ này có trong phòng chưa
                  // So sánh dựa trên ID
                  final bool isSelected = currentRoomServices.any(
                    (existingService) =>
                        existingService.idDichVu == service.idDichVu,
                  );

                  return ServiceCheckboxItem(
                    key: ValueKey(service.idDichVu),
                    service: service,
                    isSelected: isSelected, // <--- Truyền trạng thái vào đây
                    onSelectionChanged: onServiceChanged,
                  );
                }).toList(),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
