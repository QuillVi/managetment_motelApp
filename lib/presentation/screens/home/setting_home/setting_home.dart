import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<Map<String, dynamic>> settings = [
    {'title': 'Tài khoản', 'onTap': () {}},
    {'title': 'Thay đổi mật khẩu', 'onTap': () {}},
    {'title': 'Sao lưu dữ liệu', 'onTap': () {}},
    {'title': 'Chính sách', 'onTap': () {}},
    {'title': 'Điều khoản sử dụng', 'onTap': () {}},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Cài đặt', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 40.0),
        child: Container(
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: settings.length + 1,
                  separatorBuilder:
                      (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Colors.grey[300],
                        ),
                      ),
                  itemBuilder: (context, index) {
                    if (index < settings.length) {
                      final item = settings[index];
                      return ListTile(
                        title: Text(
                          item['title'],
                          style: const TextStyle(fontSize: 16),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        tileColor: Colors.white,
                        onTap: item['onTap'],
                      );
                    } else {
                      // Phiên bản
                      return ListTile(
                        title: const Text('Phiên bản'),
                        trailing: const Text(
                          '1.3.9',
                          style: TextStyle(color: Colors.grey),
                        ),
                        tileColor: Colors.white,
                      );
                    }
                  },
                ),
              ),

              InkWell(
                onTap: () {
                  // TODO: Đăng xuất ở đây
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bạn đã đăng xuất')),
                  );
                },
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: const Center(
                    child: Text(
                      'Đăng xuất',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 350),
            ],
          ),
        ),
      ),
    );
  }
}
