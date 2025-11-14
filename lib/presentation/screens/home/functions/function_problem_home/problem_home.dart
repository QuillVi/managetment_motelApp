import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:motelapp/data/models/problem_model.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/home/problem_home/list_problem_cubit.dart';
import 'package:motelapp/logic/cubits/home/problem_home/list_problem_state.dart';
import 'package:motelapp/presentation/screens/buttonNavicationBar/buttonNavicationBar.dart';
import 'package:motelapp/presentation/screens/home/functions/function_problem_home/create_problem/create_problem.dart';
import 'package:motelapp/presentation/screens/home/functions/function_problem_home/detail_problem/detail_problem.dart';

import 'package:motelapp/router/app_router.dart';

class ProblemHome extends StatefulWidget {
  const ProblemHome({super.key});

  @override
  State<ProblemHome> createState() => _ProblemHomeState();
}

class _ProblemHomeState extends State<ProblemHome>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final tabs = const [Tab(text: "Đang yêu cầu"), Tab(text: "Hoàn thành")];

  @override
  void initState() {
    _tabController = TabController(length: tabs.length, vsync: this);
    super.initState();

    //load cubit list problem
    context.read<ListProblemRequestingCubit>().loadListProblemRequesting();
    context.read<ListProblemDonedCubit>().loadListProblemDoned();
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
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () {
                getIt<AppRouter>().push(Buttonnavicationbar());
              },
            ),
            title: const Text(
              'Sự cố',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.green,
              unselectedLabelColor: Colors.black45,
              indicatorColor: Colors.green,
              indicatorWeight: 2,
              dividerHeight: 0,
              tabs: tabs,
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              /// Tab: Đang yêu cầu
              BlocBuilder<ListProblemRequestingCubit, ListProblemState>(
                builder: (context, state) {
                  if (state.status == ListProblemStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state.status == ListProblemStatus.error) {
                    print('Lỗi: ${state.errorMessage}');
                    return Center(child: Text('Lỗi: ${state.errorMessage}'));
                  } else if (state.status == ListProblemStatus.loaded &&
                      state.problemsRequesting != null &&
                      state.problemsRequesting!.isNotEmpty) {
                    final problemsRequesting = state.problemsRequesting!;
                    return ListView.builder(
                      itemCount: problemsRequesting.length,
                      itemBuilder: (context, index) {
                        return _buildIssueCardProblemsRequesting(
                          problemsRequesting[index],
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Text('Không có sự cố nào đang yêu cầu'),
                    );
                  }
                },
              ),

              /// Tab: Hoàn thành
              BlocBuilder<ListProblemDonedCubit, ListProblemState>(
                builder: (context, state) {
                  if (state.status == ListProblemStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state.status == ListProblemStatus.error) {
                    print('Lỗi: ${state.errorMessage}');
                    return Center(child: Text('Lỗi: ${state.errorMessage}'));
                  } else if (state.status == ListProblemStatus.loaded &&
                      state.problemsDoned != null &&
                      state.problemsDoned!.isNotEmpty) {
                    final problemsDoned = state.problemsDoned!;
                    return ListView.builder(
                      itemCount: problemsDoned.length,
                      itemBuilder: (context, index) {
                        return _buildIssueCardproblemsDoned(
                          problemsDoned[index],
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Text('Không có sự cố nào đang yêu cầu'),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 84,
          right: 24,
          child: GestureDetector(
            onTap: () {
              getIt<AppRouter>().push(CreateProblem());
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

  Widget _buildIssueCardProblemsRequesting(
    ProblemModelRequesting problemsRequesting,
  ) {
    return GestureDetector(
      onTap: () {
        getIt<AppRouter>().push(
          DetailProblem(problemId: problemsRequesting.id_suco),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Tiêu đề và độ ưu tiên
              Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      problemsRequesting.ten_suco,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: getMucDoColor(
                        problemsRequesting.muc_do,
                      ).withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      problemsRequesting.muc_do ?? 'Không xác định',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              /// Phòng
              Row(
                children: [
                  Icon(Icons.home_outlined, size: 18, color: Colors.grey),
                  SizedBox(width: 6),
                  Text(
                    '${problemsRequesting.ten_phong} - ${problemsRequesting.ten_toanha}',
                  ),
                ],
              ),
              const SizedBox(height: 6),

              /// Địa chỉ
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 6),
                  Text(problemsRequesting.dia_chi ?? 'Chưa có địa chỉ'),
                ],
              ),
              const SizedBox(height: 6),

              /// Người báo
              Row(
                children: [
                  Icon(Icons.person, size: 18, color: Colors.grey),
                  SizedBox(width: 6),
                  Text(
                    problemsRequesting.ten_nguoithue ?? 'Chưa có người thuê',
                  ),
                ],
              ),
              const SizedBox(height: 10),

              /// Ngày
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  problemsRequesting.createdAt != null
                      ? DateFormat(
                        'dd/MM/yyyy',
                      ).format(problemsRequesting.createdAt!)
                      : '',
                  style: TextStyle(
                    color: Colors.green[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIssueCardproblemsDoned(ProblemModelDoned problemsDoned) {
    return GestureDetector(
      onTap: () {
        getIt<AppRouter>().push(
          DetailProblem(problemId: problemsDoned.id_suco),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Tiêu đề và độ ưu tiên
              Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      problemsDoned.ten_suco,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: getMucDoColor(
                        problemsDoned.muc_do,
                      ).withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      problemsDoned.muc_do ?? 'Không xác định',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              /// Phòng
              Row(
                children: [
                  Icon(Icons.home_outlined, size: 18, color: Colors.grey),
                  SizedBox(width: 6),
                  Text(
                    '${problemsDoned.ten_phong} - ${problemsDoned.ten_toanha}',
                  ),
                ],
              ),
              const SizedBox(height: 6),

              /// Địa chỉ
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 6),
                  Text(problemsDoned.dia_chi ?? 'Chưa có địa chỉ'),
                ],
              ),
              const SizedBox(height: 6),

              /// Người báo
              Row(
                children: [
                  Icon(Icons.person, size: 18, color: Colors.grey),
                  SizedBox(width: 6),
                  Text(problemsDoned.ten_nguoithue ?? 'Chưa có người thuê'),
                ],
              ),
              const SizedBox(height: 10),

              /// Ngày
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  problemsDoned.updatedAt != null
                      ? DateFormat(
                        'dd/MM/yyyy',
                      ).format(problemsDoned.updatedAt!)
                      : '',
                  style: TextStyle(
                    color: Colors.green[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
