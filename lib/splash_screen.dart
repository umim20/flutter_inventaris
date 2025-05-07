import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'tutorial_page.dart';

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
    // Memberikan waktu delay selama 3 detik agar splash screen muncul
    await Future.delayed(const Duration(seconds: 3));

    // Mengambil SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isTutorialSeen = prefs.getBool('isTutorialSeen') ?? false;

    // Cek apakah tutorial sudah dilihat atau belum
    if (isTutorialSeen) {
      // Jika tutorial sudah dilihat, arahkan ke halaman Login
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } else {
      // Jika tutorial belum dilihat, arahkan ke halaman Tutorial
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TutorialPage()),
        );
      }
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
            // Logo atau ikon di Splash Screen
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
