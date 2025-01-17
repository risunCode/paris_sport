import 'dart:convert';

List<ProdukModel> produkModelFromJson(String str) => List<ProdukModel>.from(
    json.decode(str).map((x) => ProdukModel.fromJson(x)));

String produkModelToJson(List<ProdukModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProdukModel {
  ProdukModel({
    this.nama_item,
    this.deskripsi,
    this.lokasi,
    this.harga,
    this.gambar,
    this.sisa_slot,
    this.tanggal_input,
    this.updated_at,
    this.created_at,
  });

  String? nama_item;
  String? deskripsi;
  String? lokasi;
  int? harga;
  String? gambar;
  String? sisa_slot;
  DateTime? tanggal_input;
  DateTime? updated_at;
  DateTime? created_at;

  factory ProdukModel.fromJson(Map<String, dynamic> json) => ProdukModel(
        nama_item: json["nama_item"],
        deskripsi: json["deskripsi"],
        lokasi: json["lokasi"],
        harga: json["harga"],
        gambar: json["gambar"],
        sisa_slot: json["sisa_slot"],
        tanggal_input: DateTime.tryParse(json["tanggal_input"] ?? ''),
        updated_at: DateTime.tryParse(json["updated_at"] ?? ''),
        created_at: DateTime.tryParse(json["created_at"] ?? ''),
      );

  Map<String, dynamic> toJson() => {
        "nama_item": nama_item,
        "deskripsi": deskripsi,
        "lokasi": lokasi,
        "harga": harga,
        "gambar": gambar,
        "sisa_slot": sisa_slot,
        "tanggal_input": tanggal_input?.toIso8601String(),
        "updated_at": updated_at?.toIso8601String(),
        "created_at": created_at?.toIso8601String(),
      };
}
