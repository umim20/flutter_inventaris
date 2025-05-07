import 'package:flutter/material.dart';

class InventarisProvider extends ChangeNotifier {
  // Daftar barang yang akan disimpan
  List<Map<String, dynamic>> barangList = [];

  // Menambahkan barang ke daftar
  void addBarang(Map<String, dynamic> barang) {
    barangList.add(barang);
    notifyListeners();
  }

  // Menghapus barang berdasarkan index
  void removeBarang(int index) {
    barangList.removeAt(index);
    notifyListeners();
  }

  // Menyimpan daftar barang
  void setBarangList(List<Map<String, dynamic>> newBarangList) {
    barangList = newBarangList;
    notifyListeners();
  }
}
