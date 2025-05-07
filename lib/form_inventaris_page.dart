import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:signature/signature.dart';

class FormInventarisPage extends StatefulWidget {
  const FormInventarisPage({super.key});

  @override
  State<FormInventarisPage> createState() => _FormInventarisPageState();
}

class _FormInventarisPageState extends State<FormInventarisPage> {
  final _formKey = GlobalKey<FormState>();
  String nama = '', nim = '', kelas = '';
  List<Map<String, dynamic>> barangList = [];
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  // Fungsi untuk menambahkan barang kosong
  void tambahBarangKosong() {
    setState(() {
      barangList.add({
        'nama': '',
        'kode': '',
        'stok': 0,
        'kondisi': '',
        'keterangan': '',
      });
    });
  }

  // Fungsi untuk menghapus barang dari daftar
  void hapusBarang(int index) {
    setState(() {
      barangList.removeAt(index);
    });
  }

  // Fungsi untuk mendapatkan tanda tangan dalam format base64
  Future<String?> getSignatureBase64() async {
    if (_signatureController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanda tangan wajib diisi')),
      );
      return null;
    }
    final image = await _signatureController.toPngBytes();
    if (image == null) return null;
    return base64Encode(image);
  }

  // Fungsi untuk menyimpan inventaris ke API
  Future<void> submitInventaris() async {
    if (!_formKey.currentState!.validate()) return;
    if (barangList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan minimal 1 barang')),
      );
      return;
    }

    final tandaTangan = await getSignatureBase64();
    if (tandaTangan == null) return;

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/inventaris'), // Ganti URL API
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nama': nama,
          'nim': nim,
          'kelas': kelas,
          'daftar_barang': barangList,
          'tanda_tangan': tandaTangan,
        }),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inventaris berhasil dicatat')),
        );

        // Ganti Navigator.pop dengan dialog untuk feedback sementara
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Success'),
            content: Text('Inventaris berhasil dicatat'),
            actions: [
              TextButton(
                onPressed: () {
                  // Kosongkan form dan reset data
                  setState(() {
                    nama = '';
                    nim = '';
                    kelas = '';
                    barangList.clear();
                    _signatureController.clear();
                  });
                  Navigator.of(context).pop(); // Menutup dialog
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan inventaris')),
        );
      }
    } catch (e) {
      print('Error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan. Silakan coba lagi.')),
      );
    }
  }

  // Fungsi untuk mengekspor inventaris ke PDF
  Future<void> exportInventarisToPDF() async {
    final tandaTanganBase64 = await getSignatureBase64();
    if (tandaTanganBase64 == null || tandaTanganBase64.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanda tangan tidak tersedia')),
      );
      return;
    }

    // Anda dapat menambahkan kode untuk export ke PDF di sini
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Inventaris'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Input untuk Nama
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  prefixIcon: Icon(Icons.person),
                ),
                onChanged: (val) => nama = val,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 10),

              // Input untuk NIM
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'NIM',
                  prefixIcon: Icon(Icons.badge),
                ),
                onChanged: (val) => nim = val,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 10),

              // Input untuk Kelas
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Kelas',
                  prefixIcon: Icon(Icons.class_),
                ),
                onChanged: (val) => kelas = val,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Daftar Barang
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: barangList.length,
                itemBuilder: (context, index) {
                  final barang = barangList[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          // Input Nama Barang
                          TextFormField(
                            decoration: const InputDecoration(labelText: 'Nama Barang'),
                            onChanged: (val) => barang['nama'] = val,
                            validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                          ),
                          // Input Kode Barang
                          TextFormField(
                            decoration: const InputDecoration(labelText: 'Kode'),
                            onChanged: (val) => barang['kode'] = val,
                          ),
                          // Input Stok Barang
                          TextFormField(
                            decoration: const InputDecoration(labelText: 'Stok'),
                            keyboardType: TextInputType.number,
                            onChanged: (val) => barang['stok'] = int.tryParse(val) ?? 0,
                          ),
                          // Input Kondisi Barang
                          TextFormField(
                            decoration: const InputDecoration(labelText: 'Kondisi'),
                            onChanged: (val) => barang['kondisi'] = val,
                          ),
                          // Input Keterangan Barang
                          TextFormField(
                            decoration: const InputDecoration(labelText: 'Keterangan'),
                            onChanged: (val) => barang['keterangan'] = val,
                          ),
                          // Tombol Hapus Barang
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => hapusBarang(index),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              // Tombol Tambah Barang
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Tambah Barang'),
                onPressed: tambahBarangKosong,
              ),
              const SizedBox(height: 20),

              // Tanda Tangan
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Tanda Tangan:', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                height: 200,
                child: Signature(
                  controller: _signatureController,
                  backgroundColor: Colors.white,
                ),
              ),
              // Tombol Hapus Tanda Tangan
              TextButton.icon(
                icon: const Icon(Icons.clear),
                label: const Text('Hapus Tanda Tangan'),
                onPressed: () => _signatureController.clear(),
              ),
              const SizedBox(height: 20),

              // Tombol Simpan Inventaris
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Simpan Inventaris'),
                onPressed: submitInventaris,
              ),
              const SizedBox(height: 10),

              // Tombol Export ke PDF
              ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Export ke PDF'),
                onPressed: exportInventarisToPDF,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
