import 'dart:convert';

class StakeModel {
  // 1. Đổi tên biến cho đúng chuẩn Dart (camelCase) và đúng với JSON
  final String trangThaiCoc;
  final int soLuongCoc;
  final String tongTienCoc; // <-- Sửa từ 'tienCoc'

  StakeModel({
    required this.trangThaiCoc,
    required this.soLuongCoc,
    required this.tongTienCoc, // <-- Sửa ở constructor
  });

  // 2. Sửa lại factory 'fromMap'
  factory StakeModel.fromMap(Map<String, dynamic> map) {
    return StakeModel(
      // Key 'trang_thai_coc' đã đúng
      trangThaiCoc: map['trang_thai_coc'] ?? '',

      // Key 'so_luong_coc' đã đúng
      soLuongCoc: map['so_luong_coc'] ?? 0,

      // 3. Sửa key từ 'tien_coc' -> 'tong_tien_coc'
      tongTienCoc: map['tong_tien_coc'] ?? '0',
    );
  }
}

class ContentStakeModel {
  // 1.  idCoc để khớp với JSON mới
  final int idCoc;
  final int idNguoiDung;
  final String? ten;
  final String? tenPhong;
  final String? tenToanha;
  final String? tienCoc;
  final String? ngayBatdau;

  // 2. Đổi trangThaiCoc thành trangThai
  final String? trangThai;

  ContentStakeModel({
    required this.idCoc,
    required this.idNguoiDung,
    this.ten,
    this.tenPhong,
    this.tenToanha,
    this.tienCoc,
    this.ngayBatdau,
    this.trangThai,
  });

  factory ContentStakeModel.fromMap(Map<String, dynamic> map) {
    return ContentStakeModel(
      // Map key 'id_coc' từ API
      idCoc: map['id_coc'] ?? 0,

      idNguoiDung: map['id_nguoidung'] ?? 0,
      ten: map['ten'] ?? '',
      tenPhong: map['ten_phong'] ?? '',
      tenToanha: map['ten_toanha'] ?? '',
      tienCoc: map['tien_coc'] ?? '',
      ngayBatdau: map['ngay_batdau'] ?? '',

      // Map key 'trang_thai' từ API (Giá trị sẽ là: DangCho, QuaHan, KhachHuy...)
      trangThai: map['trang_thai'] ?? '',
    );
  }
}

// 1. Model cho thông tin người đặt cọc (nằm trong mảng danh_sach_nguoi_dat_coc)
class StakerModel {
  final int idNguoiDatCoc;
  final String? tenNguoiDatCoc;
  final String? sdtNguoiDatCoc;
  final String? emailNguoiDatCoc;
  final String? cmndNguoiDatCoc;
  final String? diaChiNguoiDatCoc;
  final List<String>? anhCmndNguoiDatCoc;

  StakerModel({
    required this.idNguoiDatCoc,
    this.tenNguoiDatCoc,
    this.sdtNguoiDatCoc,
    this.emailNguoiDatCoc,
    this.cmndNguoiDatCoc,
    this.diaChiNguoiDatCoc,
    this.anhCmndNguoiDatCoc,
  });

  factory StakerModel.fromMap(Map<String, dynamic> map) {
    // --- BẮT ĐẦU ĐOẠN XỬ LÝ ẢNH AN TOÀN ---
    List<String> listAnh = [];
    var dataAnh = map['anh_cmnd_nguoi_dat_coc'];

    if (dataAnh != null) {
      if (dataAnh is List) {
        // Trường hợp 1: API trả về đúng là List
        listAnh = List<String>.from(dataAnh.map((e) => e.toString()));
      } else if (dataAnh is String) {
        // Trường hợp 2: API trả về String (ví dụ chuỗi JSON "[link1, link2]")
        if (dataAnh.trim().startsWith('[')) {
          try {
            // Thử decode JSON array
            var decoded = jsonDecode(dataAnh);
            if (decoded is List) {
              listAnh = List<String>.from(decoded.map((e) => e.toString()));
            }
          } catch (e) {
            print("Lỗi parse ảnh JSON: $e");
          }
        } else if (dataAnh.isNotEmpty) {
          // Trường hợp 3: String đơn (1 đường dẫn ảnh duy nhất không phải JSON)
          listAnh = [dataAnh];
        }
      }
    }
    // --- KẾT THÚC ĐOẠN XỬ LÝ ẢNH ---

    return StakerModel(
      idNguoiDatCoc: map['id_nguoidatcoc'] ?? 0,
      tenNguoiDatCoc: map['ten_nguoi_dat_coc'] ?? '',
      sdtNguoiDatCoc: map['sdt_nguoi_dat_coc'] ?? '',
      emailNguoiDatCoc: map['email_nguoi_dat_coc'] ?? '',
      cmndNguoiDatCoc: map['cmnd_nguoi_dat_coc'] ?? '',
      diaChiNguoiDatCoc: map['dia_chi_nguoi_dat_coc'] ?? '',
      anhCmndNguoiDatCoc: listAnh, // Gán danh sách đã xử lý
    );
  }
}

// 2. Model chính cho chi tiết cọc (DetailStakeModel)
class DetailStakeModel {
  final String? tienCoc;
  final int idPhong;
  final String? tenPhong;
  final String? tenToanha;
  final String? ngayHenVao;
  final String? ngayNhanCoc;
  final String? phuongThucThanhToan;
  final String? tenNguoiNhan;
  final String? ghiChuCoc;
  final List<StakerModel> danhSachNguoiDatCoc;

  DetailStakeModel({
    this.tienCoc,
    this.tenPhong,
    required this.idPhong,
    this.tenToanha,
    this.ngayHenVao,
    this.ngayNhanCoc,
    this.phuongThucThanhToan,
    this.tenNguoiNhan,
    this.ghiChuCoc,
    required this.danhSachNguoiDatCoc,
  });

  factory DetailStakeModel.fromMap(Map<String, dynamic> map) {
    return DetailStakeModel(
      tienCoc: map['tien_coc'] ?? '0',
      idPhong: map['id_phong'] ?? 0,
      tenPhong: map['ten_phong'] ?? '',
      tenToanha: map['ten_toanha'] ?? '',
      ngayHenVao: map['ngay_hen_vao'] ?? '',
      ngayNhanCoc: map['ngay_nhan_coc'] ?? '',
      phuongThucThanhToan: map['phuong_thuc_thanh_toan'] ?? '',
      tenNguoiNhan: map['ten_nguoi_nhan'] ?? '',
      ghiChuCoc: map['ghi_chu'] ?? '',

      // Xử lý mapping danh sách lồng nhau (Nested List)
      danhSachNguoiDatCoc:
          map['danh_sach_nguoi_dat_coc'] != null
              ? List<StakerModel>.from(
                (map['danh_sach_nguoi_dat_coc'] as List).map(
                  (x) => StakerModel.fromMap(x),
                ),
              )
              : [],
    );
  }
}

class SelectRoomStakeModel {
  final List<RoomStakeItem> daCoCoc;
  final List<RoomStakeItem> chuaCoCoc;

  SelectRoomStakeModel({this.daCoCoc = const [], this.chuaCoCoc = const []});

  // Factory để parse dữ liệu từ JSON tổng (cục 'data')
  factory SelectRoomStakeModel.fromMap(Map<String, dynamic> map) {
    return SelectRoomStakeModel(
      daCoCoc:
          map['da_co_coc'] != null
              ? List<RoomStakeItem>.from(
                (map['da_co_coc'] as List).map((x) => RoomStakeItem.fromMap(x)),
              )
              : [],
      chuaCoCoc:
          map['chua_co_coc'] != null
              ? List<RoomStakeItem>.from(
                (map['chua_co_coc'] as List).map(
                  (x) => RoomStakeItem.fromMap(x),
                ),
              )
              : [],
    );
  }
}

// Class đại diện cho từng phòng
class RoomStakeItem {
  final int idPhong;
  final String tenPhong;
  final String tenToanha;
  final String diaChi;
  final String? trangThaiCoc;

  RoomStakeItem({
    required this.idPhong,
    required this.tenPhong,
    required this.tenToanha,
    required this.diaChi,
    this.trangThaiCoc,
  });

  factory RoomStakeItem.fromMap(Map<String, dynamic> map) {
    return RoomStakeItem(
      idPhong: map['id_phong'] ?? 0,
      tenPhong: map['ten_phong'] ?? '',
      tenToanha: map['ten_toanha'] ?? '',
      diaChi: map['dia_chi'] ?? '',
      trangThaiCoc:
          map['trang_thai_coc'], // Có thể null hoặc 'ChuaCo', 'DangCho'...
    );
  }
}
