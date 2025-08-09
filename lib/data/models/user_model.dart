class UserModel {
  final String id_nguoidung;
  final String ten;
  final String email;
  final String vaitro;
  final String? token;

  UserModel({
    required this.id_nguoidung,
    required this.ten,
    required this.email,
    required this.vaitro,
    this.token,
  });



    UserModel copyWith({
    String? id_nguoidung,
    String? ten,
    String? email,
    String? vaitro,
    String? token,
  }) {
    return UserModel(
      id_nguoidung: id_nguoidung ?? this.id_nguoidung,
      ten: ten ?? this.ten,
      email: email ?? this.email,
      vaitro: vaitro ?? this.vaitro,
      token: token ?? this.token,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id_nguoidung: map['id_nguoidung'].toString(), 
      ten: map['ten'] as String,
      email: map['email'],
      vaitro: map['vaitro'],
      token: map['token'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_nguoidung': id_nguoidung,
      'ten': ten,
      'email': email,
      'vaitro': vaitro,
      'token': token,
    };
  }
}

