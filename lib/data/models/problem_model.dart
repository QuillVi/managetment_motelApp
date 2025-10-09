class ProblemModelRequesting {
  final int id_suco;
  final int id_phong;
  final String ten_suco;
  final String? muc_do;
  final DateTime? createdAt;
  final String? ten_phong;
  final String? ten_toanha;
  final String? dia_chi;
  final String? ten_nguoithue;
  final String? Trang_thai;
  final String? hop_dong_trang_thai;

  ProblemModelRequesting({
    required this.id_suco,
    required this.id_phong,
    required this.ten_suco,
    this.muc_do,
    this.createdAt,
    this.ten_phong,
    this.ten_toanha,
    this.dia_chi,
    this.ten_nguoithue,
    this.Trang_thai,
    this.hop_dong_trang_thai,
  });

  factory ProblemModelRequesting.fromMap(Map<String, dynamic> map) {
    return ProblemModelRequesting(
      id_suco: map['id_suco'],
      id_phong: map['id_phong'],
      ten_suco: map['ten_suco'] ?? '',
      muc_do: map['muc_do'],
      createdAt:
          map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null,
      ten_phong: map['ten_phong'],
      ten_toanha: map['ten_toanha'],
      dia_chi: map['dia_chi'],
      ten_nguoithue: map['nguoi_thue'],
      Trang_thai: map['trang_thai'],
      hop_dong_trang_thai: map['hopdong_trang_thai'],
    );
  }
}

class ProblemModelDoned {
  final int id_suco;
  final int id_phong;
  final String ten_suco;
  final String? muc_do;
  final DateTime? updatedAt;
  final String? ten_phong;
  final String? ten_toanha;
  final String? dia_chi;
  final String? ten_nguoithue;
  final String? Trang_thai;
  final String? hop_dong_trang_thai;

  ProblemModelDoned({
    required this.id_suco,
    required this.id_phong,
    required this.ten_suco,
    this.muc_do,
    this.updatedAt,
    this.ten_phong,
    this.ten_toanha,
    this.dia_chi,
    this.ten_nguoithue,
    this.Trang_thai,
    this.hop_dong_trang_thai,
  });

  factory ProblemModelDoned.fromMap(Map<String, dynamic> map) {
    return ProblemModelDoned(
      id_suco: map['id_suco'],
      id_phong: map['id_phong'],
      ten_suco: map['ten_suco'] ?? '',
      muc_do: map['muc_do'],
      updatedAt:
          map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt']) : null,
      ten_phong: map['ten_phong'],
      ten_toanha: map['ten_toanha'],
      dia_chi: map['dia_chi'],
      ten_nguoithue: map['nguoi_thue'],
      Trang_thai: map['trang_thai'],
      hop_dong_trang_thai: map['hopdong_trang_thai'],
    );
  }
}
