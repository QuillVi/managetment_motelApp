import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:motelapp/data/models/service_model.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/home/service_home/service_cubit.dart';
import 'package:motelapp/logic/cubits/home/service_home/service_state.dart';
import 'package:motelapp/presentation/screens/home/functions/function_eletricwater_home/detail_electricwater/detail_eclectricwater.dart';
import 'package:motelapp/router/app_router.dart';

class ElectricwaterHome extends StatefulWidget {
  const ElectricwaterHome({super.key});

  @override
  State<ElectricwaterHome> createState() => _ElectricwaterHomeState();
}

class _ElectricwaterHomeState extends State<ElectricwaterHome> {
  @override
  void initState() {
    super.initState();

    // //load cubit list room select problem
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ClosureServiceCubit>()
          .loadClosureServices(); // Tên hàm đã sửa thành loadServices
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          shadowColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Column(
            children: [
              const Text(
                'Chốt dịch vụ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MM-yyyy').format(DateTime.now()),
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_today, color: Colors.orange),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.filter_alt_outlined, color: Colors.orange),
              onPressed: () {},
            ),
          ],
          bottom: TabBar(
            labelColor: Colors.green,
            unselectedLabelColor: Colors.black45,
            indicatorColor: Colors.green,
            indicatorWeight: 2,
            dividerHeight: 0,
            tabs: const [Tab(text: 'Chưa chốt'), Tab(text: 'Đã chốt')],
          ),
        ),

        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Tìm kiếm theo tên',
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Chưa chốt
                  _buildUnclosedListTab(context),
                  // Tab 2: Đã chốt
                  _buildClosedListTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnclosedListTab(BuildContext context) {
    return BlocBuilder<ClosureServiceCubit, ServiceState>(
      builder: (context, state) {
        if (state.status == ServiceStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final safeList = state.dataClosureService ?? [];
        final unclosedList =
            safeList
                .where((item) => item.trangThaiChotDichVu == 'ChuaChot')
                .toList();

        if (unclosedList.isEmpty) {
          return const Center(
            child: Text('Không có hợp đồng nào chưa chốt dịch vụ.'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: unclosedList.length,
          itemBuilder: (context, index) {
            final item = unclosedList[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (index == 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Tổng (${unclosedList.length})', // Hiển thị số lượng đúng
                      style: const TextStyle(
                        color: Colors.green, // Màu đỏ cho cảnh báo chưa chốt
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                // Widget hiển thị item của bạn
                _buildUnclosedServiceItem(context, item),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildClosedListTab(BuildContext context) {
    return BlocBuilder<ClosureServiceCubit, ServiceState>(
      builder: (context, state) {
        // Tương tự tab 1
        if (state.status == ServiceStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final safeList = state.dataClosureService ?? [];

        // --- Lấy các item có trạng thái là 'DaChot' ---
        final closedList =
            safeList
                .where((item) => item.trangThaiChotDichVu == 'DaChot')
                .toList();

        if (closedList.isEmpty) {
          return const Center(child: Text('Chưa có lịch sử chốt dịch vụ nào.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: closedList.length,
          itemBuilder: (context, index) {
            final item = closedList[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (index == 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Tổng (${closedList.length})',
                      style: const TextStyle(
                        color: Colors.green, // Màu xanh cho đã hoàn thành
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                // Widget hiển thị item của bạn
                _buildClosedServiceItem(context, item),
              ],
            );
          },
        );
      },
    );
  }

  //  _buildServiceItem
  Widget _buildUnclosedServiceItem(
    BuildContext context,
    ServiceClosureModel item,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            // Bạn có thể truyền item.id_hopdong vào đây nếu cần
            getIt<AppRouter>().push(DetailEclectricwater());
          },
          child: Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.home, size: 20, color: Colors.grey),
                      const SizedBox(width: 6),
                      // Hiển thị Tên phòng và Tên Tòa Nhà
                      Expanded(
                        child: Text(
                          '${item.tenPhong ?? 'N/A'} - ${item.tenToanha ?? 'N/A'}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(),
                      Column(
                        children: [
                          // Hiển thị Trạng thái cọc (Blue)
                          _buildStatusTag(
                            item.trangThaiCocPhong ?? 'N/A',
                            Colors.blue,
                          ),
                          const SizedBox(height: 4),
                          // Hiển thị Trạng thái thuê (Red)
                          _buildStatusTag(
                            item.trangThaiPhong ?? 'N/A',
                            Colors.red,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 20,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      // Hiển thị Tên tòa nhà và Địa chỉ
                      Expanded(
                        child: Text(
                          '${item.tenToanha ?? 'N/A'}, ${item.diaChiToanha ?? 'N/A'}',
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClosedServiceItem(
    BuildContext context,
    ServiceClosureModel item,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            // Bạn có thể truyền item.id_hopdong vào đây nếu cần
            getIt<AppRouter>().push(DetailEclectricwater());
          },
          child: Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.home, size: 20, color: Colors.grey),
                      const SizedBox(width: 6),
                      // Hiển thị Tên phòng và Tên người thuê
                      Expanded(
                        child: Text(
                          '${item.tenPhong ?? 'N/A'} - ${item.tenToanha ?? 'N/A'}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(),
                      Column(
                        children: [
                          // Hiển thị Trạng thái cọc (Blue)
                          _buildStatusTag(
                            item.trangThaiCocPhong ?? 'N/A',
                            Colors.blue,
                          ),
                          const SizedBox(height: 4),
                          // Hiển thị Trạng thái thuê (Red)
                          _buildStatusTag(
                            item.trangThaiPhong ?? 'N/A',
                            Colors.red,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 20,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      // Hiển thị Tên tòa nhà và Địa chỉ
                      Expanded(
                        child: Text(
                          '${item.tenToanha ?? 'N/A'}, ${item.diaChiToanha ?? 'N/A'}',
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 8),
      ),
    );
  }
}
