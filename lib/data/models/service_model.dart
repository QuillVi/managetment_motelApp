class ServiceModel {
  final int id_dichvu;
  final String ten_dichvu;
  final double phi_dichvu;
  final String? icon;

  ServiceModel({
    required this.id_dichvu,
    required this.ten_dichvu,
    required this.phi_dichvu,
    this.icon,
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id_dichvu: map['id_dichvu'] ?? 0,
      ten_dichvu: map['ten_dichvu'] ?? '',
      phi_dichvu:
          map['phi_dichvu'] != null
              ? double.tryParse(map['phi_dichvu'].toString()) ?? 0.0
              : 0.0,
      icon: map['icon'],
    );
  }
}
