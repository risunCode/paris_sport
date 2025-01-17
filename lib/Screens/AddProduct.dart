import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:paris_sport/Screens/MainScreens.dart'; // Import MainScreens

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final String baseurl =
      "https://classic-duly-goat.ngrok-free.app/lapangan_apiku"; // Replace with your backend URL

  final _formKey = GlobalKey<FormState>();

  // Using a map to store the controllers for easier access
  final Map<String, TextEditingController> _controllers = {
    'nama_item': TextEditingController(),
    'deskripsi': TextEditingController(),
    'lokasi': TextEditingController(),
    'harga': TextEditingController(), // Use TextEditingController for harga
    'sisa_slot': TextEditingController(),
  };
  String? imageUrl; // For storing the image URL
  bool _isLoading = false; // For loading state
  int _retryCount = 0; // Counter for retry attempts

  Future<void> createProduct(
    String namaProduk,
    String deskripsi,
    String lokasi,
    String harga, // String
    String sisaSlot, // String
  ) async {
    try {
      setState(() {
        _isLoading = true; // Show loading indicator
      });
      var dio = Dio();
      var formData = FormData.fromMap({
        'nama_item': namaProduk, // Using the provided arguments directly
        'deskripsi': deskripsi,
        'lokasi': lokasi,
        'harga': harga, //
        'sisa_slot': int.parse(
            sisaSlot), // Assuming sisaSlot is already an integer string
        'gambar': imageUrl, // Using the image URL
      });

      Response? response; // Declare response here and initialize as null

      // Retry logic
      while (_retryCount < 2) {
        try {
          response = await dio.post(
            '$baseurl/api/product/POST_item',
            data: formData,
          );
          break; // Exit loop if successful
          // ignore: unused_catch_clause hehe males kuning kuning kek teleg
        } on DioException catch (e) {
          _retryCount++;
          debugPrint("Retry attempt: $_retryCount");
          await Future.delayed(const Duration(seconds: 1)); // Wait 1 second
          if (_retryCount >= 2) rethrow; // Rethrow if retries exhausted
        }
      }
      _retryCount = 0; // Reset retry count

      // Check if response is not null before accessing properties
      if (response == null) {
        throw Exception("Failed to get response after retries");
      }

      if (response.statusCode == 201) {
        // Data successfully added
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Sukses"),
              content: Text(" ${response?.data['message']}"),
              actions: <Widget>[
                TextButton(
                  child: const Text("Kembali Ke Halaman"),
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
            "Failed to add product. Status code: ${response.statusCode}");
      }
    } on DioException catch (e) {
      // Dio error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Data produk sudah ada"),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint("Dio Error: ${e.response?.data}");
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  void clearForm() {
    _formKey.currentState?.reset();
    for (var controller in _controllers.values) {
      controller.clear();
    }
  }

  bool isInputValid() {
    return _formKey.currentState!.validate() &&
        imageUrl != null &&
        imageUrl!.isNotEmpty; // Check if imageUrl is not empty
  }

  void _setImageUrl(String url) {
    setState(() {
      imageUrl = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Produk',
            style:
                TextStyle(color: Colors.white)), // Set text color to white here
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Nama Item
              TextFormField(
                controller: _controllers['nama_item'],
                decoration: buildInputDecoration('Nama Item'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              // Deskripsi
              TextFormField(
                controller: _controllers['deskripsi'],
                decoration: buildInputDecoration('Deskripsi'),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              // Lokasi
              TextFormField(
                controller: _controllers['lokasi'],
                decoration: buildInputDecoration('Lokasi'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              // Harga
              TextFormField(
                controller: _controllers['harga'],
                decoration: buildInputDecoration('Harga (Rp)'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              // Sisa Slot
              TextFormField(
                controller: _controllers['sisa_slot'],
                decoration: buildInputDecoration('Sisa Slot'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              // Image URL Input
              TextFormField(
                decoration: buildInputDecoration('Image URL'),
                keyboardType: TextInputType.url, // Set keyboard type to URL
                onChanged: (value) => _setImageUrl(value),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 10),
              // Display the image if the URL is not null
              if (imageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: SizedBox(
                    height: 200,
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              // Submit button
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () async {
                        if (isInputValid()) {
                          try {
                            await createProduct(
                              _controllers['nama_item']!.text,
                              _controllers['deskripsi']!.text,
                              _controllers['lokasi']!.text,
                              _controllers['harga']!.text,
                              _controllers['sisa_slot']!.text,
                            );
                          } catch (e) {
                            debugPrint("Error in createProduct: $e");
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: const Text(
                        'Tambah Produk',
                        style: TextStyle(fontSize: 18.0, color: Colors.white),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration buildInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(
          color: Colors.grey,
        ),
      ),
      filled: true,
      fillColor: Colors.grey[200],
    );
  }
}
