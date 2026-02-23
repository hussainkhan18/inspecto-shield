import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hash_mufattish/LanguageTranslate/app_localizations.dart';
import 'package:hash_mufattish/Screens/HomeScreen.dart';
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
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  /*=========================================================
      SAVE TOKEN + USER DETAILS LOCALLY
  ==========================================================*/
  Future<void> saveUserLogin(Map jsonResponse) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", jsonResponse["access_token"]);
    await prefs.setInt("id", jsonResponse["user"]["id"]);
    await prefs.setString("name", jsonResponse["user"]["fullname"]);
    await prefs.setString("email", jsonResponse["user"]["email"]);
    await prefs.setString("password", password.text);
    await prefs.setString("image", jsonResponse["user"]["profile_img"]);
    await prefs.setString("contact", jsonResponse["user"]["contact_number"]);
    await prefs.setString("company", jsonResponse["user"]["company_name"]);
    await prefs.setString("branch", jsonResponse["user"]["branch_name"]);

    await prefs.setBool("isLoggedIn", true); // for auto-login
    print("USER LOGIN SAVED SUCCESSFULLY");
  }

  /*=========================================================
      LOGIN API
  ==========================================================*/
  Future<ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?>
      login() async {
    try {
      if (email.text.trim().isEmpty) {
        return ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Email required")));
      }
      if (password.text.trim().isEmpty) {
        return ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Password required")));
      }

      String? fcmToken = await NotificationService().getToken();

      final response = await http.post(
        Uri.parse('https://inspectoshield.com/api/login'),
        body: {
          "email": email.text,
          "password": password.text,
          if (fcmToken != null) "fcm_token": fcmToken,
        },
      );

      // Check if response body is empty
      if (response.body.isEmpty) {
        return ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Server returned an empty response")),
        );
      }

      Map jsonResponse;
      try {
        jsonResponse = jsonDecode(response.body);
      } catch (e) {
        print("JSON Parse Error: $e");
        return ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid response from server: $e")),
        );
      }

      print("Response status: ${response.statusCode}");
      print(jsonResponse);

      // Check HTTP status code
      if (response.statusCode != 200) {
        print("HTTP Error: ${response.statusCode}");
        return ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error: ${response.statusCode}")),
        );
      }

      if (jsonResponse["success"] == true) {
        /// >>>>>>> SAVE TOKEN HERE <<<<<<<<
        await saveUserLogin(jsonResponse);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "${AppLocalizations.of(context)!.translate("Welcome")} ${jsonResponse["user"]["fullname"]}")),
        );

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                id: jsonResponse["user"]["id"],
                name: jsonResponse["user"]["fullname"],
                company: jsonResponse["user"]["company_name"],
                branch: jsonResponse["user"]["branch_name"],
                email: jsonResponse["user"]["email"],
                password: password.text,
                image: jsonResponse["user"]["profile_img"],
                contact: jsonResponse["user"]["contact_number"],
              ),
            ),
          );
        }
      } else {
        /// API ERROR HANDLING
        if (jsonResponse["message"] is String) {
          return ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(jsonResponse["message"])));
        } else {
          if (jsonResponse["message"]["email"] != null) {
            return ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(jsonResponse["message"]["email"][0])));
          }
          if (jsonResponse["message"]["password"] != null) {
            return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(jsonResponse["message"]["password"][0])));
          }
        }
      }
      return null;
    } catch (e) {
      print("Login Error: $e");
      return ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Connection error: $e")));
    }
  }

  /*=========================================================
      UI
  ==========================================================*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/HASH MUFATTISH.png", scale: 4),
          Text(AppLocalizations.of(context)!.translate('Sign In'),
              style: const TextStyle(fontSize: 25)),

          const SizedBox(height: 20),

          /// EMAIL FIELD
          inputBox(
              controller: email,
              hint: AppLocalizations.of(context)!.translate('Email')),

          /// PASSWORD FIELD
          inputBox(
              controller: password,
              isPassword: true,
              hint: AppLocalizations.of(context)!.translate('Password')),

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
              onTap: (startLoading, stopLoading, btnState) => login(),
            ),
          ),
        ],
      ),
    );
  }

  /*======================== Widgets ===========================*/
  Widget inputBox(
          {required TextEditingController controller,
          bool isPassword = false,
          required String hint}) =>
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
}
