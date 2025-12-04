import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/logic/cubits/home/contract_home/contract_cubit.dart';
import 'package:motelapp/logic/cubits/home/contract_home/contract_state.dart';

class SelectTanentContract extends StatefulWidget {
  const SelectTanentContract({super.key});

  @override
  State<SelectTanentContract> createState() => _SelectTanentContractState();
}

class _SelectTanentContractState extends State<SelectTanentContract> {
  @override
  void initState() {
    super.initState();
    // Gọi API load dữ liệu ngay khi màn hình khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListContractCubit>().LoadListUserContractSelected();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chọn đại diện cho thuê',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: BlocBuilder<ListContractCubit, ListContractState>(
        builder: (context, state) {
          // 1. Trạng thái đang tải
          if (state.status == ListContractIsActiveStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Trạng thái lỗi
          if (state.status == ListContractIsActiveStatus.error) {
            return Center(
              child: Text(
                state.errorMessage ?? 'Đã xảy ra lỗi',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // 3. Trạng thái đã tải xong (Loaded)
          if (state.status == ListContractIsActiveStatus.loaded) {
            final listData = state.listUserContractSelected ?? [];

            if (listData.isEmpty) {
              return const Center(
                child: Text("Chưa có danh sách người đại diện"),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: listData.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = listData[index];

                // Ghép chuỗi thông tin CCCD
                final cccdInfo =
                    '${item.cccd ?? ''} cấp ngày ${item.ngayCap ?? ''} - ${item.noiCap ?? ''}';

                return _buildRepresentativeCard(
                  name:
                      item.ten ??
                      'Chưa cập nhật tên', // Lưu ý: JSON mẫu bạn gửi thiếu trường "ten", nên có thể sẽ hiện fallback này
                  phone: item.sdt ?? '',
                  dob: item.ngaySinh ?? '',
                  address: item.diaChi ?? '',
                  idCard: cccdInfo,
                  isDefault:
                      index ==
                      0, // Ví dụ: item đầu tiên là mặc định (hoặc logic khác tùy bạn)
                  onTap: () {
                    //trả dữ liệu về màn hình trước
                    final String displayName = item.ten ?? 'Chưa cập nhật tên';

                    // Log dữ liệu khi chọn
                    print(
                      'Chọn người đại diện: ${item.idNguoiThue} - $displayName - ${item.sdt}',
                    );

                    // đóng gói dữ liệu để trả về
                    final Map<String, dynamic> result = {
                      'idNguoiThue': item.idNguoiThue,
                      'ten': displayName,
                      'sdt': item.sdt,
                    };

                    Navigator.pop(context, result);
                  },
                );
              },
            );
          }

          // Trạng thái khởi tạo (Initial)
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Xử lý khi bấm nút thêm mới
        },
        backgroundColor: const Color(0xFF66BB6A),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  // --- WIDGET CON: CARD THÔNG TIN ---
  Widget _buildRepresentativeCard({
    required String name,
    required String phone,
    required String dob,
    required String address,
    required String idCard,
    bool isDefault = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            // Dòng 1: Icon người + Tên + [Mặc định] + 3 chấm
            Row(
              children: [
                const Icon(Icons.person, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_vert, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.phone_in_talk, phone),
            _buildInfoRow(Icons.calendar_today, dob),
            _buildInfoRow(Icons.location_on_outlined, address),
            _buildInfoRow(Icons.badge_outlined, idCard),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
