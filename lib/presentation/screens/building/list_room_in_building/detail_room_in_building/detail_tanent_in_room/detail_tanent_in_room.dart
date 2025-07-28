import 'package:flutter/material.dart';

class DetailTanentInRoom extends StatefulWidget {
  const DetailTanentInRoom({super.key});

  @override
  State<DetailTanentInRoom> createState() => _DetailTanentInRoomState();
}

class _DetailTanentInRoomState extends State<DetailTanentInRoom> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Thông tin người thuê",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit, color: Colors.orange),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar + tên
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "huy",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          CircleAvatar(
                            backgroundColor: Colors.purple,
                            child: Icon(Icons.sms, color: Colors.white),
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.lightBlue,
                            child: Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.white,
                            ),
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Icon(Icons.phone, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Thông tin chi tiết
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: const [
                      ThongTinRow(label: "Email", value: "agsisv@gmail.com"),
                      ThongTinRow(label: "Ngày sinh", value: "23-03-2025"),
                      ThongTinRow(label: "Số điện thoại", value: "404640464"),
                      ThongTinRow(label: "Phòng", value: "số 1 - vi"),
                      ThongTinRow(label: "CMND/CCCD", value: "49484694"),
                      ThongTinRow(label: "Ngày cấp", value: "21-03-2025"),
                      ThongTinRow(label: "Nơi cấp", value: "Shaps s"),
                      ThongTinRow(label: "Địa chỉ", value: "Sbshdjsb"),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Ảnh CMND/CCCD (hiện chưa có ảnh, dùng làm placeholder)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Ảnh CMND/CCCD",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 32),
            // tao 1 button để xóa người thuê
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Bordered button
                  ),
                ),
                child: const Text(
                  'Xóa người thuê',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThongTinRow extends StatelessWidget {
  final String label;
  final String value;

  const ThongTinRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
