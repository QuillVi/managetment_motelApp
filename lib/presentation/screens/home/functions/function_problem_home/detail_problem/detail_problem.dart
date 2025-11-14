import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/home/problem_home/detail_problem_cubit.dart';
import 'package:motelapp/logic/cubits/home/problem_home/detail_problem_state.dart';
import 'package:motelapp/presentation/screens/home/functions/function_problem_home/problem_home.dart';
import 'package:motelapp/router/app_router.dart';

class DetailProblem extends StatefulWidget {
  final int problemId;
  const DetailProblem({super.key, required this.problemId});

  @override
  State<DetailProblem> createState() => _DetailProblemState();
}

class _DetailProblemState extends State<DetailProblem> {
  @override
  void initState() {
    super.initState();

    // Load problem details using widget.problemId
    context.read<DetailProblemCubit>().loadDetailProblem(widget.problemId);
  }

  Color getMucDoColor(String? mucDo) {
    final normalized = mucDo?.trim().toLowerCase();
    switch (normalized) {
      case 'thấp':
        return Colors.green;
      case 'trung bình':
        return Colors.orange;
      case 'cao':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailProblemCubit, DetailProblemState>(
      builder: (context, state) {
        // Loading
        if (state.status == DetailProblemStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Error
        if (state.status == DetailProblemStatus.error) {
          print('Lỗi: ${state.errorMessage}');
          return Scaffold(
            body: Center(child: Text('Lỗi: ${state.errorMessage}')),
          );
        }

        // Loaded with data
        if (state.status == DetailProblemStatus.loaded &&
            state.detailProblem != null &&
            state.detailProblem!.id_suco == widget.problemId) {
          final detailProblem = state.detailProblem!;

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () {
                  getIt<AppRouter>().push(ProblemHome());
                },
              ),
              title: const Text(
                'Sự cố',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
            ),
            body: ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                // Thông tin sự cố
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 14,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Tiêu đề + mức độ
                            Row(
                              children: [
                                const Icon(
                                  Icons.warning_amber,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    detailProblem.ten_suco,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: getMucDoColor(
                                      detailProblem.muc_do,
                                    ).withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    detailProblem.muc_do ?? 'Thấp',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              Icons.home,
                              '${detailProblem.ten_phong}, ${detailProblem.ten_toanha}',
                            ),
                            const SizedBox(height: 6),
                            _buildInfoRow(
                              Icons.location_on_outlined,
                              detailProblem.dia_chi ?? 'Chưa có địa chỉ',
                            ),
                            const SizedBox(height: 6),
                            _buildInfoRow(Icons.person_outline, 'vi'),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Builder(
                                builder: (context) {
                                  String label = '';
                                  String dateText = '';

                                  if (detailProblem.Trang_thai ==
                                      'Hoàn thành') {
                                    // Hiển thị ngày hoàn thành
                                    label = 'Ngày hoàn thành: ';
                                    if (detailProblem.updatedAt != null) {
                                      final date = detailProblem.updatedAt!;
                                      dateText =
                                          '${date.day}/${date.month}/${date.year}';
                                    } else {
                                      dateText = 'Chưa có ngày hoàn thành';
                                    }
                                  } else if (detailProblem.Trang_thai ==
                                      'Đang yêu cầu') {
                                    // Hiển thị ngày tạo
                                    label = 'Ngày tạo: ';
                                    if (detailProblem.createdAt != null) {
                                      final date = detailProblem.createdAt!;
                                      dateText =
                                          '${date.day}/${date.month}/${date.year}';
                                    } else {
                                      dateText = 'Chưa có ngày tạo';
                                    }
                                  } else {
                                    // Trường hợp khác nếu có
                                    label = 'Ngày cập nhật: ';
                                    if (detailProblem.updatedAt != null) {
                                      final date = detailProblem.updatedAt!;
                                      dateText =
                                          '${date.day}/${date.month}/${date.year}';
                                    } else {
                                      dateText = 'Chưa có ngày cập nhật';
                                    }
                                  }

                                  return Text(
                                    '$label$dateText',
                                    style: TextStyle(
                                      color: Colors.green[600],
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Mô tả
                _buildCardSection(
                  'Mô tả sự cố',
                  content: detailProblem.mo_ta_su_co ?? '',
                ),
                SizedBox(height: 16),
                // Ảnh sự cố
                _buildCardNoteSection('', content: 'Ảnh sự cố (tối đa 5 ảnh)'),
                // Ghi chú
                _buildCardSection(
                  'Ghi chú',
                  child: const TextField(
                    maxLines: 5,
                    decoration: InputDecoration.collapsed(
                      hintText: 'Nhập tóm tắt sự cố',
                    ),
                  ),
                ),
              ],
            ),

            // Nút Đã khắc phục: chỉ hiện khi trạng thái đang yêu cầu
            bottomSheet:
                (detailProblem.Trang_thai == 'Đang yêu cầu')
                    ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // TODO: Gọi cubit để cập nhật trạng thái sang "Hoàn thành"
                          // Ví dụ:
                          // context.read<DetailProblemCubit>().markCompleted(detailProblem.id_suco);
                        },
                        child: const Text(
                          'Đã khắc phục',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    )
                    : null,
          );
        }
        return const Scaffold(
          body: Center(child: Text('Không tìm thấy chi tiết sự cố')),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }

  Widget _buildCardSection(String title, {String? content, Widget? child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          Container(
            height: 120,
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child:
                child ??
                Text(content ?? '', style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildCardNoteSection(String title, {String? content, Widget? child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          Container(
            height: 150,
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child:
                child ??
                Text(content ?? '', style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
