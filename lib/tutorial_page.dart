import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

class TutorialPage extends StatelessWidget {
  const TutorialPage({super.key});

  // Menandai tutorial sebagai sudah dilihat dan navigasi ke halaman login
  Future<void> _skipTutorial(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isTutorialSeen', true); // Set flag bahwa tutorial sudah dilihat

    // Set status pengguna sudah login
    await prefs.setBool('isLoggedIn', false); // Set status login menjadi false sebelum login

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('Tutorial'),
        backgroundColor: Colors.teal[600],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, size: 100, color: Colors.teal),
              const SizedBox(height: 20),
              const Text(
                'Selamat datang di TOOLMATE!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'Aplikasi untuk mengelola dan melacak alat Anda.',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Lanjut ke Aplikasi'),
                onPressed: () => _skipTutorial(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
