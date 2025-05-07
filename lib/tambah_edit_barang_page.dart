import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TambahEditBarangPage extends StatefulWidget {
  final Map<String, dynamic>? barang;

  const TambahEditBarangPage({super.key, this.barang});

  @override
  State<TambahEditBarangPage> createState() => _TambahEditBarangPageState();
}

class _TambahEditBarangPageState extends State<TambahEditBarangPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController kodeController = TextEditingController();
  final TextEditingController stokController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.barang != null) {
      namaController.text = widget.barang!['nama'] ?? '';
      kodeController.text = widget.barang!['kode'] ?? '';
      stokController.text = widget.barang!['stok']?.toString() ?? '0';
      deskripsiController.text = widget.barang!['deskripsi'] ?? '';
    }
  }

  Future<void> simpanBarang() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    final url = widget.barang == null
        ? 'http://127.0.0.1:8000/api/barangs'
        : 'http://127.0.0.1:8000/api/barangs/${widget.barang!['id']}';

    final method = widget.barang == null ? http.post : http.put;

    final response = await method(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nama': namaController.text,
        'kode': kodeController.text,
        'stok': int.tryParse(stokController.text) ?? 0,
        'deskripsi': deskripsiController.text,
      }),
    );

    setState(() => isSaving = false);

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan barang')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.barang != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Barang' : 'Tambah Barang'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(labelText: 'Nama Barang'),
                validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: kodeController,
                decoration: const InputDecoration(labelText: 'Kode Barang'),
                validator: (value) => value!.isEmpty ? 'Kode tidak boleh kosong' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: stokController,
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                (int.tryParse(value ?? '') == null) ? 'Masukkan angka yang valid' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: deskripsiController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: isSaving ? null : simpanBarang,
                icon: isSaving
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Icon(Icons.save),
                label: Text(isEdit ? 'Update' : 'Simpan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
