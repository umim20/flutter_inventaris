import 'package:flutter/material.dart';
import 'splash_screen.dart'; // Pastikan file ini ada di lib/
import 'tutorial_page.dart'; // Import halaman tutorial
import 'login_page.dart'; // Import halaman login
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peminjaman Alat',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // panggil halaman splash screen
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _navigateToNextPage();
  }

  // Fungsi untuk menavigasi ke halaman berikutnya setelah splash screen
  Future<void> _navigateToNextPage() async {
    await Future.delayed(const Duration(seconds: 3)); // Tampilkan splash selama 3 detik

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isTutorialSeen = prefs.getBool('isTutorialSeen') ?? false;

    if (isTutorialSeen) {
      // Jika tutorial sudah dilihat, navigasi ke halaman Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      // Jika tutorial belum dilihat, navigasi ke halaman Tutorial
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TutorialPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            // Logo atau konten splash lainnya
            Icon(Icons.app_registration, size: 100, color: Colors.teal),
            SizedBox(height: 20),
            Text(
              'TOOLMATE',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
