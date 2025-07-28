import 'package:flutter/material.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/presentation/screens/building/list_room_in_building/list_room_in_building.dart';
import 'package:motelapp/router/app_router.dart';

class BuildingScreen extends StatefulWidget {
  const BuildingScreen({super.key});

  @override
  State<BuildingScreen> createState() => _BuildingScreenState();
}

class _BuildingScreenState extends State<BuildingScreen> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text(
              'Toà nhà',
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
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Hồ Chí Minh (1)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildBuildingCard(),
              ),
            ],
          ),
        ),
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

  /// Thẻ hiển thị toà nhà
  Widget _buildBuildingCard() {
    return GestureDetector(
      onTap: () {
        getIt<AppRouter>().push(ListRoomInBuilding());
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
            const Text(
              'vi',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'hhhh, Quận 8, Hồ Chí Minh',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
