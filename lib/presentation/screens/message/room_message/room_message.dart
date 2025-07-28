import 'package:flutter/material.dart';

class RoomMessage extends StatefulWidget {
  const RoomMessage({super.key});

  @override
  State<RoomMessage> createState() => _RoomMessageState();
}

class _RoomMessageState extends State<RoomMessage> {
  final List<Map<String, dynamic>> messages = [
    {
      "text":
          "Xin chào vi. Gói cước của bạn sẽ/đã hết hạn vào ngày 22/04/2025. Vui lòng sớm liên hệ CSKH để gia hạn thêm gói cước cũng như nhận được thật nhiều ưu đãi từ LalaHome bạn nhé!",
      "time": "08:05",
      "date": "ngày 22 thg 4, 2025",
    },
    {
      "text":
          "Xin chào vi. Hôm nay là ngày chốt dịch vụ điện nước của toà nhà vi bạn nhé.",
      "time": "08:10",
      "date": "ngày 30 thg 4, 2025",
    },
    {
      "text":
          "Xin chào vi. Hôm nay là ngày chốt dịch vụ điện nước của toà nhà vi bạn nhé.",
      "time": "08:10",
      "date": "ngày 30 thg 5, 2025",
    },
    {
      "text":
          "Xin chào vi. Hôm nay là ngày chốt dịch vụ điện nước của toà nhà vi bạn nhé.",
      "time": "08:15",
      "date": "ngày 30 thg 6, 2025",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LalaBot', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.green,
              child: Text("L", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        msg['date'],
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 14,
                        ),
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          msg['text'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      msg['time'],
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.add, color: Colors.blue),
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Nhập tin nhắn...",
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.green,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_upward, color: Colors.white),
                    onPressed: () {
                      // Gửi tin nhắn
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
