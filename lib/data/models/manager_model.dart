class ManagerModel {
  final int id_quanly;
  final String ten;
  final String sdt;

  ManagerModel({required this.id_quanly, required this.ten, required this.sdt});

  factory ManagerModel.fromMap(Map<String, dynamic> map) {
    return ManagerModel(
      id_quanly: map['id_quanly'] ?? 0,
      ten: map['ten'] ?? '',
      sdt: map['sdt'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'id_quanly': id_quanly, 'ten': ten, 'sdt': sdt};
  }
}
