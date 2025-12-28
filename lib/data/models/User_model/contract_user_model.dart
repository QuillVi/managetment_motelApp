import 'dart:convert';

// --- HELPER FUNCTIONS ---

/// Chuyển từ JSON String -> Object
DetailContractUserModel detailContractUserModelFromJson(String str) =>
    DetailContractUserModel.fromMap(json.decode(str));

/// Chuyển từ Object -> JSON String
String detailContractUserModelToJson(DetailContractUserModel data) =>
    json.encode(data.toMap());

// --- MAIN MODELS ---

class DetailContractUserModel {
  bool? success;
  ContractData? data;

  DetailContractUserModel({this.success, this.data});

  // Đổi tên thành fromMap
  factory DetailContractUserModel.fromMap(Map<String, dynamic> map) {
    return DetailContractUserModel(
      success: map["success"],
      data: map["data"] != null ? ContractData.fromMap(map["data"]) : null,
    );
  }

  // Đổi tên thành toMap
  Map<String, dynamic> toMap() => {"success": success, "data": data?.toMap()};
}

class ContractData {
  ThongTinChung? thongTinChung;
  ThongTinPhongO? thongTinPhongO;
  BenAChuNha? benAChuNha;
  BenBNguoiThue? benBNguoiThue;

  ContractData({
    this.thongTinChung,
    this.thongTinPhongO,
    this.benAChuNha,
    this.benBNguoiThue,
  });

  factory ContractData.fromMap(Map<String, dynamic> map) {
    return ContractData(
      thongTinChung:
          map["thong_tin_chung"] != null
              ? ThongTinChung.fromMap(map["thong_tin_chung"])
              : null,
      thongTinPhongO:
          map["thong_tin_phong_o"] != null
              ? ThongTinPhongO.fromMap(map["thong_tin_phong_o"])
              : null,
      benAChuNha:
          map["ben_a_chu_nha"] != null
              ? BenAChuNha.fromMap(map["ben_a_chu_nha"])
              : null,
      benBNguoiThue:
          map["ben_b_nguoi_thue"] != null
              ? BenBNguoiThue.fromMap(map["ben_b_nguoi_thue"])
              : null,
    );
  }

  Map<String, dynamic> toMap() => {
    "thong_tin_chung": thongTinChung?.toMap(),
    "thong_tin_phong_o": thongTinPhongO?.toMap(),
    "ben_a_chu_nha": benAChuNha?.toMap(),
    "ben_b_nguoi_thue": benBNguoiThue?.toMap(),
  };
}

class ThongTinChung {
  int? idHopdong;
  String? trangThai;
  String? ngayBatdau;
  int? thoiHan;
  String? kyThanhtoan;
  String? tienCoc;
  String? tienPhongHangThang;

  ThongTinChung({
    this.idHopdong,
    this.trangThai,
    this.ngayBatdau,
    this.thoiHan,
    this.kyThanhtoan,
    this.tienCoc,
    this.tienPhongHangThang,
  });

  factory ThongTinChung.fromMap(Map<String, dynamic> map) {
    return ThongTinChung(
      idHopdong: map["id_hopdong"],
      trangThai: map["trang_thai"],
      ngayBatdau: map["ngay_batdau"],
      thoiHan: map["thoi_han"],
      kyThanhtoan: map["ky_thanhtoan"],
      tienCoc: map["tien_coc"],
      tienPhongHangThang: map["tien_phong_hang_thang"],
    );
  }

  Map<String, dynamic> toMap() => {
    "id_hopdong": idHopdong,
    "trang_thai": trangThai,
    "ngay_batdau": ngayBatdau,
    "thoi_han": thoiHan,
    "ky_thanhtoan": kyThanhtoan,
    "tien_coc": tienCoc,
    "tien_phong_hang_thang": tienPhongHangThang,
  };

  // Helper lấy giá trị số
  double get tienCocValue => double.tryParse(tienCoc ?? "0") ?? 0.0;
  double get tienPhongValue =>
      double.tryParse(tienPhongHangThang ?? "0") ?? 0.0;
}

class ThongTinPhongO {
  String? tenToanha;
  String? tenPhong;
  String? diaChi;
  String? dienTich;

  ThongTinPhongO({this.tenToanha, this.tenPhong, this.diaChi, this.dienTich});

  factory ThongTinPhongO.fromMap(Map<String, dynamic> map) {
    return ThongTinPhongO(
      tenToanha: map["ten_toanha"],
      tenPhong: map["ten_phong"],
      diaChi: map["dia_chi"],
      dienTich: map["dien_tich"],
    );
  }

  Map<String, dynamic> toMap() => {
    "ten_toanha": tenToanha,
    "ten_phong": tenPhong,
    "dia_chi": diaChi,
    "dien_tich": dienTich,
  };
}

class BenAChuNha {
  String? hoTen;
  String? sdt;
  String? cmndCccd;
  String? diaChiThuongTru;

  BenAChuNha({this.hoTen, this.sdt, this.cmndCccd, this.diaChiThuongTru});

  factory BenAChuNha.fromMap(Map<String, dynamic> map) {
    return BenAChuNha(
      hoTen: map["ho_ten"],
      sdt: map["sdt"],
      cmndCccd: map["cmnd_cccd"],
      diaChiThuongTru: map["dia_chi_thuong_tru"],
    );
  }

  Map<String, dynamic> toMap() => {
    "ho_ten": hoTen,
    "sdt": sdt,
    "cmnd_cccd": cmndCccd,
    "dia_chi_thuong_tru": diaChiThuongTru,
  };
}

class BenBNguoiThue {
  String? hoTen;
  String? sdt;
  String? ngaySinh;
  String? cmndCccd;
  String? ngayCap;
  String? noiCap;
  String? hkThuongTru;

  BenBNguoiThue({
    this.hoTen,
    this.sdt,
    this.ngaySinh,
    this.cmndCccd,
    this.ngayCap,
    this.noiCap,
    this.hkThuongTru,
  });

  factory BenBNguoiThue.fromMap(Map<String, dynamic> map) {
    return BenBNguoiThue(
      hoTen: map["ho_ten"],
      sdt: map["sdt"],
      ngaySinh: map["ngay_sinh"],
      cmndCccd: map["cmnd_cccd"],
      ngayCap: map["ngay_cap"],
      noiCap: map["noi_cap"],
      hkThuongTru: map["hk_thuong_tru"],
    );
  }

  Map<String, dynamic> toMap() => {
    "ho_ten": hoTen,
    "sdt": sdt,
    "ngay_sinh": ngaySinh,
    "cmnd_cccd": cmndCccd,
    "ngay_cap": ngayCap,
    "noi_cap": noiCap,
    "hk_thuong_tru": hkThuongTru,
  };
}
