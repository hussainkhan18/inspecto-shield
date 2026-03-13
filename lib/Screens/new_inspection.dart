import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hash_mufattish/LanguageTranslate/app_localizations.dart';
import 'package:hash_mufattish/Providers/checklist_Provider.dart';
import 'package:hash_mufattish/Screens/HomeScreen.dart';
import 'package:hash_mufattish/services/equipment_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class NewInspection extends StatefulWidget {
  final Map data;
  final int id;
  final String name;
  final String company;
  final String branch;
  final String email;
  final String image;
  final String contact;

  const NewInspection({
    super.key,
    required this.data,
    required this.id,
    required this.name,
    required this.company,
    required this.branch,
    required this.email,
    required this.image,
    required this.contact,
  });

  @override
  State<NewInspection> createState() => _NewInspectionState();
}

class _NewInspectionState extends State<NewInspection> {
  String? selectedValue = "";
  List items = [];
  File? _image;
  bool isVisible = false;
  File? _certificate;
  bool isShow = false;
  bool _isLoading = true;
  TextEditingController issueDate = TextEditingController();
  TextEditingController expiryDate = TextEditingController();

  Future<void> _selectIssueDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );
    if (pickedDate != null) {
      issueDate.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );
    if (pickedDate != null) {
      expiryDate.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
        source: source, imageQuality: 20, maxHeight: 500, maxWidth: 500);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        isVisible = true;
      });
      print("_image size check $_image");
    }
  }

  Future pickCertificate() async {
    final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 30,
        maxHeight: 200,
        maxWidth: 200);

    if (pickedFile != null) {
      setState(() {
        _certificate = File(pickedFile.path);
        isShow = true;
      });
      Navigator.of(context).pop();
      _showImageDialog();
    }
  }

  void showPickerDialog() {
    Alert(
      context: context,
      title: AppLocalizations.of(context)!.translate("Select Image Source"),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              pickImage(ImageSource.camera);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff0DC5B9),
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * .05,
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.translate("Camera"),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              pickImage(ImageSource.gallery);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff0DC5B9),
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * .05,
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.translate("Gallery"),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
      buttons: [
        DialogButton(
          onPressed: () => Navigator.pop(context),
          color: Colors.red,
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ],
    ).show();
  }

  void _showImageDialog() {
    Alert(
      context: context,
      title: AppLocalizations.of(context)!.translate("Add Certificate"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ArgonButton(
            width: MediaQuery.of(context).size.width,
            height: 50,
            borderRadius: 8.0,
            elevation: 10,
            color: const Color(0xff0DC5B9),
            child: Text(
              AppLocalizations.of(context)!.translate("Add Picture"),
              style: const TextStyle(color: Colors.white),
            ),
            onTap: (startLoading, stopLoading, btnState) async {
              pickCertificate();
            },
          ),
          const SizedBox(height: 10),
          _certificate != null
              ? Image.file(_certificate!, height: 60)
              : Text(AppLocalizations.of(context)!
                  .translate('No image selected.')),
          const SizedBox(height: 10),
          _buildDateField("Issue Date: ", issueDate, _selectIssueDate),
          const SizedBox(height: 10),
          _buildDateField("Expiry Date: ", expiryDate, _selectExpiryDate),
        ],
      ),
      buttons: [
        DialogButton(
          onPressed: () async {
            if (_certificate == null ||
                issueDate.text.isEmpty ||
                expiryDate.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Please fill all the required fields.")),
              );
              return;
            }
            await postCertificateDataToAPI(
              widget.data["equipment_id"].toString(),
              _certificate,
              issueDate.text,
              expiryDate.text,
            );
            Navigator.pop(context);
          },
          color: Colors.black,
          child: const Text(
            "Submit",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ],
    ).show();
  }

  Widget _buildDateField(String label, TextEditingController controller,
      Function(BuildContext) onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(AppLocalizations.of(context)!.translate(label)),
        Container(
          height: 40,
          width: 100,
          color: Colors.white,
          child: TextField(
            textAlign: TextAlign.center,
            controller: controller,
            readOnly: true,
            decoration: InputDecoration(
              hintText:
                  AppLocalizations.of(context)!.translate("Select a date"),
              border: InputBorder.none,
            ),
            onTap: () => onTap(context),
          ),
        ),
      ],
    );
  }

  Future<void> postCertificateDataToAPI(String equipmentId,
      File? certificateImg, String issuanceDate, String expiryDate) async {
    if (certificateImg == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!
              .translate("Certificate detail could not be added"))));
      return;
    }
    try {
      final success = await EquipmentService.postCertificate(
        reportId: widget.data["report_id"].toString(),
        certificateImg: certificateImg,
        issuanceDate: issuanceDate,
        expiryDate: expiryDate,
      );
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!
                .translate("Certificate details added successfully"))));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!
                .translate("Certificate detail could not be added"))));
      }
    } catch (e) {
      print('Error posting data: $e');
    }
  }

  Future<Map<String, dynamic>?> fetchEquipmentData(String reportId) async {
    return await EquipmentService.fetchEquipmentData(reportId);
  }

  Map<String, dynamic>? _equipmentData;

  Future<void> _fetchEquipmentData() async {
    try {
      final data =
          await fetchEquipmentData(widget.data["report_id"].toString());
      print("locationId ${widget.data["report_id"]}");
      setState(() {
        _equipmentData = data;
        _isLoading = false;

        if (_equipmentData != null && _equipmentData!['tags'] != null) {
          final checklistData = _equipmentData!['tags'];
          final checklistItems = checklistData is String
              ? checklistData.split(',')
              : List<String>.from(checklistData);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<ChecklistProvider>(context, listen: false)
                .addItems(checklistItems);
          });
        }
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching equipment data: $error');
    }
  }

  Future<void> saveCheckList() async {
    try {
      var equipmentData =
          await fetchEquipmentData(widget.data["report_id"].toString());
      if (!mounted) return;
      if (equipmentData == null) {
        print("Equipment data is null");
        return;
      }
      if (!mounted) return;
      if (_image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Upload equipment Image First")));
        return;
      }
      if (!mounted) return;
      var checklistProvider =
          Provider.of<ChecklistProvider>(context, listen: false);
      if (!checklistProvider.areAllTagsSelected()) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!
                .translate("Please select all tags"))));
        return;
      }

      final result = await EquipmentService.saveCheckList(
        equipmentData: equipmentData,
        imageFile: _image!,
        certificateFile: _certificate,
        reportId: widget.data["report_id"].toString(),
        inspectorId: widget.id,
        inspectorName: widget.name,
        issuanceDate: issueDate.text,
        expiryDate: expiryDate.text,
        checklistItems: Map<String, String>.from(checklistProvider.items),
      );

      if (!mounted) return;
      if (result['statusCode'] == 200) {
        showSuccessAnimation(context);
      } else if (result['body']["success"] == false) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(result['body'].toString())));
      }
      print("Time Right Now: ${DateTime.now()}");
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Something went wrong please refresh app")));
      print('Error saving checklist: $error');
    }
  }

  void showSuccessAnimation(BuildContext context) {
    Alert(
      context: context,
      title: "Success",
      content: Column(
        children: [
          Lottie.asset(
            'assets/animations/success.json',
            width: MediaQuery.of(context).size.width * .7,
            height: MediaQuery.of(context).size.height * .3,
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.translate("New inspection made"),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      buttons: [
        DialogButton(
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  id: widget.id,
                  name: widget.name,
                  company: widget.company,
                  branch: widget.branch,
                  email: widget.email,
                  image: widget.image,
                  contact: widget.contact,
                ),
              ),
              (Route<dynamic> route) => false,
            );
          },
          color: Colors.black,
          child: const Text(
            "CLOSE",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ).show();
  }

  @override
  void initState() {
    print("QR code id ${widget.data["id"]}");
    print("QR code id ${widget.data}");
    _fetchEquipmentData();
    print(widget.data);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── TOP HEADER CARD ─────────────────────────────
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Equipment image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _equipmentData?["equipment_img"] ??
                                  "https://hashbaqala.bssstageserverforpanels.xyz/upload/profileImage/user.png",
                              width: 100,
                              height: 100,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Container(
                                width: 100,
                                height: 100,
                                color: const Color(0xffF0F0F0),
                                child: const Icon(Icons.image_not_supported,
                                    color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Certificate button
                          Expanded(
                            child: Visibility(
                              visible: _equipmentData != null &&
                                  (_equipmentData!['certificate_permission'] ==
                                          'yes' ||
                                      _equipmentData![
                                              'certificate_permission'] ==
                                          'YES' ||
                                      _equipmentData![
                                              'certificate_permission'] ==
                                          "" ||
                                      _equipmentData![
                                              'certificate_permission'] ==
                                          null),
                              child: LayoutBuilder(
                                builder: (context, constraints) => ArgonButton(
                                  width: constraints.maxWidth,
                                  height: 46,
                                  borderRadius: 10.0,
                                  elevation: 4,
                                  color: const Color(0xff0DC5B9),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.add_circle_outline,
                                          color: Colors.white, size: 18),
                                      const SizedBox(width: 6),
                                      Text(
                                        AppLocalizations.of(context)!
                                            .translate("Add Certificate"),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  onTap: (startLoading, stopLoading, btnState) {
                                    print("saad qr data: ${widget.data}");
                                    _showImageDialog();
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── EQUIPMENT INFO CARD ──────────────────────────
                    _buildInfoCard(context),

                    // ── CHECKLIST CARD ───────────────────────────────
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Checklist header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: const Color(0xff0DC5B9),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  AppLocalizations.of(context)!
                                      .translate("Checklist"),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff1A1A2E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, indent: 16, endIndent: 16),

                          // Checklist Items
                          Consumer<ChecklistProvider>(
                            builder: (context, provider, child) {
                              final checkItems = provider.items.keys.toList();
                              return checkItems.isEmpty
                                  ? Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.all(32),
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .translate("No Data"),
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 15),
                                      ),
                                    )
                                  : ListView.separated(
                                      itemCount: checkItems.length,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      separatorBuilder: (_, __) =>
                                          const Divider(
                                              height: 1,
                                              indent: 16,
                                              endIndent: 16),
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                          child: _buildChecklistItem(
                                              checkItems[index]),
                                        );
                                      },
                                    );
                            },
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),

                    // ── UPLOAD IMAGE SECTION ─────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: ArgonButton(
                        width: MediaQuery.of(context).size.width - 32,
                        height: 52,
                        borderRadius: 12.0,
                        elevation: 4,
                        color: const Color(0xff0DC5B9),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.camera_alt_outlined,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!
                                  .translate("Upload Equipment Image"),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        onTap: (startLoading, stopLoading, btnState) {
                          print(_image);
                          pickImage(ImageSource.camera);
                        },
                      ),
                    ),

                    // Uploaded image preview
                    Visibility(
                      visible: isVisible,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        height: MediaQuery.of(context).size.height / 5,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xff0DC5B9), width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _image != null
                              ? Image.file(_image!, fit: BoxFit.cover)
                              : Center(
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .translate('No image selected.'),
                                  ),
                                ),
                        ),
                      ),
                    ),

                    // ── SAVE BUTTON ──────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      child: ArgonButton(
                        width: MediaQuery.of(context).size.width - 32,
                        height: 52,
                        borderRadius: 12.0,
                        elevation: 4,
                        color: const Color(0xff1A1A2E),
                        loader: Container(
                          padding: const EdgeInsets.all(10),
                          child: const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        onTap: (startLoading, stopLoading, btnState) async {
                          startLoading();
                          try {
                            await saveCheckList();
                          } finally {
                            stopLoading();
                          }
                        },
                        child: Text(
                          AppLocalizations.of(context)!.translate("SAVE"),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // ── EQUIPMENT INFO CARD ────────────────────────────────────────────────────
  Widget _buildInfoCard(BuildContext context) {
    final fields = [
      {"label": "EQUIPMENT NAME: ", "value": _equipmentData?["equipment_name"]},
      {"label": "AREA:", "value": _equipmentData?["area"]},
      {"label": "LOCATION:", "value": _equipmentData?["location"]},
      {"label": "DESCRIPTION:", "value": _equipmentData?["description"]},
      {"label": "EQUIPMENT TYPE: ", "value": _equipmentData?["equipment_type"]},
      {
        "label": "EQUIPMENT CATEGORY: ",
        "value": _equipmentData?["equipment_category"]
      },
      {
        "label": "LAST INSPECTION DATE: ",
        "value": _equipmentData?["last_inspection_date"]
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(fields.length, (i) {
          final isLast = i == fields.length - 1;
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.38,
                      child: Text(
                        AppLocalizations.of(context)!
                            .translate(fields[i]["label"] ?? ""),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff555555),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        fields[i]["value"] ?? "No data",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xff1A1A2E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast) const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        }),
      ),
    );
  }
}

// ── CHECKLIST ITEM with styled chips ────────────────────────────────────────
Widget _buildChecklistItem(String title) {
  final options = [
    {"label": "Good", "value": "Good", "color": const Color(0xff22C55E)},
    {"label": "Bad", "value": "Bad", "color": const Color(0xffEF4444)},
    {"label": "N/A", "value": "N/A", "color": const Color(0xff94A3B8)},
  ];

  return Consumer<ChecklistProvider>(
    builder: (context, provider, child) {
      final selectedVal = provider.items[title];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xff1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: options.map((opt) {
              final isSelected = selectedVal == opt["value"];
              final color = opt["color"] as Color;
              return Expanded(
                child: GestureDetector(
                  onTap: () =>
                      provider.changeValue(title, opt["value"] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withOpacity(0.12)
                          : const Color(0xffF5F6FA),
                      border: Border.all(
                        color: isSelected ? color : const Color(0xffDDE1E7),
                        width: isSelected ? 1.8 : 1.2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked,
                          color: isSelected ? color : const Color(0xffBDBDBD),
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          AppLocalizations.of(context)!
                              .translate(opt["label"] as String),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? color : const Color(0xff777777),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
    },
  );
}

// ── DATA ROW helper (kept for any external usage) ────────────────────────────
// Widget _buildDataRow(BuildContext context,
//     {required String label, required String value}) {
//   return Row(
//     children: [
//       Expanded(
//         child: SizedBox(
//           width: MediaQuery.of(context).size.width / 2,
//           child: Text(
//             AppLocalizations.of(context)!.translate(label),
//             style: const TextStyle(
//               fontSize: 15,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//       Expanded(
//         child: Container(
//           padding: const EdgeInsets.only(left: 20),
//           width: MediaQuery.of(context).size.width / 2,
//           child: Text(
//             value,
//             style: const TextStyle(
//               fontSize: 15,
//             ),
//           ),
//         ),
//       ),
//     ],
//   );
// }
