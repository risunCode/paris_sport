import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'AddProduct.dart';
import 'EditProduct.dart';

// Model untuk produk
class Product {
  final String idItem;
  final String namaItem;
  final String deskripsi;
  final String lokasi;
  final String harga;
  final String sisaSlot;
  final String gambar;

  Product({
    required this.idItem,
    required this.namaItem,
    required this.deskripsi,
    required this.lokasi,
    required this.harga,
    required this.sisaSlot,
    required this.gambar,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      idItem: json['id_item'],
      namaItem: json['nama_item'],
      deskripsi: json['deskripsi'],
      lokasi: json['lokasi'],
      harga: json['harga'],
      sisaSlot: json['sisa_slot'],
      gambar: json['gambar'],
    );
  }
}

// Fungsi untuk mengambil data produk dari API
Future<List<Product>> fetchProducts() async {
  final response = await http.get(Uri.parse(
      'https://classic-duly-goat.ngrok-free.app/lapangan_apiku/api/GET_Product'));

  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = json.decode(response.body);
    return jsonResponse.map((product) => Product.fromJson(product)).toList();
  } else {
    throw Exception('Failed to load products');
  }
}

// Fungsi untuk menghapus item dari API
Future<bool> deleteItem(String idItem) async {
  var dio = Dio();
  String baseurl = "https://classic-duly-goat.ngrok-free.app/lapangan_apiku";

  Map<String, dynamic> data = {
    "id_item": idItem,
  };

  try {
    final response = await dio.delete(
      "$baseurl/api/product/DELETE_item",
      data: data,
      options: Options(
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      ),
    );

    if (response.statusCode == 200) {
      print("Item berhasil dihapus");
      return true;
    } else {
      print("Failed to delete item with status code: ${response.statusCode}");
    }
  } catch (e) {
    print("Failed to delete item: $e");
  }

  return false;
}

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<Product>> futureProducts;

  @override
  void initState() {
    super.initState();
    futureProducts = fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List'),
      ),
      body: FutureBuilder<List<Product>>(
        future: futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products available.'));
          } else {
            final products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: product.gambar.isNotEmpty
                            ? Image.network(product.gambar)
                            : const Icon(Icons.image_not_supported),
                        title: Text(product.namaItem),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Lokasi: ${product.lokasi}'),
                            Text('Deskripsi: ${product.deskripsi}'),
                            Text('Harga: ${product.harga}'),
                            Text('Slot tersisa: ${product.sisaSlot}'),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              bool success =
                                  await deleteItem(product.idItem);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Item berhasil dihapus')),
                                );
                                setState(() {
                                  futureProducts = fetchProducts();
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Gagal menghapus item')),
                                );
                              }
                            },
                            icon: const Icon(Icons.delete),
                            label: const Text('Hapus'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProduct(
                                      productId: product.idItem, // Pastikan product.idItem benar
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit'),
                            ),  
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProduct()),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
