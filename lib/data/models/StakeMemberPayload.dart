class StakeMemberPayload {
  String ten;
  String sdt;
  String email;
  String cmnd;
  String diaChi;
  List<String> anhCmnd; // <--- Thêm trường này

  StakeMemberPayload({
    required this.ten,
    required this.sdt,
    this.email = '',
    this.cmnd = '',
    this.diaChi = '',
    this.anhCmnd = const [], // Mặc định là mảng rỗng
  });

  Map<String, dynamic> toMap() {
    return {
      'ten': ten,
      'sdt': sdt,
      'email': email,
      'cmnd': cmnd,
      'dia_chi': diaChi,
      'anh_cmnd': anhCmnd, // Map luôn cả ảnh
    };
  }
}
