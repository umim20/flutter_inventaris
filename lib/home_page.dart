import 'package:flutter/material.dart';
import 'form_inventaris_page.dart';
import 'login_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final String nimUser;

  const HomePage({super.key, required this.nimUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> barangList = [];
  bool isLoading = true;
  int _selectedIndex = 0;

  Color primaryColor = const Color(0xFF00897B); // Warna hijau dari halaman login

  @override
  void initState() {
    super.initState();
    fetchBarang();
  }

  Future<void> fetchBarang() async {
    setState(() => isLoading = true);
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/barangs'));
    if (response.statusCode == 200) {
      setState(() {
        barangList = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      HomePageContent(
        barangList: barangList,
        isLoading: isLoading,
        refreshCallback: fetchBarang,
        primaryColor: primaryColor,
      ),
      const FormInventarisPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventaris Alat'),
        backgroundColor: primaryColor,
        actions: [
          IconButton(onPressed: fetchBarang, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, Colors.green.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: primaryColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_add),
            label: 'Form Inventaris',
          ),
        ],
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  final List<dynamic> barangList;
  final bool isLoading;
  final VoidCallback refreshCallback;
  final Color primaryColor;

  const HomePageContent({
    super.key,
    required this.barangList,
    required this.isLoading,
    required this.refreshCallback,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daftar Barang',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
            child: ListView.builder(
              itemCount: barangList.length,
              itemBuilder: (context, index) {
                final barang = barangList[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: InkWell(
                    onTap: () {
                      // Action when tapping the card (optional)
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            barang['nama'] ?? '',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Divider(color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text(
                            'Kode: ${barang['kode'] ?? '-'}',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Stok: ${barang['stok'] ?? 0}',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Kondisi: ${barang['kondisi'] ?? '-'}',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 8),
                          Divider(color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
