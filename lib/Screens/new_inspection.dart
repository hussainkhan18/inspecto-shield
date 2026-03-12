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
  // String password;
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
    // required this.password,
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
      // Format the date and show it in the text field
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
      // Format the date and show it in the text field
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
      Navigator.of(context).pop(); // Close the current dialog
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

// ── FETCH EQUIPMENT DATA ─────────────────────────────────
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

        // Add checklist items to ChecklistProvider here
        if (_equipmentData != null && _equipmentData!['tags'] != null) {
          final checklistData = _equipmentData!['tags'];
          final checklistItems = checklistData is String
              ? checklistData.split(',')
              : List<String>.from(checklistData);

          // Update provider after build
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
                  // password: widget.password,
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

    // if (Provider.of<LocaleProvider>(context, listen: false).locale ==
    //     const Locale('en')) {
    //   if (widget.data["tags"] != null &&
    //       (widget.data["tags"] as List).isNotEmpty) {
    //     items = widget.data["tags"] as List;
    //   }
    // } else {
    //   if (widget.data["arabic_tags"] != null &&
    //       (widget.data["arabic_tags"] as List).isNotEmpty) {
    //     items = widget.data["arabic_tags"] as List;
    //   }
    // }

    // print(items);
    // Provider.of<ChecklistProvider>(context, listen: false)
    //     .addItems(items.cast<String>());

    _fetchEquipmentData();

    print(widget.data);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  children: [
                    // Image and Add Certificate Button
                    Container(
                      height: MediaQuery.of(context).size.height / 5,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: Image.network(
                              _equipmentData?["equipment_img"] ??
                                  "https://hashbaqala.bssstageserverforpanels.xyz/upload/profileImage/user.png",
                              // scale: 7,
                              fit: BoxFit
                                  .contain, // optional: ensures it fits well

                              alignment: Alignment.center,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Visibility(
                            visible: _equipmentData != null &&
                                (_equipmentData!['certificate_permission'] == 'yes' ||
                                    _equipmentData!['certificate_permission'] ==
                                        'YES' ||
                                    _equipmentData!['certificate_permission'] ==
                                        "" ||
                                    _equipmentData!['certificate_permission'] ==
                                        null),
                            child: Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 20.0),
                                child: ArgonButton(
                                  width: 180,
                                  height: 50,
                                  borderRadius: 8.0,
                                  elevation: 10,
                                  color: const Color(0xff0DC5B9),
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .translate("Add Certificate"),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 15),
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

                    // Description
                    _buildDataRow(
                      context,
                      label: "EQUIPMENT NAME: ",
                      value: _equipmentData?["equipment_name"] ?? "No data",
                    ),
                    const Divider(),
                    // Location Description
                    _buildDataRow(
                      context,
                      label: "AREA:",
                      value: _equipmentData?["area"] ?? "No data",
                    ),
                    const Divider(),
                    // Location Description
                    _buildDataRow(
                      context,
                      label: "LOCATION:",
                      value: _equipmentData?["location"] ?? "No data",
                    ),

                    const Divider(),
                    // Equipment Name
                    _buildDataRow(
                      context,
                      label: "DESCRIPTION:",
                      value: _equipmentData?["description"] ?? "No data",
                    ),
                    const Divider(),
                    // Equipment Type
                    _buildDataRow(
                      context,
                      label: "EQUIPMENT TYPE: ",
                      value: _equipmentData?["equipment_type"] ?? "No data",
                    ),

                    const Divider(),
                    // Equipment Category
                    _buildDataRow(
                      context,
                      label: "EQUIPMENT CATEGORY: ",
                      value: _equipmentData?["equipment_category"] ?? "No data",
                    ),
                    const Divider(),
                    // Last Inspection Date
                    _buildDataRow(
                      context,
                      label: "LAST INSPECTION DATE: ",
                      value: _equipmentData?["last_inspection_date"] ??
                          "No data", // Replace with the correct field if available
                    ),
                    const Divider(),
                    // Checklist Title
                    Text(
                      AppLocalizations.of(context)!.translate("Checklist"),
                      style: const TextStyle(
                          fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    // Checklist Items
                    Consumer<ChecklistProvider>(
                      builder: (context, provider, child) {
                        final items = provider.items.keys.toList();
                        return items.isEmpty
                            ? Container(
                                alignment: Alignment.center,
                                height: 170,
                                child: Text(AppLocalizations.of(context)!
                                    .translate("No Data")),
                              )
                            : ListView.builder(
                                itemCount: items.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Container(
                                    height: 85,
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.only(
                                        left: 9, right: 20),
                                    child: _buildRadioButton(items[index]),
                                  );
                                },
                              );
                      },
                    ),
                    // Upload Equipment Image Button
                    ArgonButton(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      borderRadius: 8.0,
                      elevation: 10,
                      color: const Color(0xff0DC5B9),
                      child: Text(
                        AppLocalizations.of(context)!
                            .translate("Upload Equipment Image"),
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: (startLoading, stopLoading, btnState) {
                        print(_image);

                        showPickerDialog();
                      },
                    ),
                    // Display selected image
                    Visibility(
                      visible: isVisible,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height / 5,
                        child: _image != null
                            ? Image.file(_image!)
                            : Text(AppLocalizations.of(context)!
                                .translate('No image selected.')),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    // Save Button
                    ArgonButton(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      borderRadius: 8.0,
                      elevation: 10,
                      color: Colors.black,
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
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
    ));
  }
}

// Helper method to build a row with a label and value
Widget _buildDataRow(BuildContext context,
    {required String label, required String value}) {
  return Row(
    children: [
      Expanded(
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          child: Text(
            AppLocalizations.of(context)!.translate(label),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      Expanded(
        child: Container(
          padding: const EdgeInsets.only(left: 20),
          width: MediaQuery.of(context).size.width / 2,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
        ),
      ),
    ],
  );
}

Widget _buildRadioButton(String title) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 17),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Consumer<ChecklistProvider>(
            builder: (context, ChecklistProvider, child) {
              return GestureDetector(
                onTap: () {
                  ChecklistProvider.changeValue(
                      title, AppLocalizations.of(context)!.translate("Good"));
                },
                child: Row(
                  children: [
                    Radio(
                      fillColor: WidgetStateProperty.all(Colors.green),
                      activeColor: Colors.green,
                      value: "Good",
                      groupValue: ChecklistProvider.items[title],
                      onChanged: (value) {
                        ChecklistProvider.changeValue(title, "Good");
                      },
                    ),
                    Text(
                      AppLocalizations.of(context)!.translate('Good'),
                      style: const TextStyle(fontSize: 17),
                    ),
                  ],
                ),
              );
            },
          ),
          Consumer<ChecklistProvider>(
            builder: (context, ChecklistProvider, child) {
              return GestureDetector(
                onTap: () {
                  ChecklistProvider.changeValue(title, "Bad");
                },
                child: Row(
                  children: [
                    Radio(
                      fillColor: WidgetStateProperty.all(Colors.red),
                      activeColor: Colors.red,
                      value: "Bad",
                      groupValue: ChecklistProvider.items[title],
                      onChanged: (value) {
                        ChecklistProvider.changeValue(title, "Bad");
                      },
                    ),
                    Text(
                      AppLocalizations.of(context)!.translate('Bad'),
                      style: const TextStyle(fontSize: 17),
                    ),
                  ],
                ),
              );
            },
          ),
          Consumer<ChecklistProvider>(
            builder: (context, ChecklistProvider, child) {
              return GestureDetector(
                onTap: () {
                  ChecklistProvider.changeValue(title, "N/A");
                },
                child: Row(
                  children: [
                    Radio(
                      fillColor: WidgetStateProperty.all(Colors.grey[800]),
                      activeColor: Colors.grey[800],
                      value: "N/A",
                      groupValue: ChecklistProvider.items[title],
                      onChanged: (value) {
                        ChecklistProvider.changeValue(title, "N/A");
                      },
                    ),
                    Text(
                      AppLocalizations.of(context)!.translate('N/A'),
                      style: const TextStyle(fontSize: 17),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
    ],
  );
}
