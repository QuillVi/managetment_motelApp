class AmenityModel {
  final String tienIchToaNha;

  AmenityModel({required this.tienIchToaNha});

  factory AmenityModel.fromMap(Map<String, dynamic> map) {
    return AmenityModel(tienIchToaNha: map['tien_ich_toanha'] ?? '');
  }
}
