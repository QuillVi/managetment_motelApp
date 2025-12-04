import 'package:motelapp/data/models/tanent_model.dart';

class ContractModel {
  final int idHopDong;
  final String ngayBatDau;
  final int thoiHan;

  ContractModel({
    required this.idHopDong,
    required this.ngayBatDau,
    required this.thoiHan,
  });

  factory ContractModel.fromMap(Map<String, dynamic> map) {
    return ContractModel(
      idHopDong: map['id_hopdong'] ?? 0,
      ngayBatDau: map['ngay_batdau'] ?? '',
      thoiHan: map['thoi_han'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_hopdong': idHopDong,
      'ngay_batdau': ngayBatDau,
      'thoi_han': thoiHan,
    };
  }
}

class ListContractModel {
  final int id_hopdong;
  final String ten_phong;
  final String ten_toanha;
  final String ngay_batdau;
  final int thoi_han;
  final String trang_thai;
  final String ten_quanly;

  ListContractModel({
    required this.id_hopdong,
    required this.ten_phong,
    required this.ten_toanha,
    required this.ngay_batdau,
    required this.thoi_han,
    required this.trang_thai,
    required this.ten_quanly,
  });

  // --- HÀM COPYWITH ĐƯỢC THÊM MỚI ---
  ListContractModel copyWith({
    int? id_hopdong,
    String? ten_phong,
    String? ten_toanha,
    String? ngay_batdau,
    int? thoi_han,
    String? trang_thai,
    String? ten_quanly,
  }) {
    return ListContractModel(
      id_hopdong: id_hopdong ?? this.id_hopdong,
      ten_phong: ten_phong ?? this.ten_phong,
      ten_toanha: ten_toanha ?? this.ten_toanha,
      ngay_batdau: ngay_batdau ?? this.ngay_batdau,
      thoi_han: thoi_han ?? this.thoi_han,
      trang_thai: trang_thai ?? this.trang_thai,
      ten_quanly: ten_quanly ?? this.ten_quanly,
    );
  }

  factory ListContractModel.fromMap(Map<String, dynamic> map) {
    return ListContractModel(
      id_hopdong: map['id_hopdong'] ?? 0,
      ten_phong: map['ten_phong'] ?? '',
      ten_toanha: map['ten_toanha'] ?? '',
      ngay_batdau: map['ngay_batdau'] ?? '',
      thoi_han: map['thoi_han'] ?? 0,
      trang_thai: map['trang_thai'] ?? '',
      ten_quanly: map['ten_nguoi_quan_ly'] ?? '',
    );
  }
}

class DetailContractModel {
  final int idHopDong;
  final String ngayBatDau;
  final String tenPhong;
  final String tenToaNha;
  final String diaChiToaNha;
  final int thoiHan;

  // Thông tin tài chính
  final String tienPhong;
  final String tienCoc;
  final String kyThanhToan;

  // Thông tin Chủ nhà (Bên A)
  final String tenNguoiTao;
  final String? ngaySinhChuNha;
  final String? hkThuongTruChuNha;
  final String? cccdChuNha;
  final String? ngayCapChuNha;
  final String? noiCapChuNha;
  final String? sdtChuNha;

  // Danh sách người thuê (Bên B)
  final List<TenantDetailContractModel> listNguoiThue;

  DetailContractModel({
    required this.idHopDong,
    required this.ngayBatDau,
    required this.tenPhong,
    required this.tenToaNha,
    required this.diaChiToaNha,
    required this.thoiHan,
    required this.tienPhong,
    required this.tienCoc,
    required this.kyThanhToan,
    required this.tenNguoiTao,
    this.ngaySinhChuNha,
    this.hkThuongTruChuNha,
    this.cccdChuNha,
    this.ngayCapChuNha,
    this.noiCapChuNha,
    this.sdtChuNha,
    required this.listNguoiThue,
  });

  DetailContractModel copyWith({
    int? idHopDong,
    String? ngayBatDau,
    String? tenPhong,
    String? tenToaNha,
    String? diaChiToaNha,
    int? thoiHan,
    String? tienPhong,
    String? tienCoc,
    String? kyThanhToan,
    String? tenNguoiTao,
    String? ngaySinhChuNha,
    String? hkThuongTruChuNha,
    String? cccdChuNha,
    String? ngayCapChuNha,
    String? noiCapChuNha,
    String? sdtChuNha,
    List<TenantDetailContractModel>? listNguoiThue,
  }) {
    return DetailContractModel(
      idHopDong: idHopDong ?? this.idHopDong,
      ngayBatDau: ngayBatDau ?? this.ngayBatDau,
      tenPhong: tenPhong ?? this.tenPhong,
      tenToaNha: tenToaNha ?? this.tenToaNha,
      diaChiToaNha: diaChiToaNha ?? this.diaChiToaNha,
      thoiHan: thoiHan ?? this.thoiHan,
      tienPhong: tienPhong ?? this.tienPhong,
      tienCoc: tienCoc ?? this.tienCoc,
      kyThanhToan: kyThanhToan ?? this.kyThanhToan,
      tenNguoiTao: tenNguoiTao ?? this.tenNguoiTao,

      // Các trường nullable: ưu tiên giá trị mới, nếu không có thì lấy giá trị cũ
      ngaySinhChuNha: ngaySinhChuNha ?? this.ngaySinhChuNha,
      hkThuongTruChuNha: hkThuongTruChuNha ?? this.hkThuongTruChuNha,
      cccdChuNha: cccdChuNha ?? this.cccdChuNha,
      ngayCapChuNha: ngayCapChuNha ?? this.ngayCapChuNha,
      noiCapChuNha: noiCapChuNha ?? this.noiCapChuNha,
      sdtChuNha: sdtChuNha ?? this.sdtChuNha,

      listNguoiThue: listNguoiThue ?? this.listNguoiThue,
    );
  }

  factory DetailContractModel.fromJson(Map<String, dynamic> json) {
    return DetailContractModel(
      idHopDong: json['id_hopdong'] ?? 0,
      ngayBatDau: json['ngay_batdau'] ?? '',
      tenPhong: json['ten_phong'] ?? '',
      tenToaNha: json['ten_toanha'] ?? '',
      diaChiToaNha: json['dia_chi_toa_nha'] ?? '', // Default rỗng nếu null
      thoiHan: json['thoi_han'] ?? 0,

      // Chuyển đổi số sang string an toàn
      tienPhong: json['tien_phong']?.toString() ?? '0',
      tienCoc: json['tien_coc']?.toString() ?? '0',
      kyThanhToan: json['ky_thanhtoan'] ?? '',

      // Mapping thông tin chủ nhà
      tenNguoiTao: json['ten_nguoi_tao'] ?? '',
      ngaySinhChuNha: json['ngay_sinh_chu_nha'],
      hkThuongTruChuNha: json['hk_thuong_tru_chu_nha'],
      cccdChuNha: json['cmnd_cccd_chu_nha'],
      ngayCapChuNha: json['ngay_cap_cmnd_chu_nha'],
      noiCapChuNha: json['noi_cap_cmnd_chu_nha'],
      sdtChuNha: json['sdt_chu_nha'],

      // Mapping danh sách người thuê
      listNguoiThue:
          (json['list_nguoi_thue'] as List<dynamic>?)
              ?.map((e) => TenantDetailContractModel.fromMap(e))
              .toList() ??
          [],
    );
  }
}
