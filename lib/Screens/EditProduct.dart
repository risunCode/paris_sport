import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:paris_sport/Screens/MainScreens.dart';

class EditProduct extends StatefulWidget {
  final String productId;

  const EditProduct({super.key, required this.productId});

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final String productApiUrl =
      "https://classic-duly-goat.ngrok-free.app/lapangan_apiku/api/GET_Product";
  final String updateApiUrl =
      "https://classic-duly-goat.ngrok-free.app/lapangan_apiku/api/product/PUT_item";

  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {
    'nama_item': TextEditingController(),
    'deskripsi': TextEditingController(),
    'lokasi': TextEditingController(),
    'harga': TextEditingController(),
    'sisa_slot': TextEditingController(),
  };

  String? imageUrl;
  bool _isLoading = false;

  // Fungsi untuk mengambil data produk berdasarkan ID
  Future<void> fetchProductData() async {
    try {
      setState(() => _isLoading = true);

      final dio = Dio();
      final response = await dio.get(
        productApiUrl,
        queryParameters: {'id_item': widget.productId},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        print("Data fetched: $data"); // Debugging

setState(() {
  _controllers['nama_item']!.text = data['nama_item'] ?? '';
  _controllers['deskripsi']!.text = data['deskripsi'] ?? '';
  _controllers['lokasi']!.text = data['lokasi'] ?? '';
  _controllers['harga']!.text = data['harga']?.toString() ?? '';
  _controllers['sisa_slot']!.text = data['sisa_slot']?.toString() ?? '';  // Pastikan diubah menjadi string
  imageUrl = data['gambar'] ?? '';
});

      } else {
        throw Exception(
            'Failed to fetch product data. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Error fetching product: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching product: ${e.message}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Fungsi untuk memperbarui data produk
  Future<void> updateProduct(
    String namaProduk,
    String deskripsi,
    String lokasi,
    String harga,
    String sisaSlot,
  ) async {
    try {
      setState(() => _isLoading = true);
      var dio = Dio();
var formData = FormData.fromMap({
  'id_item': widget.productId,
  'nama_item': namaProduk,
  'deskripsi': deskripsi,
  'lokasi': lokasi,
  'harga': harga,
  'sisa_slot': int.tryParse(sisaSlot) ?? 0, // Mengonversi string menjadi integer
  'gambar': imageUrl,
});


      final response = await dio.put(
        updateApiUrl,
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Product updated successfully: ${response.data}');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Sukses"),
              content: Text(response.data['message']),
              actions: <Widget>[
                TextButton(
                  child: const Text("Kembali ke Halaman Utama"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MainScreens()),
                      (route) => false,
                    );
                  },
                ),
              ],
            );
          },
        );
      } else {
        throw Exception(
            "Failed to update product. Status code: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error updating product: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal memperbarui produk."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool isInputValid() {
    return _formKey.currentState!.validate() &&
        imageUrl != null &&
        imageUrl!.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    fetchProductData();
  }

  InputDecoration buildInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      filled: true,
      fillColor: Colors.grey[200],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Produk'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _controllers['nama_item'],
                decoration: buildInputDecoration('Nama Item'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _controllers['deskripsi'],
                decoration: buildInputDecoration('Deskripsi'),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _controllers['lokasi'],
                decoration: buildInputDecoration('Lokasi'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _controllers['harga'],
                decoration: buildInputDecoration('Harga (Rp)'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _controllers['sisa_slot'],
                decoration: buildInputDecoration('Sisa Slot'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: imageUrl,
                decoration: buildInputDecoration('Image URL'),
                keyboardType: TextInputType.url,
                onChanged: (value) => setState(() => imageUrl = value),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              if (imageUrl != null && imageUrl!.isNotEmpty)
                Image.network(imageUrl!, height: 200, fit: BoxFit.cover),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () {
                        if (isInputValid()) {
                          updateProduct(
                            _controllers['nama_item']!.text,
                            _controllers['deskripsi']!.text,
                            _controllers['lokasi']!.text,
                            _controllers['harga']!.text,
                            _controllers['sisa_slot']!.text,
                          );
                        }
                      },
                      child: const Text('Edit Produk'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
