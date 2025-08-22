import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/models/building_model.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/building/list_building_cubit.dart';
import 'package:motelapp/logic/cubits/building/list_building_state.dart';
import 'package:motelapp/presentation/screens/building/list_room_in_building/list_room_in_building.dart';
import 'package:motelapp/router/app_router.dart';

class BuildingScreen extends StatefulWidget {
  const BuildingScreen({super.key});

  @override
  State<BuildingScreen> createState() => _BuildingScreenState();
}

class _BuildingScreenState extends State<BuildingScreen> {
  @override
  void initState() {
    super.initState();
    // Gọi API khi mở màn hình
    context.read<ListBuildingCubit>().loadBuildings();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text(
              'Tòa nhà',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.filter_alt_outlined,
                  color: Colors.orange,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.help_outline, color: Colors.orange),
                onPressed: () {},
              ),
            ],
          ),
          body: BlocBuilder<ListBuildingCubit, ListBuildingState>(
            builder: (context, state) {
              if (state.status == ListBuildingStatus.loaded &&
                  state.data != null) {
                final buildings = state.data!;
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 cột
                    crossAxisSpacing: 24, // khoảng cách ngang giữa các cột
                    mainAxisSpacing: 16, // khoảng cách dọc giữa các hàng
                    childAspectRatio: 1, // tỉ lệ khung (rộng / cao)
                  ),
                  itemCount: buildings.length,
                  itemBuilder: (context, index) {
                    final b = buildings[index];
                    return _buildBuildingCard(b);
                  },
                );
              }

              return SizedBox.shrink();
            },
          ),
        ),
        // Nút thêm mới
        Positioned(
          bottom: 60,
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

  /// Card hiển thị thông tin tòa nhà
  Widget _buildBuildingCard(BuildingModel building) {
    return GestureDetector(
      onTap: () {
        final buildingId = building.id_toanha;
        final buildingName = building.tentoanha;
        print('Selected building ID: $buildingId');
        print('Selected building Name: $buildingName');
        getIt<AppRouter>().push(
          ListRoomInBuilding(
            buildingId: buildingId,
            buildingName: buildingName,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Column(
          children: [
            const Icon(Icons.house, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              building.tentoanha,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              building.diachi_toanha,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
