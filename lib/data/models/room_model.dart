import 'package:motelapp/data/models/contract_model.dart';
import 'package:motelapp/data/models/service_model.dart';
import 'package:motelapp/data/models/user_model.dart';

class RoomModel {
  final int idPhong;
  final int idToaNha;
  final String tenPhong;
  final int soTang;
  final double dienTich;
  final double giaPhong;
  final int soNguoiThue;
  final double tienDatCoc;
  final int phongKhach;
  final int phongNgu;
  final String? anhPhong;
  final String trangThai;
  final String tienIchPhong;
  final String noiThat;
  final String moTaPhong;
  final String luuYChoNguoiThuePhong;
  final List<ServiceModel>? dichvu;
  final ContractModel? hopdong;
  final UserModel? nguoidung;

  RoomModel({
    required this.idPhong,
    required this.idToaNha,
    required this.tenPhong,
    required this.soTang,
    required this.dienTich,
    required this.giaPhong,
    required this.soNguoiThue,
    required this.tienDatCoc,
    required this.phongKhach,
    required this.phongNgu,
    this.anhPhong,
    required this.trangThai,
    required this.tienIchPhong,
    required this.noiThat,
    required this.moTaPhong,
    required this.luuYChoNguoiThuePhong,
    this.dichvu,
    this.hopdong,
    this.nguoidung,
  });

  /// Parse từ Map (API trả về)
  factory RoomModel.fromMap(Map<String, dynamic> map) {
    return RoomModel(
      idPhong: map['id_phong'] ?? 0,
      idToaNha: map['id_toanha'] ?? 0,
      tenPhong: map['ten_phong'] ?? '',
      soTang: map['so_tang'] ?? 0,
      dienTich: double.tryParse(map['dien_tich']?.toString() ?? '') ?? 0.0,
      giaPhong: double.tryParse(map['gia_phong']?.toString() ?? '') ?? 0.0,
      soNguoiThue: map['so_nguoi_thue'] ?? 0,
      tienDatCoc: double.tryParse(map['tien_dat_coc']?.toString() ?? '') ?? 0.0,
      phongKhach: map['phong_khach'] ?? 0,
      phongNgu: map['phong_ngu'] ?? 0,
      anhPhong: map['anh_phong'],
      trangThai: map['trang_thai'] ?? 'Trống',
      tienIchPhong: map['tien_ich_phong'] ?? '',
      noiThat: map['noi_that'] ?? '',
      moTaPhong: map['mo_ta_phong'] ?? '',
      luuYChoNguoiThuePhong: map['luu_y_cho_nguoi_thue_phong'] ?? '',
      dichvu:
          map['dichvu'] != null
              ? List<ServiceModel>.from(
                (map['dichvu'] as List).map(
                  (e) => ServiceModel.fromMap(e as Map<String, dynamic>),
                ),
              )
              : [],
      hopdong:
          map['hopdong'] != null
              ? ContractModel.fromMap(map['hopdong'] as Map<String, dynamic>)
              : null,

      nguoidung:
          map['nguoidung'] != null
              ? UserModel.fromMap(map['nguoidung'] as Map<String, dynamic>)
              : null,
    );
  }

  factory RoomModel.fromJson(Map<String, dynamic> json) =>
      RoomModel.fromMap(json);

  /// Convert object -> Map
  Map<String, dynamic> toMap() {
    return {
      'id_phong': idPhong,
      'id_toanha': idToaNha,
      'ten_phong': tenPhong,
      'so_tang': soTang,
      'dien_tich': dienTich,
      'gia_phong': giaPhong,
      'so_nguoi_thue': soNguoiThue,
      'tien_dat_coc': tienDatCoc,
      'phong_khach': phongKhach,
      'phong_ngu': phongNgu,
      'anh_phong': anhPhong,
      'trang_thai': trangThai,
      'tien_ich_phong': tienIchPhong,
      'noi_that': noiThat,
      'mo_ta_phong': moTaPhong,
      'luu_y_cho_nguoi_thue_phong': luuYChoNguoiThuePhong,
      'dichvu': dichvu,
      'hopdong': hopdong,
      'nguoiDung': nguoidung,
    };
  }

  Map<String, dynamic> toJson() => toMap();
}

class ListRoomProblemModel {
  final int id_phong;
  final int id_toanha;
  final String ten_phong;
  final String ten_toanha;
  final String dia_chi;
  final String trang_thai_coc;

  ListRoomProblemModel({
    required this.id_phong,
    required this.id_toanha,
    required this.ten_phong,
    required this.ten_toanha,
    required this.dia_chi,
    required this.trang_thai_coc,
  });

  /// Parse từ Map (API trả về)
  factory ListRoomProblemModel.fromMap(Map<String, dynamic> map) {
    return ListRoomProblemModel(
      id_phong: map['id_phong'],
      id_toanha: map['id_toanha'],
      ten_phong: map['ten_phong'],
      ten_toanha: map['ten_toanha'],
      dia_chi: map['dia_chi'],
      trang_thai_coc: map['trang_thai_coc'],
    );
  }
}

class NameRoomBuildingModel {
  final int id_phong;
  final int id_toanha;
  final String ten_phong;
  final String ten_toanha;

  NameRoomBuildingModel({
    required this.id_phong,
    required this.id_toanha,
    required this.ten_phong,
    required this.ten_toanha,
  });

  /// Parse từ Map (API trả về)
  factory NameRoomBuildingModel.fromMap(Map<String, dynamic> map) {
    return NameRoomBuildingModel(
      id_phong: map['id_phong'],
      id_toanha: map['id_toanha'],
      ten_phong: map['ten_phong'],
      ten_toanha: map['ten_toanha'],
    );
  }
}

class SelectRoomManagetModel {
  final int id_phong;
  final int id_toanha;
  final int id_hopdong;
  final String ten_phong;
  final double gia_phong;
  final String ten_toanha;
  final String dia_chi;
  final String trang_thai_coc;
  final int id_nguoidung;
  final List<ServiceModel> ds_dichvu; // List<ServiceModel>

  SelectRoomManagetModel({
    required this.id_phong,
    required this.id_toanha,
    required this.id_hopdong,
    required this.ten_phong,
    required this.gia_phong,
    required this.ten_toanha,
    required this.dia_chi,
    required this.trang_thai_coc,
    required this.id_nguoidung,
    required this.ds_dichvu,
  });

  /// Parse từ Map (API trả về)
  factory SelectRoomManagetModel.fromMap(Map<String, dynamic> map) {
    return SelectRoomManagetModel(
      id_phong: map['id_phong'],
      id_toanha: map['id_toanha'],
      id_hopdong: map['id_hopdong'],
      ten_phong: map['ten_phong'],
      gia_phong: double.tryParse(map['gia_phong']?.toString() ?? '0.0') ?? 0.0,
      ten_toanha: map['ten_toanha'],
      dia_chi: map['dia_chi'],
      trang_thai_coc: map['trang_thai_coc'],
      id_nguoidung: map['id_nguoidung'],
      ds_dichvu:
          (map['ds_dichvu'] as List<dynamic>)
              .map((item) => ServiceModel.fromMap(item as Map<String, dynamic>))
              .toList(),
    );
  }
}

class SelectRoomIDManagetModel {
  final int idPhong;
  final String tenPhong;
  final String tenToaNha;
  final String giaPhong;
  final String tienDatCoc;
  final String diaChiToaNha;
  final String trangThaiHopDong;
  final String trangThaiPhong;

  SelectRoomIDManagetModel({
    required this.idPhong,
    required this.tenPhong,
    required this.tenToaNha,
    required this.giaPhong,
    required this.tienDatCoc,
    required this.diaChiToaNha,
    required this.trangThaiHopDong,
    required this.trangThaiPhong,
  });

  /// Parse từ Map (API trả về)
  factory SelectRoomIDManagetModel.fromMap(Map<String, dynamic> map) {
    return SelectRoomIDManagetModel(
      idPhong: map['id_phong'] ?? 0,
      tenPhong: map['ten_phong'] ?? '',
      tenToaNha: map['ten_toanha'] ?? '',
      giaPhong: map['gia_phong'] ?? '0',
      tienDatCoc: map['tien_dat_coc'] ?? '0',
      diaChiToaNha: map['dia_chi_toanha'] ?? '',
      trangThaiHopDong: map['trang_thai_hop_dong'] ?? 'ChuaCoHopDong',
      trangThaiPhong: map['trang_thai_phong'] ?? 'Trống',
    );
  }
}
