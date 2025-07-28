import 'package:flutter/material.dart';

class DetailStake extends StatefulWidget {
  const DetailStake({super.key});

  @override
  State<DetailStake> createState() => _DetailStakeState();
}

class _DetailStakeState extends State<DetailStake> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chi tiết cọc',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: const BackButton(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// Số tiền
          Center(
            child: Text(
              '3.000.000 đ',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),

          /// Thông tin chi tiết
          _buildDetailRow(Icons.home_outlined, 'số 1 - vi'),
          _buildDetailRow(Icons.calendar_today, 'Ngày hẹn vào 23-03-2025'),
          _buildDetailRow(
            Icons.calendar_today_outlined,
            'Ngày nhận cọc 23-03-2025',
          ),
          _buildDetailRow(Icons.person, 'Người nhận tiền vi'),

          const SizedBox(height: 24),

          /// Người đặt cọc
          _buildCardSection(
            title: 'Người đặt cọc',
            child: Row(
              children: [
                const CircleAvatar(radius: 24, backgroundColor: Colors.grey),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('vi'),
                    SizedBox(height: 4),
                    Text('0846941020', style: TextStyle(color: Colors.green)),
                  ],
                ),
              ],
            ),
          ),

          /// Ảnh giao dịch
          const SizedBox(height: 16),
          _buildCardSection(
            title: 'Ảnh giao dịch',
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Dữ liệu trống',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),

          /// Ghi chú
          const SizedBox(height: 16),
          _buildCardSection(
            title: 'Ghi chú',
            child: const TextField(
              maxLines: 3,
              decoration: InputDecoration.collapsed(hintText: 'Nhập ghi chú'),
            ),
          ),
        ],
      ),
    );
  }

  /// Một dòng thông tin
  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  /// Thẻ có tiêu đề (Người đặt cọc, Ảnh giao dịch...)
  Widget _buildCardSection({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
