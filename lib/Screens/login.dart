import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hash_mufattish/LanguageTranslate/app_localizations.dart';
import 'package:hash_mufattish/Providers/local_Provider.dart';
import 'package:hash_mufattish/Screens/HomeScreen.dart';
import 'package:hash_mufattish/Screens/internet_error_popup.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  Future<void> login() async {
    try {
      if (email.text == "") {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Email Field is required")));
      } else if (password.text == "") {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Password Field is required")));
      } else {
        final response = await http
            .post(Uri.parse('https://inspectoshield.com/api/login'), body: {
          "email": email.text,
          "password": password.text,
        });
        Map<dynamic, dynamic> jsonResponse = jsonDecode(response.body);
        print(jsonResponse);
        if (jsonResponse["success"] == true) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  "${AppLocalizations.of(context)!.translate("Welcome")} ${jsonResponse["user"]["fullname"]}")));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => NetworkWrapper(
                child: HomeScreen(
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
            ),
          );
        } else if (jsonResponse["success"] == false) {
          if (jsonResponse["message"] is String) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(jsonResponse["message"])));
          } else if (jsonResponse["message"]["email"] != null) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(jsonResponse["message"]["email"][0])));
          } else if (jsonResponse["message"]["password"] != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(jsonResponse["message"]["password"][0])));
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/HASH MUFATTISH.png",
            scale: 4,
          ),
          Text(
            AppLocalizations.of(context)!.translate('Sign In'),
            style: TextStyle(fontSize: 25),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 56,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(6),
              ),
              child: TextField(
                controller: email,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: AppLocalizations.of(context)!.translate('Email')),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 56,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(6),
              ),
              child: TextField(
                obscureText: true,
                controller: password,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText:
                        AppLocalizations.of(context)!.translate('Password')),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: NetworkWrapper(
              child: ArgonButton(
                width: MediaQuery.of(context).size.width,
                height: 50,
                borderRadius: 10.0,
                elevation: 10,
                color: Colors.black,
                borderSide: BorderSide(color: Colors.blue),
                child: Text(
                  AppLocalizations.of(context)!.translate('SIGN IN'),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                ),
                // loader: Container(
                //   padding: EdgeInsets.all(10),
                //   child: SpinKitRotatingCircle(
                //     color: tWhite,
                //     // size: loaderWidth ,
                //   ),
                // ),
                onTap: (startLoading, stopLoading, btnState) {
                  login();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
