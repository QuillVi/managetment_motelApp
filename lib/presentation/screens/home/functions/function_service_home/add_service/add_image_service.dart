import 'package:flutter/material.dart';

class AddImageService extends StatelessWidget {
  final List<Map<String, dynamic>> icons = [
    {"icon": Icons.lightbulb_outline, "name": "lightbulb_outline"},
    {"icon": Icons.flash_on, "name": "flash_on"},
    {"icon": Icons.water_drop, "name": "water_drop"},
    {"icon": Icons.elevator, "name": "elevator"},
    {"icon": Icons.local_parking, "name": "local_parking"},
    {"icon": Icons.ac_unit, "name": "ac_unit"},
    {"icon": Icons.directions_bike, "name": "directions_bike"},
    {"icon": Icons.cabin, "name": "cabin"},
    {"icon": Icons.directions_car, "name": "directions_car"},
    {"icon": Icons.cleaning_services, "name": "cleaning_services"},
    {"icon": Icons.electric_bolt, "name": "electric_bolt"},
    {"icon": Icons.toys, "name": "toys"},
    {"icon": Icons.kitchen, "name": "kitchen"},
    {"icon": Icons.local_laundry_service, "name": "local_laundry_service"},
    {"icon": Icons.security, "name": "security"},
    {"icon": Icons.motorcycle, "name": "motorcycle"},
    {"icon": Icons.local_parking_outlined, "name": "local_parking_outlined"},
    {"icon": Icons.shield, "name": "shield"},
    {"icon": Icons.bed, "name": "bed"},
    {"icon": Icons.iron, "name": "iron"},
    {"icon": Icons.tv, "name": "tv"},
    {"icon": Icons.wifi, "name": "wifi"},
    {"icon": Icons.credit_card, "name": "credit_card"},
    {"icon": Icons.shower, "name": "shower"},
    {"icon": Icons.water, "name": "water"},
    {"icon": Icons.wash, "name": "wash"},
    {"icon": Icons.person, "name": "person"},
    {"icon": Icons.clean_hands, "name": "clean_hands"},
  ];

  AddImageService({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Chọn biểu tượng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.all(16),
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

          // Grid icon
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                itemCount: icons.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final iconData = icons[index]["icon"] as IconData;
                  final iconName = icons[index]["name"] as String;

                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context, {
                        "icon": iconData,
                        "name": iconName,
                      });
                    },

                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(iconData, size: 28),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
