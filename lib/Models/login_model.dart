import 'dart:convert';

LoginModels loginModelsFromJson(String str) =>
    LoginModels.fromJson(json.decode(str));

String loginModelsToJson(LoginModels data) => json.encode(data.toJson());

class LoginModels {
  LoginModels({
    this.isActive,
    this.message,
    this.data,
  });

  bool? isActive;
  String? message;
  Data? data;

  factory LoginModels.fromJson(Map<String, dynamic> json) => LoginModels(
        isActive: json["is_active"],
        message: json["message"],
        data: json["data"] != null ? Data.fromJson(json["data"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "is_active": isActive,
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  Data({
    this.idUser,
    this.nama,
    this.email,
    this.password,
    this.roleId,
    this.isActive,
    this.createdAt,
    this.modifiedAt,
  });

  String? idUser;
  String? nama;
  String? email;
  String? password;
  String? roleId;
  int? isActive;
  DateTime? createdAt;
  DateTime? modifiedAt;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        idUser: json["id_user"],
        nama: json["nama"],
        email: json["email"],
        password: json["password"],
        roleId: json["role_id"],
        isActive: json["is_active"] != null
            ? int.tryParse(json["is_active"].toString())
            : null,  // Ubah menjadi int jika berbentuk string
        createdAt: json["created_at"] != null
            ? DateTime.tryParse(json["created_at"]) ?? DateTime.now()
            : null,
        modifiedAt: json["modified_at"] != null
            ? DateTime.tryParse(json["modified_at"]) ?? DateTime.now()
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id_user": idUser,
        "nama": nama,
        "email": email,
        "password": password,
        "role_id": roleId,
        "is_active": isActive,
        "created_at": createdAt?.toIso8601String(),
        "modified_at": modifiedAt?.toIso8601String(),
      };
}
