import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hash_mufattish/LanguageTranslate/app_localizations.dart';
import 'package:hash_mufattish/Providers/checklist_Provider.dart';
import 'package:hash_mufattish/Providers/local_Provider.dart';
import 'package:hash_mufattish/Screens/view_certificate.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
class EquipementInfo extends StatefulWidget {
  Map data;

  EquipementInfo({super.key, required this.data});

  @override
  State<EquipementInfo> createState() => _EquipementInfoState();
}

class _EquipementInfoState extends State<EquipementInfo> {
  String certificateImgUrl = "";
  bool _isLoading = true;

  Future<Map<String, dynamic>?> fetchEquipmentData(String reportId) async {
    final response = await http.get(
      Uri.parse(
        'https://inspectoshield.com/api/generate/$reportId',
      ),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)["data"];
    } else {
      throw Exception('Failed to load equipment data');
    }
  }

  Map<String, dynamic>? _equipmentData;

  Future<void> _fetchEquipmentData() async {
    try {
      final data = await fetchEquipmentData(widget.data["report_id"].toString());
      setState(() {
        _equipmentData = data;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching equipment data: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    getCertificateData();
    _fetchEquipmentData();
  }

  Future<void> getCertificateData() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://inspectoshield.com/api/certificate/${widget.data["report_id"].toString()}'),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        String certificateImage = jsonResponse["data"]["certificate_img"];
        setState(() {
          certificateImgUrl = certificateImage;
        });
      } else {
        print("Failed to load certificate data");
      }
    } catch (e) {
      print({"error": e.toString()});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
//                 Container(
//                   height: MediaQuery.of(context).size.height / 5,
//                   alignment: Alignment.center,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
                    
//                     children: [
//                       Image.network(
//                         _equipmentData?["equipment_img"] ??
//                             "https://hashbaqala.bssstageserverforpanels.xyz/upload/profileImage/user.png",
//                         // scale: 7,
//                                   fit: BoxFit.contain, // optional: ensures it fits well
// ),
//                       ArgonButton(
//                         width: 180,
//                         height: 50,
//                         borderRadius: 8.0,
//                         elevation: 10,
//                         color: const Color(0xff0DC5B9),
//                         child: Text(
//                           AppLocalizations.of(context)!
//                               .translate("View Certificate"),
//                           style: const TextStyle(color: Colors.white, fontSize: 15),
//                         ),
//                         onTap: (startLoading, stopLoading, btnState) {
//                           startLoading();
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => FullScreenImageView(
//                                 imageUrl: certificateImgUrl ??
//                                     "https://hashbaqala.bssstageserverforpanels.xyz/upload/profileImage/user.png",
//                               ),
//                             ),
//                           ).then((_) {
//                             stopLoading();
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
Container(
  height: MediaQuery.of(context).size.height / 3.5,
  alignment: Alignment.center,
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Image.network(
        _equipmentData?["equipment_img"] ??
            "https://hashbaqala.bssstageserverforpanels.xyz/upload/profileImage/user.png",
        fit: BoxFit.contain,
        height: MediaQuery.of(context).size.height / 6,
      ),
      const SizedBox(height: 16),
      ArgonButton(
        width: 180,
        height: 50,
        borderRadius: 8.0,
        elevation: 10,
        color: const Color(0xff0DC5B9),
        child: Text(
          AppLocalizations.of(context)!.translate("View Certificate"),
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
        onTap: (startLoading, stopLoading, btnState) {
          startLoading();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullScreenImageView(
                imageUrl: certificateImgUrl ??
                    "https://hashbaqala.bssstageserverforpanels.xyz/upload/profileImage/user.png",
              ),
            ),
          ).then((_) {
            stopLoading();
          });
        },
      ),
    ],
  ),
),

                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  height: MediaQuery.of(context).size.height / 1.7,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDataRow(context, label: "EQUIPMENT NAME: ", value: _equipmentData?["equipment_name"]),
                      _buildDataRow(context, label: "LOCATION DESCRIPTION: ", value: _equipmentData?["location_description"]),
                      _buildDataRow(context, label: "EQUIPMENT CATEGORY: ", value: _equipmentData?["equipment_sub_category"]),
                      _buildDataRow(context, label: "EQUIPMENT TYPE: ", value: _equipmentData?["equipment_type"]),
                      _buildDataRow(context, label: "EQUIPMENT FAMILY: ", value: _equipmentData?["equipment_category"]),
                      _buildDataRow(context, label: "LAST INSPECTION DATE: ", value: "Not Available"),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDataRow(BuildContext context, {required String label, String? value}) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width / 2,
                child: Text(
                  AppLocalizations.of(context)!.translate(label),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.only(left: 20),
                width: MediaQuery.of(context).size.width / 2,
                child: Text(
                  value ?? AppLocalizations.of(context)!.translate("No data"),
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),
          ],
        ),
        Divider(),
      ],
    );
  }
}
