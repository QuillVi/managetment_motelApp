import 'package:motelapp/data/models/manager_model.dart';
import 'package:motelapp/data/models/service_model.dart';

class BuildingModel {
  final int id_toanha;
  final String tentoanha;
  final String diachi_toanha;
  final int? soPhong;
  final String? soNguoiThue;
  final int? soTang;
  final double? phiThueNha;
  final String? moCua;
  final String? dongCua;
  final String? ngayChotTien;
  final String? chuyenBaoTruoc;
  final String? thoiGianNopTien;
  final String? moTa;
  final List<String>? tien_ich_toanha;
  final String? luu_y_cho_nguoi_thue;
  final String? ghi_chu_hoa_don;
  final ManagerModel? quanly;
  final List<ServiceModel>? dichvu; // Danh sách dịch vụ

  BuildingModel({
    required this.id_toanha,
    required this.tentoanha,
    required this.diachi_toanha,
    this.soPhong,
    this.soNguoiThue,
    this.soTang,
    this.phiThueNha,
    this.moCua,
    this.dongCua,
    this.ngayChotTien,
    this.chuyenBaoTruoc,
    this.thoiGianNopTien,
    this.moTa,
    this.tien_ich_toanha,
    this.luu_y_cho_nguoi_thue,
    this.ghi_chu_hoa_don,
    this.quanly,
    this.dichvu,
  });

  factory BuildingModel.fromMap(Map<String, dynamic> map) {
    return BuildingModel(
      id_toanha: map['id_toanha'] ?? 0,
      tentoanha: map['ten_toanha'] ?? '',
      diachi_toanha: map['dia_chi'] ?? '',
      soTang: map['so_tang'],
      soPhong: map['so_phong'],
      soNguoiThue: map['so_nguoi_thue']?.toString(),
      phiThueNha:
          map['phi_thue_nha'] != null
              ? double.tryParse(map['phi_thue_nha'].toString())
              : null,
      moCua: map['mo_cua'],
      dongCua: map['dong_cua'],
      ngayChotTien: map['ngay_chot_tien'],
      chuyenBaoTruoc: map['chuyen_bao_truoc'],
      thoiGianNopTien: map['thoi_gian_nop_tien'],
      moTa: map['mo_ta'],
      tien_ich_toanha:
          map['tien_ich_toanha'] != null
              ? (map['tien_ich_toanha'] as String)
                  .split(',')
                  .map((e) => e.trim())
                  .toList()
              : null,
      luu_y_cho_nguoi_thue: map['luu_y_cho_nguoi_thue'],
      ghi_chu_hoa_don: map['ghi_chu_hoa_don'],
      quanly:
          map['quanly'] != null ? ManagerModel.fromMap(map['quanly']) : null,

      dichvu:
          map['dichvu'] != null
              ? List<ServiceModel>.from(
                (map['dichvu'] as List).map((x) => ServiceModel.fromMap(x)),
              )
              : null,
    );
  }
}
