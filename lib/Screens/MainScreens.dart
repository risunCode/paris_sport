import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Login.dart'; // Mengimpor halaman Login 
import 'ProductListScreen.dart'; // Import ProductListScreen

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

class MainScreens extends StatefulWidget {
  const MainScreens({Key? key}) : super(key: key);

  @override
  State<MainScreens> createState() => _MainScreensState();
}

class _MainScreensState extends State<MainScreens> {
  int _selectedIndex = 1; // Default ke Home (index 1)
  late List<Product> products = []; // Variabel untuk menyimpan data produk

  // Fungsi untuk mengambil data produk dari API
  void fetchProducts() async {
    final response = await http.get(Uri.parse('https://classic-duly-goat.ngrok-free.app/lapangan_apiku/api/GET_Product'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      setState(() {
        products = jsonResponse.map((product) => Product.fromJson(product)).toList();
      });
    } else {
      throw Exception('Failed to load products');
    }
  }
void _onItemTapped(int index) {
  setState(() {
    if (index == 2) { // Change to 2, as 'Product List' is at index 2
      // Navigate to ProductListScreen when index 2 is tapped
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProductListScreen()),
      );
    } else {
      _selectedIndex = index;
    }
  });
}


  @override
  void initState() {
    super.initState();
    fetchProducts(); // Memanggil fungsi fetchProducts saat widget diinisialisasi
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Set background color to grey
      appBar: AppBar(
        backgroundColor: Colors.green[900], // Set AppBar background color to dark green
        title: const Center(
          child: Text(
            'Paris Sport',
            style: TextStyle(
              color: Colors.white, // Set text color to white
              fontWeight: FontWeight.bold, // Make text bold
            ),
          ),
        ),
        automaticallyImplyLeading: false, // Remove back button from AppBar
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Widget untuk halaman Info
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 100,
                  color: Colors.grey,
                ),
                SizedBox(height: 20),
                Text(
                  'Info',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Aplikasi ini dibuat untuk memenuhi tugas UAS Teknologi Web Services',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          // Widget untuk halaman Home
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(), // Bouncing physics for smooth scrolling
            child: Column(
              children: [
                SizedBox(height: 20), // Jarak antara AppBar dan Card
                // Card lonjong dengan gambar dan salam
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Membuat card lonjong
                  ),
                  elevation: 5,
                  color: Colors.green[200],
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Gambar kustom di atas teks
                        Image.asset(
                          'assets/img/pemain.jpg', // Ganti dengan path gambar Anda
                          fit: BoxFit.cover, // Sesuaikan gambar
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.waving_hand, size: 40, color: Colors.green[900]),
                            SizedBox(width: 10),
                            Text(
                              'Selamat Datang di Paris Sport!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[900],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Menampilkan produk yang diambil dari API
                products.isEmpty
                    ? Center(child: CircularProgressIndicator()) // Tampilkan loading saat data belum diambil
                    : ListView.builder(
                        physics: const NeverScrollableScrollPhysics(), // Disable inner scrolling
                        shrinkWrap: true, // Menambahkan shrinkWrap agar ListView tidak mengambil seluruh ruang
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                            child: ListTile(
                              leading: Image.network(product.gambar, fit: BoxFit.cover),
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
                          );
                        },
                      ),
              ],
            ),
          ),
          // Widget untuk halaman Logout (bisa dikosongkan karena logout ditangani di _onItemTapped)
          Container(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aksi Logout
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Konfirmasi Logout'),
                content: const Text('Apakah Anda yakin ingin keluar?'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Tidak'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  TextButton(
                    child: const Text('Ya'),
                    onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const Login())),
                  ),
                ],
              );
            },
          );
        },
        backgroundColor: Colors.red, // Warna untuk logout
        child: const Icon(Icons.exit_to_app, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Mengatur posisi tombol di kanan bawah
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Info',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          // Menghapus item Logout di BottomNavigationBar
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Product List', // New tab for Product List
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey, // Warna item tidak terpilih
        backgroundColor: const Color.fromARGB(255, 29, 24, 24), // Warna latar belakang navbar
        onTap: _onItemTapped,
        selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold), // Style teks item terpilih
        type: BottomNavigationBarType.fixed, // Tipe fixed untuk menghindari pergeseran ikon
        showUnselectedLabels: true, // Menampilkan label item tidak terpilih
      ),
    );
  }
}
