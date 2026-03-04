import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hash_mufattish/LanguageTranslate/app_localizations.dart';
import 'package:hash_mufattish/Screens/HomeScreen.dart';
import 'package:hash_mufattish/services/secure_storage_service.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:hash_mufattish/services/notification_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  // ── Save user session ──────────────────────────────────────────────────────
  // FIXED: Raw password is NEVER saved. Token goes to SecureStorage.
  // Non-sensitive display data (name, company, etc.) stays in SharedPreferences.
  Future<void> _saveUserSession(Map jsonResponse) async {
    // 1. Sensitive: token → encrypted secure storage
    await SecureStorageService.saveToken(jsonResponse["access_token"]);
    await SecureStorageService.setLoggedIn(true);

    // 2. Non-sensitive display data → SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("id", jsonResponse["user"]["id"]);
    await prefs.setString("name", jsonResponse["user"]["fullname"]);
    await prefs.setString("email", jsonResponse["user"]["email"]);
    await prefs.setString("image", jsonResponse["user"]["profile_img"]);
    await prefs.setString("contact", jsonResponse["user"]["contact_number"]);
    await prefs.setString("company", jsonResponse["user"]["company_name"]);
    await prefs.setString("branch", jsonResponse["user"]["branch_name"]);

    print("User session saved securely.");
  }

  // ── Login API call ─────────────────────────────────────────────────────────
  Future<void> login() async {
    if (email.text.trim().isEmpty) {
      _showSnack(AppLocalizations.of(context)!.translate("Email required"));
      return;
    }
    if (password.text.trim().isEmpty) {
      _showSnack(AppLocalizations.of(context)!.translate("Password required"));
      return;
    }

    try {
      final String? fcmToken = await NotificationService().getToken();

      final response = await http.post(
        Uri.parse('https://inspectoshield.com/api/login'),
        body: {
          "email": email.text.trim(),
          "password": password.text,
          if (fcmToken != null) "fcm_token": fcmToken,
        },
      );

      if (response.body.isEmpty) {
        _showSnack("Server returned an empty response");
        return;
      }

      Map jsonResponse;
      try {
        jsonResponse = jsonDecode(response.body);
      } catch (e) {
        _showSnack("Invalid response from server");
        return;
      }

      if (response.statusCode != 200) {
        _showSnack("Server error: ${response.statusCode}");
        return;
      }

      if (jsonResponse["success"] == true) {
        await _saveUserSession(jsonResponse);

        if (!mounted) return;

        _showSnack(
          "${AppLocalizations.of(context)!.translate("Welcome")} "
          "${jsonResponse["user"]["fullname"]}",
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              id: jsonResponse["user"]["id"],
              name: jsonResponse["user"]["fullname"],
              company: jsonResponse["user"]["company_name"],
              branch: jsonResponse["user"]["branch_name"],
              email: jsonResponse["user"]["email"],
              image: jsonResponse["user"]["profile_img"],
              contact: jsonResponse["user"]["contact_number"],
            ),
          ),
        );
      } else {
        _handleApiError(jsonResponse["message"]);
      }
    } catch (e) {
      print("Login error: $e");
      _showSnack("Connection error. Please try again.");
    }
  }

  void _handleApiError(dynamic message) {
    if (message is String) {
      _showSnack(message);
    } else if (message is Map) {
      if (message["email"] != null) {
        _showSnack(message["email"][0]);
      } else if (message["password"] != null) {
        _showSnack(message["password"][0]);
      }
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ── UI ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/HASH MUFATTISH.png", scale: 4),
          Text(
            AppLocalizations.of(context)!.translate('Sign In'),
            style: const TextStyle(fontSize: 25),
          ),
          const SizedBox(height: 20),
          _inputBox(
            controller: email,
            hint: AppLocalizations.of(context)!.translate('Email'),
          ),
          _inputBox(
            controller: password,
            isPassword: true,
            hint: AppLocalizations.of(context)!.translate('Password'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ArgonButton(
              width: MediaQuery.of(context).size.width,
              height: 50,
              borderRadius: 10.0,
              elevation: 10,
              color: Colors.black,
              borderSide: const BorderSide(color: Colors.blue),
              child: Text(
                AppLocalizations.of(context)!.translate('SIGN IN'),
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
              onTap: (startLoading, stopLoading, btnState) async {
                startLoading();
                await login();
                stopLoading();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputBox({
    required TextEditingController controller,
    bool isPassword = false,
    required String hint,
  }) =>
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(6),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            decoration:
                InputDecoration(border: InputBorder.none, hintText: hint),
          ),
        ),
      );

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }
}
