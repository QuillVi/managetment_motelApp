class BuildingModel {
  final int id_toanha;
  final String tentoanha;
  final String diachi_toanha;
  final int? so_tang;
  final int? id_quanly;


BuildingModel({
  required this.id_toanha,
  required this.tentoanha,
  required this.diachi_toanha,
  this.so_tang,
  this.id_quanly,
});

factory BuildingModel.fromMap(Map<String, dynamic> map) {
  return BuildingModel(
    id_toanha: map['id_toanha'] ?? 0,
    tentoanha: map['ten_toanha'] ?? '',
    diachi_toanha: map['diachi_toanha'] ?? '',
    so_tang: map['so_tang'],
    id_quanly: map['id_quanly'],
  );

}
}