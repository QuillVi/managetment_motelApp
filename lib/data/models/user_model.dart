import 'package:motelapp/data/models/room_model.dart';

class UserModel {
  final String id_nguoidung;
  final String ten;
  final String email;
  final String vaitro;
  final String? soDienThoai;
  final String? token;

  final String? ngaySinh;
  final String? diaChi;
  final String? cmndCccd;
  final String? ngayCap;
  final String? noiCap;
  final String? phong;

  UserModel({
    required this.id_nguoidung,
    required this.ten,
    required this.email,
    required this.vaitro,
    this.soDienThoai,
    this.token,
    this.ngaySinh,
    this.diaChi,
    this.cmndCccd,
    this.ngayCap,
    this.noiCap,
    this.phong,
  });

  UserModel copyWith({
    String? id_nguoidung,
    String? ten,
    String? email,
    String? vaitro,
    String? soDienThoai,
    String? token,
    String? ngaySinh,
    String? diaChi,
    String? cmndCccd,
    String? ngayCap,
    String? noiCap,
    String? phong,
  }) {
    return UserModel(
      id_nguoidung: id_nguoidung ?? this.id_nguoidung,
      ten: ten ?? this.ten,
      email: email ?? this.email,
      vaitro: vaitro ?? this.vaitro,
      soDienThoai: soDienThoai ?? this.soDienThoai,
      token: token ?? this.token,
      ngaySinh: ngaySinh ?? this.ngaySinh,
      diaChi: diaChi ?? this.diaChi,
      cmndCccd: cmndCccd ?? this.cmndCccd,
      ngayCap: ngayCap ?? this.ngayCap,
      noiCap: noiCap ?? this.noiCap,
      phong: phong ?? this.phong,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id_nguoidung: map['id_nguoidung'].toString(),
      ten: map['ten'] ?? '',
      email: map['email'] ?? '',
      vaitro: map['vai_tro'] ?? '',
      soDienThoai: map['sdt'] ?? map['so_dienthoai'],
      token: map['token'],
      ngaySinh: map['ngay_sinh'],
      diaChi: map['dia_chi'],
      cmndCccd: map['cmnd_cccd'],
      ngayCap: map['ngay_cap'],
      noiCap: map['noi_cap'],
      phong: map['ten_phong'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_nguoidung': id_nguoidung,
      'ten': ten,
      'email': email,
      'vai_tro': vaitro,
      'so_dienthoai': soDienThoai,
      'token': token,
      'ngay_sinh': ngaySinh,
      'dia_chi': diaChi,
      'cmnd_cccd': cmndCccd,
      'ngay_cap': ngayCap,
      'noi_cap': noiCap,
      'ten_phong': phong,
    };
  }
}
