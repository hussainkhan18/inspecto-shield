import 'package:flutter/material.dart';
import 'package:hash_mufattish/Screens/internet_error_popup.dart';
import 'package:hash_mufattish/Screens/login.dart';
import 'package:hash_mufattish/Screens/HomeScreen.dart';
import 'package:hash_mufattish/services/secure_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    // Brief splash delay
    await Future.delayed(const Duration(seconds: 5));

    // FIXED: Read auth token from SecureStorage (encrypted)
    // Non-sensitive display data still read from SharedPreferences
    final String? token = await SecureStorageService.getToken();
    final bool isLoggedIn = await SecureStorageService.isLoggedIn();

    if (!mounted) return;

    if (token != null && token.isNotEmpty && isLoggedIn) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final int? id = prefs.getInt('id');
      final String name = prefs.getString('name') ?? '';
      final String email = prefs.getString('email') ?? '';
      final String image = prefs.getString('image') ?? '';
      final String contact = prefs.getString('contact') ?? '';
      final String company = prefs.getString('company') ?? '';
      final String branch = prefs.getString('branch') ?? '';

      // Ensure we have a valid user ID before auto-login
      if (id != null && id > 0) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => NetworkWrapper(
              child: HomeScreen(
                id: id,
                name: name,
                company: company,
                branch: branch,
                email: email,
                // FIXED: password field removed — no longer passed anywhere
                image: image,
                contact: contact,
              ),
            ),
          ),
        );
        return;
      }
    }

    // No valid session → go to login
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => NetworkWrapper(child: const LoginScreen()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Image.asset(
          "assets/Splash.gif",
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
