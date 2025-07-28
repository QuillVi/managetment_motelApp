import 'package:flutter/material.dart';

class AddImageService extends StatelessWidget {
  final List<IconData> icons = [
    Icons.lightbulb_outline,
    Icons.flash_on,
    Icons.water_drop,
    Icons.elevator,
    Icons.local_parking,
    Icons.ac_unit,
    Icons.directions_bike,
    Icons.cabin,
    Icons.directions_car,
    Icons.cleaning_services,
    Icons.electric_bolt,
    Icons.toys,
    Icons.kitchen,
    Icons.local_laundry_service,
    Icons.security,
    Icons.motorcycle,
    Icons.local_parking_outlined,
    Icons.shield,
    Icons.bed,
    Icons.iron,
    Icons.tv,
    Icons.wifi,
    Icons.credit_card,
    Icons.shower,
    Icons.water,
    Icons.wash,
    Icons.person,
    Icons.clean_hands,
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
                  return GestureDetector(
                    onTap: () {
                      // Trả về icon được chọn
                      print('Chọn icon: $index');
                      Navigator.pop(context, icons[index]);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icons[index], size: 28),
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
