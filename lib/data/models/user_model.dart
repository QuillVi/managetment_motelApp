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

  // Giữ nguyên copyWith và toMap

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
    // Để xử lý dữ liệu người thuê, các trường bắt buộc (required) sẽ được gán giá trị mặc định.
    // Nếu đây là dữ liệu người thuê, bạn sẽ cần truyền 'id_nguoidung', 'email', 'vaitro' thủ công
    // hoặc chuyển đổi UserModel thành một model khác dành riêng cho người thuê.
    // Giả định: Bạn đang cố gắng đổ dữ liệu Người Thuê vào các trường optional của UserModel.

    // Lấy dữ liệu từ trường 'data' nếu tồn tại
    final data = map['data'] ?? map;

    return UserModel(
      // Các trường bắt buộc (required) thường không có trong dữ liệu Người Thuê
      // Cần gán giá trị mặc định hoặc NULL an toàn.
      // Tuy nhiên, vì chúng là required, chúng ta phải gán giá trị không-null.
      // Nếu API này chỉ trả về dữ liệu người thuê, bạn phải tự cung cấp ID.
      id_nguoidung: data['id_nguoidung']?.toString() ?? '',
      ten:
          data['ten'] ??
          data['ten'] ??
          '', // Ánh xạ tên người thuê vào trường 'ten'
      email:
          data['email'] ??
          '', // Thường không có trong dữ liệu người thuê, gán rỗng
      vaitro:
          data['vai_tro'] ??
          '', // Thường không có trong dữ liệu người thuê, gán rỗng
      token: data['token'],

      // Ánh xạ các trường Người Thuê vào các thuộc tính UserModel
      soDienThoai: data['sdt_nguoithue'] ?? data['sdt'] ?? data['so_dienthoai'],
      ngaySinh: data['ngaysinh_nguoithue'] ?? data['ngay_sinh'],
      diaChi: data['diachi_nguoithue'] ?? data['dia_chi'],
      cmndCccd: data['cccd_nguoithue'] ?? data['cmnd_cccd'],
      ngayCap: data['ngaycap_cccd'] ?? data['ngay_cap'],
      noiCap: data['noicap_cccd'] ?? data['noi_cap'],
      phong: data['ten_phong'],
    );
  }

  // Giữ nguyên toMap

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

class ManageModel {
  final int id_nguoidung;
  final String? ten;
  final String? soDienThoai;
  final String? diaChi;

  ManageModel({
    required this.id_nguoidung,
    this.ten,
    this.soDienThoai,
    this.diaChi,
  });

  factory ManageModel.fromMap(Map<String, dynamic> map) {
    return ManageModel(
      id_nguoidung: map['id_nguoidung'],
      ten: map['ten'],
      soDienThoai: map['sdt'],
      diaChi: map['dia_chi'],
    );
  }
}

class SelectTanentContractModel {
  final int idNguoiThue;
  final String? ten;
  final String? sdt;
  final String? ngaySinh;
  final String? diaChi;
  final String? cccd;
  final String? ngayCap;
  final String? noiCap;

  SelectTanentContractModel({
    required this.idNguoiThue,
    this.ten,
    this.sdt,
    this.ngaySinh,
    this.diaChi,
    this.cccd,
    this.ngayCap,
    this.noiCap,
  });

  factory SelectTanentContractModel.fromMap(Map<String, dynamic> map) {
    return SelectTanentContractModel(
      idNguoiThue: map['id_nguoidung'],
      ten: map['ten'],
      sdt: map['sdt'],
      ngaySinh: map['ngay_sinh'],
      diaChi: map['dia_chi'],
      cccd: map['cmnd_cccd'],
      ngayCap: map['ngay_cap'],
      noiCap: map['noi_cap'],
    );
  }
}
