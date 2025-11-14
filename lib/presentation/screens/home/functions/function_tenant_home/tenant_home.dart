import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/models/lessee_model.dart';

import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/home/tanent_home/lessee_cubit.dart';
import 'package:motelapp/logic/cubits/home/tanent_home/lessee_state.dart';
import 'package:motelapp/presentation/screens/building/list_room_in_building/detail_room_in_building/detail_tanent_in_room/detail_tanent_in_room.dart';

import 'package:motelapp/router/app_router.dart';

class TenantHome extends StatefulWidget {
  const TenantHome({super.key});

  @override
  State<TenantHome> createState() => _TenantHomeState();
}

class _TenantHomeState extends State<TenantHome>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> myTabs = const [
    Tab(text: 'Đã có phòng'),
    Tab(text: 'Chưa có phòng'),
    Tab(text: 'Đã thanh lý'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: myTabs.length, vsync: this);

    //load cubit list tanent
    context.read<LesseeCubit>().loadTanents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            //icon ios arrow back
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: const Text(
              'Người thuê',
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
              tabs: myTabs,
            ),
            actions: [
              IconButton(
                onPressed: () {
                  // Help icon action
                },
                icon: const Icon(Icons.help_outline, color: Colors.orange),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Tìm kiếm theo tên, sđt, phòng, toà nhà...',
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
                  controller: _tabController,
                  children: [
                    //tab1 đã có phòng
                    BlocBuilder<LesseeCubit, LesseeState>(
                      builder: (context, state) {
                        if (state.status == LesseeStatus.loading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state.status == LesseeStatus.error) {
                          print('Lỗi: ${state.errorMessage}');
                          return Center(
                            child: Text('Lỗi: ${state.errorMessage}'),
                          );
                        } else if (state.status == LesseeStatus.loaded &&
                            state.listLessee != null &&
                            state.listLessee!.isNotEmpty) {
                          final lessees = state.listLessee!;
                          return ListView.builder(
                            itemCount: lessees.length,
                            itemBuilder: (context, index) {
                              return _buildTenantCard(lessees[index]);
                            },
                          );
                        } else {
                          return const Center(
                            child: Text('Không có người thuê'),
                          );
                        }
                      },
                    ),
                    //tab2 chưa có phòng
                    const Center(child: Text('Chưa có phòng')),
                    //tab3 đã thanh lý
                    const Center(child: Text('Đã Thanh lý')),
                  ],
                ),
              ),
            ],
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
}

Widget _buildTenantCard(LesseeModel lessee) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 14, offset: Offset(0, 6)),
      ],
    ),
    child: ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.grey[300],
        child: Icon(Icons.person, color: Colors.white),
      ),
      title: Text(
        lessee.tenNguoiThue,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(
        '${lessee.tenPhong} - ${lessee.tenToaNha}',
        style: TextStyle(fontSize: 12),
      ),
      trailing: Text(
        lessee.soDienThoai.toString(),
        style: TextStyle(color: Colors.green),
      ),
      onTap: () {
        print('lessee ID: ${lessee.idNguoiThue}');
        getIt<AppRouter>().push(
          DetailTanentInRoom(idNguoiThue: lessee.idNguoiThue),
        );
      },
    ),
  );
}
