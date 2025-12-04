import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/models/building_model.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/building/list_building_cubit.dart';
import 'package:motelapp/logic/cubits/building/list_building_state.dart';
import 'package:motelapp/logic/cubits/home/service_home/service_cubit.dart';
import 'package:motelapp/logic/cubits/home/service_home/service_state.dart';
import 'package:motelapp/presentation/screens/home/functions/function_service_home/add_service/add_image_service.dart';
import 'package:motelapp/presentation/screens/home/functions/function_service_home/service_home.dart';
import 'package:motelapp/router/app_router.dart';

class UpdateServiceHome extends StatefulWidget {
  final int idDichVu;
  const UpdateServiceHome({super.key, required this.idDichVu});

  @override
  State<UpdateServiceHome> createState() => _UpdateServiceHomeState();
}

class _UpdateServiceHomeState extends State<UpdateServiceHome> {
  // Controller để quản lý text để nhận dữ liệu từ input
  final _nameController = TextEditingController();
  final _unitController = TextEditingController();
  final _feeController = TextEditingController();
  final _notesController = TextEditingController();
  final _cachTinhPhiController = TextEditingController();

  // Danh sách tên toà nhà đã chọn
  Set<int> _selectedBuildingIDs = {};

  @override
  void initState() {
    super.initState();

    //gọi API lấy chi tiết dịch vụ
    context.read<ServiceCubit>().loadDetailService(widget.idDichVu);

    // Lấy danh sách tất cả toà nhà
    context.read<ListBuildingCubit>().loadBuildings();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    _feeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. AppBar
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Cập nhật dịch vụ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.black,
      ),
      // 2. Body với SingleChildScrollView
      body: BlocListener<ServiceCubit, ServiceState>(
        listener: (context, state) {
          // -----------------------------------------------------------
          // CASE 1: TẢI DỮ LIỆU THÀNH CÔNG (Vừa vào màn hình)
          // -> Chỉ thực hiện điền dữ liệu vào ô input
          // -----------------------------------------------------------
          if (state.status == ServiceStatus.success &&
              state.detailService != null) {
            final detail = state.detailService!;

            // Điền dữ liệu vào controllers
            _nameController.text = detail.ten_dichvu;
            _unitController.text = detail.don_vi_do;
            _feeController.text = detail.phi_dichvu.toStringAsFixed(0);
            _notesController.text = detail.ghi_chu;
            _cachTinhPhiController.text = detail.cach_tinh_phi;

            // Xử lý danh sách toà nhà đã chọn từ API chi tiết
            List<int> initialSelectedList =
                detail.danh_sach_toa_nha
                    .map((building) => building.id_toanha)
                    .toList();

            // Chỉ set state nếu danh sách đang trống (tránh reset khi user đang sửa)
            if (_selectedBuildingIDs.isEmpty) {
              setState(() {
                _selectedBuildingIDs = initialSelectedList.toSet();
              });
            }
          }
          // -----------------------------------------------------------
          // CASE 2: CẬP NHẬT THÀNH CÔNG (Sau khi bấm nút Cập nhật)
          // -> Chỉ thực hiện hiện Popup
          // -----------------------------------------------------------
          else if (state.status == ServiceStatus.updateSuccess) {
            if (ModalRoute.of(context)?.isCurrent == true) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    title: const Column(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 50),
                        SizedBox(height: 10),
                        Text(
                          "Thành công",
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                    content: const Text(
                      "Cập nhật dịch vụ thành công!",
                      textAlign: TextAlign.center,
                    ),
                    actions: [
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(); // Đóng Popup
                            getIt<AppRouter>().push(ServiceHome());
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              "OK",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }
          }
          // -----------------------------------------------------------
          // CASE 3: CÓ LỖI XẢY RA
          // -----------------------------------------------------------
          else if (state.status == ServiceStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi: ${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        // 5. Dùng BlocBuilder để HIỂN THỊ UI (loading, error, success)
        child: BlocBuilder<ServiceCubit, ServiceState>(
          builder: (context, state) {
            // --- A. Trạng thái Loading ---
            if (state.status == ServiceStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên dịch vụ
                  _buildLabel('Tên dịch vụ', isRequired: true),
                  _buildTextField(controller: _nameController),
                  const SizedBox(height: 24),

                  // Thu phí dựa trên
                  _buildLabel('Thu phí dựa trên', isRequired: true),
                  _buildDropdownField(_cachTinhPhiController.text),
                  const SizedBox(height: 24),

                  // Đơn vị đo
                  _buildLabel('Đơn vị đo', isRequired: true),
                  _buildTextField(controller: _unitController),
                  const SizedBox(height: 24),

                  // Phí dịch vụ
                  _buildLabel('Phí dịch vụ'),
                  _buildTextField(
                    controller: _feeController,
                    keyboardType: TextInputType.number,
                    suffix: _buildSuffixButton(_unitController.text),
                  ),
                  const SizedBox(height: 24),

                  // Ảnh đại diện
                  _buildLabel('Ảnh đại diện'),
                  _buildIconPickerField(state.detailService?.icon),
                  const SizedBox(height: 24),

                  // Ghi chú
                  _buildLabel('Ghi chú'),
                  _buildTextField(
                    controller: _notesController,
                    maxLines: 4,
                    isMultiline: true,
                  ),
                  const SizedBox(height: 32),

                  // Thêm dịch vụ cho toà nhà
                  const Text(
                    'Thêm dịch vụ này cho toà nhà',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  BlocBuilder<ListBuildingCubit, ListBuildingState>(
                    builder: (context, buildingState) {
                      if (buildingState.status == ListBuildingStatus.loading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (buildingState.status ==
                          ListBuildingStatus.error) {
                        return Text(
                          'Lỗi: ${buildingState.error}',
                          style: const TextStyle(color: Colors.red),
                        );
                      }

                      final List<BuildingModel> allBuildings =
                          buildingState.data ?? [];

                      if (allBuildings.isEmpty) {
                        return const Text('Không có toà nhà nào để hiển thị.');
                      }

                      // 1. Lấy danh sách ID của TẤT CẢ toà nhà
                      // (Giả sử BuildingModel có 'idtoanha' kiểu int)
                      final allBuildingIDs =
                          allBuildings.map((b) => b.id_toanha).toSet();

                      // 2. TÍNH TOÁN LẠI TRẠNG THÁI "CHỌN TẤT CẢ"
                      // So sánh độ dài của 2 Set (Set đã chọn vs Set tất cả)
                      final bool isSelectAllChecked =
                          allBuildingIDs.isNotEmpty &&
                          _selectedBuildingIDs.length == allBuildingIDs.length;

                      // 4. Hiển thị Column
                      return Column(
                        children: [
                          // --- THÊM CHECKBOX "CHỌN TẤT CẢ" ---
                          _buildCheckbox(
                            title: 'Chọn tất cả',
                            value: isSelectAllChecked,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  // CHỌN TẤT CẢ:
                                  _selectedBuildingIDs = Set.from(
                                    allBuildingIDs,
                                  );
                                  print(
                                    "✅ [Chọn tất cả] -> Đã thêm toàn bộ ID",
                                  );
                                } else {
                                  // BỎ CHỌN TẤT CẢ:
                                  _selectedBuildingIDs.clear();
                                  print("❌ [Bỏ tất cả] -> Đã xóa toàn bộ ID");
                                }

                                // In ra danh sách kết quả
                                print(
                                  "📋 Danh sách ID hiện tại: ${_selectedBuildingIDs.toList()}",
                                );
                              });
                            },
                          ),

                          // --- HIỂN THỊ DANH SÁCH TOÀ NHÀ ---
                          ...allBuildings.map((building) {
                            // Dùng cả ID và Tên
                            final buildingId = building.id_toanha;
                            final buildingName = building.tentoanha;

                            // Kiểm tra bằng ID (int)
                            final isSelected = _selectedBuildingIDs.contains(
                              buildingId,
                            );

                            return _buildCheckbox(
                              title: buildingName,
                              value: isSelected,
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    // Thêm ID (int)
                                    _selectedBuildingIDs.add(buildingId);
                                    print(
                                      "➕ Đã thêm: $buildingName (ID: $buildingId)",
                                    );
                                  } else {
                                    // Xoá ID (int)
                                    _selectedBuildingIDs.remove(buildingId);
                                    print(
                                      "➖ Đã bỏ: $buildingName (ID: $buildingId)",
                                    );
                                  }

                                  // In ra danh sách kết quả để kiểm tra
                                  print(
                                    "📋 Danh sách ID hiện tại: ${_selectedBuildingIDs.toList()}",
                                  );
                                });
                              },
                            );
                          }),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // Nút Cập nhật
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // --- 1. Lấy dữ liệu thô từ Input ---
                        int idDichVu = widget.idDichVu;
                        String phiDichVuString = _feeController.text.trim();
                        String ghiChu = _notesController.text.trim();

                        // --- 2. Xử lý dữ liệu (Validate & Parse) ---

                        // Chuyển giá tiền từ String sang số (Double).
                        // Nếu user nhập sai hoặc để trống thì mặc định là 0.
                        double phiDichVu =
                            double.tryParse(phiDichVuString) ?? 0;

                        // Lấy danh sách tòa nhà từ Set chuyển sang List
                        List<int> danhSachToaNha =
                            _selectedBuildingIDs.toList();

                        // --- 3. Tổng hợp vào 1 biến Map (Payload) ---
                        // Đây là cấu trúc chuẩn để gửi lên API
                        Map<String, dynamic> updateData = {
                          "id_dichvu": idDichVu,
                          "phi_dichvu": phiDichVu,
                          "ghi_chu": ghiChu,
                          "danhSachToaNha": danhSachToaNha,
                        };

                        // --- 4. Print ra Log ---
                        print(
                          "--------------------------------------------------",
                        );
                        print("🚀 CLICK CẬP NHẬT - DỮ LIỆU CHUẨN BỊ GỬI:");
                        // jsonEncode giúp in ra dạng chuỗi JSON đẹp, dễ copy vào Postman để test nếu cần
                        print(jsonEncode(updateData));
                        print(
                          "--------------------------------------------------",
                        );

                        // --- 5. Gọi API ---
                        context.read<ServiceCubit>().updateService(
                          data: updateData,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cập nhật',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16), // Padding cho an toàn
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- Helper Widgets để build UI ---

  // Widget cho các nhãn (label)
  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
          children: [
            if (isRequired)
              const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  // Widget cho các ô nhập liệu (TextFormField)
  Widget _buildTextField({
    TextEditingController? controller,
    int maxLines = 1,
    TextInputType? keyboardType,
    Widget? suffix,
    bool isMultiline = false,
  }) {
    // Style cho các trường 1 dòng (có gạch chân)
    InputBorder singleLineBorder = const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.black12),
    );
    InputBorder singleLineFocusedBorder = const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.green, width: 2),
    );

    // Style cho trường Ghi chú (multiline, có nền)
    InputBorder multiLineBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    );

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: isMultiline, // Chỉ fill nền cho Ghi chú
        fillColor: Colors.grey.shade100, // Màu nền của Ghi chú
        contentPadding:
            isMultiline
                ? const EdgeInsets.all(12)
                : const EdgeInsets.symmetric(vertical: 10),
        border: isMultiline ? multiLineBorder : singleLineBorder,
        enabledBorder: isMultiline ? multiLineBorder : singleLineBorder,
        focusedBorder: isMultiline ? multiLineBorder : singleLineFocusedBorder,
        suffixIcon: suffix,
      ),
    );
  }

  // Widget cho nút suffix "/kwh"
  Widget _buildSuffixButton(String unit) {
    return Padding(
      // Dùng padding để căn chỉnh nút cho đẹp
      padding: const EdgeInsets.only(top: 8.0, left: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(8),
        ),
        // Dùng UnconstrainedBox để kích thước container vừa với nội dung
        child: UnconstrainedBox(
          child: Text(
            unit.isNotEmpty ? '/$unit' : '',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ),
    );
  }

  // Widget giả lập Dropdown (vì chỉ là UI)
  Widget _buildDropdownField(String value) {
    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(value, style: const TextStyle(fontSize: 16))],
      ),
    );
  }

  // Widget cho trường chọn Icon
  Widget _buildIconPickerField(String? iconName) {
    return GestureDetector(
      onTap: () async {
        // // 1. Chuyển màn hình và chờ kết quả
        // final result = await getIt<AppRouter>().push(AddImageService());

        // // 2. Kiểm tra kết quả trả về
        // if (result != null && result is Map<String, String>) {
        //   // Lấy tên file, ví dụ: "icon_dien.png"
        //   String selectedFile = result['file']!;

        //   // TODO: Cập nhật state tại đây (setState hoặc Bloc)
        //   // Ví dụ: setState(() => _selectedIcon = selectedFile);
        //   print("Đã chọn file: $selectedFile");
        // }
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end, // Căn phải
          children: [
            // Logic hiển thị icon (giống ServiceCard)
            if (iconName != null && iconName.isNotEmpty)
              Image.asset(
                'lib/assets/icons/$iconName', // <-- Dùng iconName động
                height: 24, // Kích thước nhỏ hơn cho field
                width: 24,
                errorBuilder:
                    (_, __, ___) => const Icon(Icons.broken_image, size: 24),
              )
            else
              const Icon(Icons.help_outline, size: 24), // Icon mặc định

            const SizedBox(width: 16),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.black54,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // Widget cho Checkbox
  Widget _buildCheckbox({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading, // Checkbox ở đầu
      contentPadding: EdgeInsets.zero, // Bỏ padding mặc định
      activeColor: Colors.green, // Màu khi được chọn
    );
  }
}
