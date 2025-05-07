import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class InventarisHistoryPage extends StatelessWidget {
  InventarisHistoryPage({super.key});

  // Contoh data dummy, nanti bisa diganti dengan data dari API
  final List<Map<String, dynamic>> riwayatInventaris = [
    {
      'oleh': 'Dian',
      'waktu': '2025-04-21 10:00',
      'hasil': 'Semua barang lengkap & sesuai.'
    },
    {
      'oleh': 'Rizky',
      'waktu': '2025-04-20 14:45',
      'hasil': 'Ada 2 barang hilang: obeng & kabel HDMI.'
    },
  ];

  // Fungsi untuk menghasilkan PDF
  Future<void> exportToPdf() async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Text('Riwayat Inventaris', style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
            ...riwayatInventaris.map((item) {
              return pw.Column(
                children: [
                  pw.Text('Oleh: ${item['oleh']}'),
                  pw.Text('Waktu: ${item['waktu']}'),
                  pw.Text('Hasil: ${item['hasil']}'),
                  pw.Divider(),
                ],
              );
            }).toList(),
          ],
        );
      },
    ));

    // Menyimpan atau mencetak PDF
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Inventaris'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: exportToPdf,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: riwayatInventaris.length,
        itemBuilder: (context, index) {
          final item = riwayatInventaris[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text('Oleh: ${item['oleh']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Waktu: ${item['waktu']}'),
                  const SizedBox(height: 4),
                  Text('Hasil: ${item['hasil']}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
