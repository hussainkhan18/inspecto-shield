import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hash_mufattish/LanguageTranslate/app_localizations.dart';
import 'package:hash_mufattish/Screens/view_certificate.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
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
  Map<String, dynamic>? _equipmentData;

  Future<Map<String, dynamic>?> fetchEquipmentData(String reportId) async {
    final response = await http.get(
      Uri.parse('https://inspectoshield.com/api/generate/$reportId'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)["data"];
    } else {
      throw Exception('Failed to load equipment data');
    }
  }

  Future<void> _fetchEquipmentData() async {
    try {
      final data =
          await fetchEquipmentData(widget.data["report_id"].toString());
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
      }
    } catch (e) {
      print({"error": e.toString()});
    }
  }

  @override
  void initState() {
    super.initState();
    getCertificateData();
    _fetchEquipmentData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 50),

                  // ─── Image + View Certificate Button ───
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
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
                            AppLocalizations.of(context)!
                                .translate("View Certificate"),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                          ),
                          onTap: (startLoading, stopLoading, btnState) {
                            startLoading();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenImageView(
                                  imageUrl: certificateImgUrl,
                                ),
                              ),
                            ).then((_) => stopLoading());
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ─── Main Info Rows ───
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Column(
                      children: [
                        _buildDataRow(
                          label: "EQUIPMENT NAME:",
                          value: _equipmentData?["equipment_name"],
                        ),
                        _buildDataRow(
                          label: "LOCATION DESCRIPTION:",
                          value: _equipmentData?["location_description"],
                        ),
                        _buildDataRow(
                          label: "EQUIPMENT CATEGORY:",
                          value: _equipmentData?["equipment_sub_category"],
                        ),
                        _buildDataRow(
                          label: "EQUIPMENT TYPE:",
                          value: _equipmentData?["equipment_type"],
                        ),
                        _buildDataRow(
                          label: "EQUIPMENT FAMILY:",
                          value: _equipmentData?["equipment_category"],
                        ),
                        _buildDataRow(
                          label: "LAST INSPECTION DATE:",
                          value: _equipmentData?["last_inspection_date"] ??
                              "Not Available",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ─── Accordion: Purchase & Warranty Details ───
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color(0xff0DC5B9), width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                        // ✅ Fix: ensure tile background is white in both states
                        colorScheme: Theme.of(context).colorScheme.copyWith(
                              surface: Colors.white,
                            ),
                      ),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                        childrenPadding: EdgeInsets.zero,
                        iconColor: const Color(0xff0DC5B9),
                        collapsedIconColor: const Color(0xff0DC5B9),
                        // ✅ Fix: explicitly set background colors so title never hides
                        backgroundColor: Colors.white,
                        collapsedBackgroundColor: Colors.white,
                        // ✅ Fix: title with explicit color always visible
                        title: Row(
                          children: [
                            const Icon(
                              Icons.receipt_long_outlined,
                              color: Color(0xff0DC5B9),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Purchase & Warranty Details",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff0DC5B9),
                              ),
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Column(
                              children: [
                                _buildDataRow(
                                  label: "PURCHASE DATE:",
                                  value: _equipmentData?["purchase_date"],
                                ),
                                _buildDataRow(
                                  label: "PURCHASE PRICE:",
                                  value: _equipmentData?["purchase_price"] !=
                                          null
                                      ? "PKR ${_equipmentData!["purchase_price"]}"
                                      : null,
                                ),
                                _buildDataRow(
                                  label: "WARRANTY EXPIRY DATE:",
                                  value:
                                      _equipmentData?["warranty_expiry_date"],
                                ),
                                _buildInvoiceRow(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  // ─── Reusable label + value row ───
  // ✅ Uses Flexible with flex ratio instead of Expanded
  // This prevents label from being cut off inside ExpansionTile
  Widget _buildDataRow({required String label, String? value}) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 45,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              flex: 55,
              child: Text(
                value ?? "No data",
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
        const Divider(height: 20),
      ],
    );
  }

  // ─── Invoice row with tappable "View Invoice" link ───
  Widget _buildInvoiceRow() {
    final invoiceUrl = _equipmentData?["invoice_attachment"];
    final hasInvoice = invoiceUrl != null && invoiceUrl.toString().isNotEmpty;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Flexible(
              flex: 45,
              child: Text(
                "INVOICE:",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              flex: 55,
              child: hasInvoice
                  ? GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FullScreenImageView(imageUrl: invoiceUrl),
                          ),
                        );
                      },
                      child: const Text(
                        "View Invoice",
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xff0DC5B9),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    )
                  : const Text(
                      "No data",
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
            ),
          ],
        ),
        const Divider(height: 20),
      ],
    );
  }
}
