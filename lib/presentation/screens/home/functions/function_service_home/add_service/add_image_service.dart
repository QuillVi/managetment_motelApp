import 'package:flutter/material.dart';

class AddImageService extends StatefulWidget {
  const AddImageService({super.key});

  @override
  State<AddImageService> createState() => _AddImageServiceState();
}

class _AddImageServiceState extends State<AddImageService> {
  // Đường dẫn gốc tới thư mục icon
  final String assetPath = 'lib/assets/icons/';

  // Danh sách map giữa tên file thực tế và tên hiển thị cho người dùng tìm kiếm
  final List<Map<String, String>> allIcons = [
    {"file": "default.png", "name": "Mặc định"},
    {"file": "icon_an.png", "name": "An ninh"},
    {"file": "icon_bt.png", "name": "Bảo trì"},
    {"file": "icon_dien.png", "name": "Tiền điện"},
    {"file": "icon_nuoc.png", "name": "Tiền nước"},
    {"file": "icon_ql.png", "name": "Phí quản lý"},
    {"file": "icon_tm.png", "name": "Thang máy"}, // Dự đoán
    {"file": "icon_tv.png", "name": "Truyền hình TV"},
    {"file": "icon_vs.png", "name": "Vệ sinh"},
    {"file": "icon_wifi.png", "name": "Mạng Wifi"},
    {"file": "icon_xe.png", "name": "Giữ xe"},
  ];

  late List<Map<String, String>> displayedIcons;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    displayedIcons = allIcons;
  }

  // Hàm tìm kiếm
  void _runFilter(String enteredKeyword) {
    List<Map<String, String>> results = [];
    if (enteredKeyword.isEmpty) {
      results = allIcons;
    } else {
      results =
          allIcons
              .where(
                (item) => item["name"]!.toLowerCase().contains(
                  enteredKeyword.toLowerCase(),
                ),
              )
              .toList();
    }
    setState(() {
      displayedIcons = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Chọn biểu tượng',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: _runFilter,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Tìm kiếm (ví dụ: điện, nước...)',
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Grid hiển thị ảnh
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                itemCount: displayedIcons.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // 4 cột cho thoáng
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1, // Hình vuông
                ),
                itemBuilder: (context, index) {
                  final fileName = displayedIcons[index]["file"]!;
                  final displayName = displayedIcons[index]["name"]!;

                  return GestureDetector(
                    onTap: () {
                      // Trả về tên file khi user chọn
                      Navigator.pop(context, {
                        "file": fileName,
                        "name": displayName,
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade100,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // HIỂN THỊ ẢNH TỪ ASSET
                          Expanded(
                            child: Image.asset(
                              '$assetPath$fileName', // Ghép chuỗi: lib/assets/icons/icon_dien.png
                              fit: BoxFit.contain,
                              errorBuilder:
                                  (_, __, ___) => const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            displayName,
                            style: const TextStyle(fontSize: 10),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
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
