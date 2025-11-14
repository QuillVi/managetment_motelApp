import 'package:flutter/material.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/router/app_router.dart';

class DetailContract extends StatefulWidget {
  const DetailContract({super.key});

  @override
  State<DetailContract> createState() => _DetailContractState();
}

class _DetailContractState extends State<DetailContract> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hợp đồng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => getIt<AppRouter>().pop(),
        ),
        actions: const [
          Icon(Icons.description_outlined, color: Colors.orange),
          SizedBox(width: 16),
          Icon(Icons.share_outlined, color: Colors.orange),
          SizedBox(width: 16),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          /// Mã hợp đồng + ngày
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '#013351',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text('23-03-2025', style: TextStyle(color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 12),

          /// Phòng, ngày bắt đầu - hết hạn, người tạo
          Row(
            children: const [
              Icon(Icons.home_outlined, size: 20, color: Colors.grey),
              SizedBox(width: 6),
              Text('số 1 - vi'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: const [
              Icon(Icons.calendar_month_outlined, size: 20, color: Colors.grey),
              SizedBox(width: 6),
              Expanded(
                child: Text('Từ 23-03-2025 đến [Chưa xác định thời hạn]'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: const [
              Icon(Icons.account_box_outlined, size: 20, color: Colors.grey),
              SizedBox(width: 6),
              Text('Người tạo: vi'),
            ],
          ),
          const Divider(height: 24),

          /// Thông tin tài chính
          _infoRow('Tiền phòng', '3.000.000 đ'),
          _infoRow('Tiền cọc', '2.000.000 đ'),
          _infoRow('Kỳ thanh toán', '1 tháng'),

          const SizedBox(height: 16),

          /// Các nút hành động
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _actionButton('Chỉnh sửa', Colors.orange),
              _actionButton('Xoá', Colors.red),
              _actionButton('Thanh lý', Colors.green),
            ],
          ),

          const SizedBox(height: 24),

          /// Dịch vụ
          const Text(
            'Dịch vụ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Divider(),

          /// Người thuê phòng
          const Text(
            'Người thuê phòng',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[100],
            ),
            child: Row(
              children: const [
                CircleAvatar(radius: 24, child: Icon(Icons.person, size: 28)),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('huy', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('404640464', style: TextStyle(color: Colors.green)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          /// Điều khoản
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Điều khoản',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _actionButton(String label, Color color) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}
