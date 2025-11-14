import 'package:flutter/material.dart';

class MucDoBadge extends StatelessWidget {
  final String? mucDo;

  const MucDoBadge({super.key, this.mucDo});

  Color getMucDoColor() {
    switch (mucDo?.toLowerCase()) {
      case 'Thấp':
        return Colors.green;
      case 'Trung bình':
        return Colors.orange;
      case 'Cao':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: getMucDoColor().withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        mucDo ?? 'Không xác định',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
