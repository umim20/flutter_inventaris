import 'package:pdf/pdf.dart'; // Tambahkan ini
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class FormInventarisPage extends StatefulWidget {
  const FormInventarisPage({super.key});

  @override
  State<FormInventarisPage> createState() => _FormInventarisPageState();
}

class _FormInventarisPageState extends State<FormInventarisPage> {
  final _formKey = GlobalKey<FormState>();
  String nama = '', nim = '', kelas = '';
  List<Map<String, dynamic>> barangList = [];

  void tambahBarangKosong() {
    setState(() {
      barangList.add({'nama': '', 'kode': '', 'stok': 0, 'kondisi': ''});
    });
  }

  void hapusBarang(int index) {
    setState(() {
      barangList.removeAt(index);
    });
  }

  Future<void> submitInventaris() async {
    if (!_formKey.currentState!.validate()) return;
    if (barangList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan minimal 1 barang')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/inventaris'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nama': nama,
        'nim': nim,
        'kelas': kelas,
        'daftar_barang': barangList,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inventaris berhasil dicatat')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan inventaris')),
      );
    }
  }

  Future<void> exportInventarisToPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text('Laporan Inventaris Alat',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text('Nama: $nama'),
          pw.Text('NIM: $nim'),
          pw.Text('Kelas: $kelas'),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ['No', 'Nama Barang', 'Kode', 'Stok', 'Kondisi'],
            data: List.generate(
              barangList.length,
                  (index) {
                final barang = barangList[index];
                return [
                  '${index + 1}',
                  barang['nama'] ?? '',
                  barang['kode'] ?? '',
                  barang['stok'].toString(),
                  barang['kondisi'] ?? '',
                ];
              },
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  void initState() {
    super.initState();
    tambahBarangKosong();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Inventaris')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nama'),
                onChanged: (val) => nama = val,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'NIM'),
                onChanged: (val) => nim = val,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Kelas'),
                onChanged: (val) => kelas = val,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
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
                          TextFormField(
                            decoration: const InputDecoration(labelText: 'Nama Barang'),
                            onChanged: (val) => barang['nama'] = val,
                            validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(labelText: 'Kode'),
                            onChanged: (val) => barang['kode'] = val,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(labelText: 'Stok'),
                            keyboardType: TextInputType.number,
                            onChanged: (val) => barang['stok'] = int.tryParse(val) ?? 0,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(labelText: 'Kondisi'),
                            onChanged: (val) => barang['kondisi'] = val,
                          ),
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
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Tambah Barang'),
                onPressed: tambahBarangKosong,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitInventaris,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: const Text('Simpan Inventaris'),
              ),
              const SizedBox(height: 10),
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
