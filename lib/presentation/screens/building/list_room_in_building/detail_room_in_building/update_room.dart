import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:motelapp/core/utils/thousands_formatter.dart';
import 'package:motelapp/data/models/service_model.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/detail_room_cubit.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/detail_room_state.dart';
import 'package:motelapp/presentation/screens/building/list_room_in_building/detail_room_in_building/list_service_room_widget.dart';
import 'package:motelapp/router/app_router.dart';

class UpdateRoom extends StatefulWidget {
  final int roomId;
  const UpdateRoom({super.key, required this.roomId});

  @override
  State<UpdateRoom> createState() => _UpdateRoomState();
}

class _UpdateRoomState extends State<UpdateRoom> {
  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _roomPriceController = TextEditingController();
  final TextEditingController _roomFloorController = TextEditingController();
  final TextEditingController _roomBedRoomController = TextEditingController();
  final TextEditingController _roomLivingRoomController =
      TextEditingController();
  final TextEditingController _roomAcreageController = TextEditingController();
  final TextEditingController _roomTanentController = TextEditingController();
  final TextEditingController _roomDepositController = TextEditingController();
  final TextEditingController _roomDecriptionController =
      TextEditingController();
  final TextEditingController _roomNoteController = TextEditingController();

  final List<ServiceModel> _selectedServicesForPayload = [];

  final List<String> _selectedAmenities = [];
  void _toggleAmenity(String amenity) {
    // Cập nhật trạng thái
    setState(() {
      if (_selectedAmenities.contains(amenity)) {
        _selectedAmenities.remove(amenity);
        // Log khi BỎ CHỌN
        print('  -> Đã BỎ CHỌN "$amenity".');
      } else {
        _selectedAmenities.add(amenity);
        // Log khi CHỌN
        print('  -> Đã CHỌN "$amenity".');
      }
      // Log trạng thái hiện tại
      print('  -> Danh sách tiện ích hiện tại: $_selectedAmenities');
    });
  }

  String _listToCommaSeparatedString(List<String> list) {
    // Nối các phần tử trong danh sách lại với nhau, phân cách bằng dấu phẩy và khoảng trắng.
    return list.join(', ');
  }

  void _handleServiceSelectionChanged(ServiceModel service, bool isSelected) {
    setState(() {
      if (isSelected) {
        if (!_selectedServicesForPayload.any(
          (s) => s.idDichVu == service.idDichVu,
        )) {
          _selectedServicesForPayload.add(service);
        }
      } else {
        _selectedServicesForPayload.removeWhere(
          (s) => s.idDichVu == service.idDichVu,
        );
      }

      // Yêu cầu: In ra chuỗi ID đã chọn sau mỗi lần click
      _printSelectedServiceIds();
    });
  }

  // Hàm tạo chuỗi ID và in ra (theo yêu cầu)
  void _printSelectedServiceIds() {
    final String idString = _selectedServicesForPayload
        .map((s) => s.idDichVu.toString())
        .join(',');

    print('I/flutter (Service IDs): Chuỗi ID dịch vụ đã chọn: $idString');
  }

  // Hàm tạo chuỗi ID để sử dụng trong payload
  String _selectServiceIdString() {
    return _selectedServicesForPayload
        .map((s) => s.idDichVu.toString())
        .join(',');
  }

  Map<String, dynamic> _updateRoomPayload() {
    // 1. Xử lý Dịch vụ: List<ServiceModel> -> String "1,2,5"
    final String serviceIdString = _selectedServicesForPayload
        .map((s) => s.idDichVu.toString())
        .join(',');

    // 2. Xử lý Tiện ích: List<String> -> String "Wifi, Thang máy"
    final String tienIchPhongString = _selectedAmenities.join(', ');

    // 3. Xử lý Tiền tệ: Xóa dấu chấm/phẩy format trước khi parse
    // Ví dụ: "3.000.000" -> "3000000"
    // Dùng replaceAll(RegExp(r'[^0-9]'), '') để chỉ giữ lại số, an toàn nhất
    int giaPhong =
        int.tryParse(
          _roomPriceController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;

    int tienCoc =
        int.tryParse(
          _roomDepositController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;

    double dienTich =
        double.tryParse(_roomAcreageController.text.replaceAll(',', '.')) ??
        0.0;

    // 4. Gom Data
    final Map<String, dynamic> payload = {
      // Quan trọng: Update phải có ID của dòng cần sửa
      "id_phong": widget.roomId,

      "ten_phong": _roomNameController.text.trim(),
      "gia_phong": giaPhong,

      "so_tang": int.tryParse(_roomFloorController.text.trim()) ?? 1,
      "phong_khach": int.tryParse(_roomLivingRoomController.text.trim()) ?? 0,
      "phong_ngu": int.tryParse(_roomBedRoomController.text.trim()) ?? 0,
      "so_nguoi_thue": int.tryParse(_roomTanentController.text.trim()) ?? 1,

      "dien_tich": dienTich,
      "tien_dat_coc": tienCoc,

      "tien_ich_phong": tienIchPhongString,
      "mo_ta_phong": _roomDecriptionController.text.trim(),
      "luu_y_cho_nguoi_thue_phong": _roomNoteController.text.trim(),

      // Key này server của bạn đọc là 'services' hay 'dich_vu' hay 'list_dich_vu'?
      // Dựa vào code cũ của bạn là 'services'
      "services": serviceIdString,
    };

    return payload;
  }

  @override
  void initState() {
    super.initState();
    context.read<DetailRoomCubit>().loadRoomDetail(widget.roomId);
  }

  @override
  void dispose() {
    super.dispose();
    _roomNameController.dispose();
    _roomPriceController.dispose();
    _roomFloorController.dispose();
    _roomBedRoomController.dispose();
    _roomLivingRoomController.dispose();
    _roomAcreageController.dispose();
    _roomTanentController.dispose();
    _roomDepositController.dispose();
    _roomDecriptionController.dispose();
    _roomNoteController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Bọc Scaffold bằng BlocListener để lắng nghe dữ liệu trả về
    return BlocListener<DetailRoomCubit, DetailRoomState>(
      listener: (context, state) {
        // Khi load thành công và có dữ liệu
        if (state.status == DetailRoomStatus.success &&
            state.roomDetail != null) {
          final room = state.roomDetail!;

          // --- PHẦN 1: ĐIỀN DỮ LIỆU VÀO TEXT FIELD (Quan trọng) ---
          // Lưu ý: Controller không cần setState, chỉ cần gán .text

          _roomNameController.text = room.tenPhong ?? '';

          // 1. Tạo formatter cho tiền tệ Việt Nam (dùng dấu chấm phân cách hàng nghìn)
          // locale 'vi_VN' sẽ tự động dùng dấu chấm (.) cho hàng nghìn
          final currencyFormatter = NumberFormat('#,###', 'vi_VN');

          // 2. Điền dữ liệu GIÁ PHÒNG
          // Logic: Parse sang double -> Format thành chuỗi có dấu chấm
          if (room.giaPhong != null) {
            double price = double.tryParse(room.giaPhong.toString()) ?? 0;
            _roomPriceController.text = currencyFormatter.format(
              price,
            ); // Kết quả: "1.000.000"
          } else {
            _roomPriceController.text = '';
          }

          // 3. Điền dữ liệu TIỀN CỌC
          if (room.tienDatCoc != null) {
            double deposit = double.tryParse(room.tienDatCoc.toString()) ?? 0;
            _roomDepositController.text = currencyFormatter.format(
              deposit,
            ); // Kết quả: "1.000.000"
          } else {
            _roomDepositController.text = '';
          }

          _roomFloorController.text = room.soTang?.toString() ?? '1';

          _roomBedRoomController.text = room.phongNgu?.toString() ?? '0';

          _roomLivingRoomController.text = room.phongKhach?.toString() ?? '0';

          // XỬ LÝ DIỆN TÍCH
          if (room.dienTich != null) {
            double acreage = double.tryParse(room.dienTich.toString()) ?? 0;

            // Pattern '#.##':
            // - Nếu là số chẵn (50.0) -> hiển thị "50"
            // - Nếu có số lẻ (50.5) -> hiển thị "50.5"
            // - Nếu nhiều số lẻ (50.567) -> làm tròn thành "50.57" (tùy số lượng dấu #)
            // 'en_US' để đảm bảo dùng dấu chấm (.) cho số thập phân thay vì dấu phẩy
            _roomAcreageController.text = NumberFormat(
              '#.##',
              'en_US',
            ).format(acreage);
          } else {
            _roomAcreageController.text = '';
          }

          _roomTanentController.text = room.soNguoiThue?.toString() ?? '1';

          _roomDecriptionController.text = room.moTaPhong ?? '';

          _roomNoteController.text = room.luuYChoNguoiThuePhong ?? '';

          // --- PHẦN 2: ĐIỀN DỮ LIỆU LIST (Cần setState) ---
          setState(() {
            // 2.1. Xử lý Tiện ích (Chips)
            if (room.tienIchPhong != null && room.tienIchPhong!.isNotEmpty) {
              _selectedAmenities.clear();
              // Tách chuỗi "Wifi, Thang máy" thành List
              _selectedAmenities.addAll(
                room.tienIchPhong!.split(',').map((e) => e.trim()).toList(),
              );
            } else {
              _selectedAmenities.clear();
            }

            // 2.2. Xử lý Dịch vụ (Checkbox)
            if (room.dichvu != null) {
              _selectedServicesForPayload.clear();
              // Add toàn bộ dịch vụ API trả về vào list đã chọn
              _selectedServicesForPayload.addAll(room.dichvu!);
            }
          });
        }

        // --- PHẦN 2: LẮNG NGHE UPDATE  ---
        if (state.updateStatus == UpdateRoomStatus.success) {
          // Tắt loading (nếu có dialog)
          // Hiện thông báo thành công
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Cập nhật phòng thành công!"),
              backgroundColor: Colors.green,
            ),
          );
          // Quay về màn hình trước
          Navigator.of(context).pop(true); // true để màn hình trước reload list
        }

        if (state.updateStatus == UpdateRoomStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Lỗi: ${state.error}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        // AppBar
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () {
              getIt<AppRouter>().pop();
            },
          ),
          title: const Text(
            'Cập nhật phòng',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        // Body
        body: BlocBuilder<DetailRoomCubit, DetailRoomState>(
          builder: (context, state) {
            if (state.status == DetailRoomStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == DetailRoomStatus.failure) {
              return Center(child: Text("Lỗi: ${state.error}"));
            }

            if (state.status == DetailRoomStatus.success &&
                state.roomDetail != null) {
              final room = state.roomDetail!;

              return SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // 1. Tên phòng
                        _buildTextField(
                          controller: _roomNameController,
                          label: 'Tên phòng',
                          hint: room.tenPhong,
                          isRequired: true,
                        ),
                        Divider(
                          color: Colors.grey[300],
                          height: 1,
                          thickness: 1,
                        ),
                        const SizedBox(height: 8),
                        // 2. Giá phòng dự kiến
                        _buildTextField(
                          controller: _roomPriceController,
                          label: 'Giá phòng dự kiến',
                          hint: room.giaPhong.toString(),
                          isRequired: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter
                                .digitsOnly, // Chỉ cho nhập số
                            ThousandsSeparatorInputFormatter(), // Tự động thêm dấu chấm
                          ],
                        ),
                        Divider(
                          color: Colors.grey[300],
                          height: 1,
                          thickness: 1,
                        ),
                        const SizedBox(height: 8),
                        // 3. Tầng
                        _buildTextField(
                          controller: _roomFloorController,
                          label: 'Tầng',
                          hint: room.soTang.toString(),
                          isRequired: true,
                          keyboardType: TextInputType.number,
                        ),
                        Divider(
                          color: Colors.grey[300],
                          height: 1,
                          thickness: 1,
                        ),
                        const SizedBox(height: 8),
                        // 4. Số phòng ngủ & Số phòng khách (trên cùng một hàng)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              // Số phòng ngủ
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: const TextSpan(
                                        text: 'Số phòng ngủ',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: ' *',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _roomBedRoomController,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(fontSize: 16),
                                      decoration: InputDecoration(
                                        hintText: room.phongNgu.toString(),
                                        hintStyle: TextStyle(
                                          color: Colors.black,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.all(0),
                                        isDense: true,
                                        fillColor: Colors.white,

                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Divider(
                                      color: Colors.grey[300],
                                      height: 1,
                                      thickness: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ), // Khoảng cách giữa 2 trường
                              // Số phòng khách
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: const TextSpan(
                                        text: 'Số phòng khách',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: ' *',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _roomLivingRoomController,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(fontSize: 16),
                                      decoration: InputDecoration(
                                        hintText: room.phongKhach.toString(),
                                        hintStyle: TextStyle(
                                          color: Colors.black,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.all(0),
                                        isDense: true,
                                        fillColor: Colors.white,

                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Divider(
                                      color: Colors.grey[300],
                                      height: 1,
                                      thickness: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),
                        // 5. Diện tích (m2)
                        _buildTextField(
                          controller: _roomAcreageController,
                          label: 'Diện tích (m2)',
                          hint: room.dienTich.toString(),
                          isRequired: true,
                          keyboardType: TextInputType.number,
                        ),
                        Divider(
                          color: Colors.grey[300],
                          height: 1,
                          thickness: 1,
                        ),
                        const SizedBox(height: 8),
                        // 6. Giới hạn số người thuê
                        _buildTextField(
                          controller: _roomTanentController,
                          label: 'Giới hạn số người thuê',
                          hint: room.soNguoiThue.toString(),
                          isRequired: true,
                          keyboardType: TextInputType.number,
                        ),
                        Divider(
                          color: Colors.grey[300],
                          height: 1,
                          thickness: 1,
                        ),
                        const SizedBox(height: 8),
                        // 7. Tiền đặt cọc
                        _buildTextField(
                          controller: _roomDepositController,
                          label: 'Tiền đặt cọc',
                          hint: room.tienDatCoc.toString(),
                          isRequired: false, // Trường này không có dấu *
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter
                                .digitsOnly, // Chỉ cho nhập số
                            ThousandsSeparatorInputFormatter(), // Tự động thêm dấu chấm
                          ],
                        ),
                        Divider(
                          color: Colors.grey[300],
                          height: 1,
                          thickness: 1,
                        ),

                        const SizedBox(height: 30),

                        // 1. Tiêu đề Dịch vụ
                        const Text(
                          'Dịch vụ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        // Container thông báo
                        Container(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Text(
                            '(Chỉnh sửa dịch vụ của phòng sẽ không ảnh hưởng tới hợp đồng thuê nhà hiện tại)',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange[800],
                            ),
                          ),
                        ),

                        ListServiceRoomWidget(
                          onServiceChanged: _handleServiceSelectionChanged,
                        ),

                        const SizedBox(height: 30),

                        // 3. Tiêu đề Tiện ích phòng
                        const Text(
                          'Tiện ích phòng',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // KHỐI HIỂN THỊ CHIP TIỆN ÍCH
                        BlocBuilder<DetailRoomCubit, DetailRoomState>(
                          builder: (context, state) {
                            // A. Đang tải
                            if (state.status == DetailRoomStatus.loading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            // B. Thành công
                            if (state.status == DetailRoomStatus.success) {
                              // Lấy danh sách TẤT CẢ tiện ích có trong tòa nhà (để hiển thị options)
                              // Lưu ý: state.utilityList là getter mình đã viết ở bước State trước
                              final List<String> availableAmenities =
                                  state.utilityList;

                              if (availableAmenities.isEmpty) {
                                return const Text(
                                  "Tòa nhà này chưa cấu hình tiện ích nào.",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                );
                              }

                              return Wrap(
                                spacing: 8.0, // Khoảng cách ngang giữa các chip
                                runSpacing: 8.0, // Khoảng cách dọc
                                children:
                                    availableAmenities.map((amenity) {
                                      // Kiểm tra xem tiện ích này có đang được chọn không
                                      final bool isSelected = _selectedAmenities
                                          .contains(amenity);

                                      return FilterChip(
                                        label: Text(amenity),
                                        selected: isSelected,
                                        // Màu nền khi chọn
                                        selectedColor: Colors.green.withOpacity(
                                          0.2,
                                        ),
                                        // Màu dấu tick
                                        checkmarkColor: Colors.green,
                                        // Style chữ
                                        labelStyle: TextStyle(
                                          color:
                                              isSelected
                                                  ? Colors.green[800]
                                                  : Colors.black,
                                          fontWeight:
                                              isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                        ),
                                        // Logic khi bấm vào
                                        onSelected: (bool selected) {
                                          _toggleAmenity(
                                            amenity,
                                          ); // Gọi hàm toggle bạn đã viết
                                        },
                                      );
                                    }).toList(),
                              );
                            }

                            // C. Trường hợp khác
                            return const SizedBox.shrink();
                          },
                        ),

                        const SizedBox(height: 30),

                        // 4. Mô tả phòng
                        const Text(
                          'Mô tả phòng (dùng cho đẩy phòng)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Trường nhập liệu mô tả
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 18,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _roomDecriptionController,
                            maxLines: 5, // Cho phép nhập nhiều dòng
                            decoration: InputDecoration(
                              hintText: room.moTaPhong,
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.black),
                              fillColor: Colors.white,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // 5. Mô tả phòng
                        const Text(
                          'Lưu ý cho người thuê phòng',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Trường nhập liệu mô tả
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 18,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _roomNoteController,
                            maxLines: 5, // Cho phép nhập nhiều dòng
                            decoration: InputDecoration(
                              hintText: room.luuYChoNguoiThuePhong,
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.black),
                              fillColor: Colors.white,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ), // Khoảng trống cuối màn hình
                      ],
                    ),
                  ),
                ),
              );
            }
            return const Center(child: Text("Không có dữ liệu phòng"));
          },
        ),
        bottomNavigationBar: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              // Trong ElevatedButton
              onPressed: () {
                // 1. Validate cơ bản
                if (_roomNameController.text.isEmpty ||
                    _roomPriceController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Vui lòng nhập Tên phòng và Giá phòng"),
                    ),
                  );
                  return;
                }

                // 2. Tạo Payload
                final payload = _updateRoomPayload();
                print("Payload Update: $payload"); // In ra check thử

                // 3. Gọi Cubit Update
                // Lưu ý: Bạn cần chắc chắn Cubit nào phụ trách hàm updateRoom.
                // Nếu là DetailRoomCubit thì gọi:
                context.read<DetailRoomCubit>().updateRoom(payload);

                // Nếu Update thành công, BlocListener sẽ cần xử lý để pop màn hình hoặc báo thành công.
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Cập nhật phòng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widget để tạo các trường nhập liệu tiêu chuẩn (từ UI trước)
Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required String hint,
  bool isRequired = false,
  TextInputType keyboardType = TextInputType.text,
  List<TextInputFormatter>? inputFormatters,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
            children: [
              if (isRequired)
                const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.black),

            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(0),
            isDense: true,
            fillColor: Colors.white,

            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
          ),
        ),
        // Đường kẻ dưới (tùy chọn, vì ảnh có vẻ không có)
        // Divider(color: Colors.grey[300], height: 1, thickness: 1),
      ],
    ),
  );
}

// Widget cho các nút Tiện ích phòng
Widget _buildUtilityTag({
  required String text,
  required bool isSelected,
  required ValueChanged<bool> onSelected,
}) {
  return Padding(
    padding: const EdgeInsets.only(right: 10.0),
    child: ChoiceChip(
      label: Text(
        text,
        style: TextStyle(
          // Màu chữ sẽ thay đổi tùy thuộc vào trạng thái chọn
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),

      selected: isSelected, // Trạng thái chọn
      onSelected: onSelected, // Xử lý khi người dùng nhấp
      // LOẠI BỎ DẤU CHECK ĐI KÈM MẶC ĐỊNH
      showCheckmark: false,
      // MÀU SẮC KHI CHỌN/KHÔNG CHỌN
      selectedColor: Colors.green, // Màu nền khi được chọn (MÀU GREEN)
      // Màu xám đậm như trong ảnh gốc khi CHƯA được chọn
      backgroundColor: Colors.grey,

      // Cấu hình hình dáng
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
    ),
  );
}

// Custom Chip cho Tiện ích
Widget _buildAmenityChip({
  required String label,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.green : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}
