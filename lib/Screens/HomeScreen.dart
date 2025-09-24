import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hash_mufattish/LanguageTranslate/app_localizations.dart';
import 'package:hash_mufattish/Providers/local_Provider.dart';
import 'package:hash_mufattish/Screens/Profile.dart';
import 'package:hash_mufattish/Screens/equipment_info.dart';
import 'package:hash_mufattish/Screens/internet_error_popup.dart';
import 'package:hash_mufattish/Screens/login.dart';
import 'package:hash_mufattish/Screens/my_record.dart';
import 'package:hash_mufattish/Screens/new_inspection.dart';
import 'package:hash_mufattish/Screens/qr_code_scanner.dart';
import 'package:hash_mufattish/Screens/qr_code_scanner_dialog.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class HomeScreen extends StatefulWidget {
  int id;
  String name;
  String company;
  String branch;
  String email;
  String password;
  String image;
  String contact;
  HomeScreen({
    super.key,
    required this.id,
    required this.name,
    required this.company,
    required this.branch,
    required this.email,
    required this.password,
    required this.image,
    required this.contact,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // final _qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();  
    final MobileScannerController _controller = MobileScannerController();
    
// Controller for the scanner
  final MobileScannerController controller = MobileScannerController();
  StreamSubscription<Object?>? _subscription;
  String? scannedCode;

  String? code;

  void _showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
    ),
  );
  Navigator.pop(context); // Close dialog on error
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 30),
                child: Image.asset(
                  "assets/HASH MUFATTISH.png",
                  scale: 4,
                ),
              ),
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (context) => NetworkWrapper(
              //             child: QRViewExample(
              //               id: widget.id,
              //               name: widget.name,
              //               branch: widget.branch,
              //               company: widget.company,
              //               email: widget.email,
              //               password: widget.password,
              //               image: widget.image,
              //               contact: widget.contact,
              //             ),
              //           ),
              //         ));
              //     // Navigator.push(
              //     //   context,
              //     //   MaterialPageRoute(
              //     //     builder: (context) => NetworkWrapper(
              //     //       child: NewInspection(
              //     //         data: const {
              //     //           "report_id": 13,
              //     //           "equipment_id": "7",
              //     //           "checklist_id": "7",
              //     //           "equipment_category": "Fire Extinguisher",
              //     //           "equipment_sub_category":
              //     //               "Water-Based Extinguishers",
              //     //           "equipment_type":
              //     //               "For ordinary combustibles like wood, paper, and textiles",
              //     //           "checklist": "Testing Fire Estinguishers",
              //     //           "area_id": "8",
              //     //           "area": "Elevator Lobbies",
              //     //           "location":
              //     //               "Every 75 feet along guest room corridors",
              //     //           "location_description":
              //     //               "This ensures immediate access as guests and staff enter or exit the building, providing a quick response point in case of a fire.",
              //     //           "location_id": "8",
              //     //           "equipment_name":
              //     //               "Aqueous Film-Forming Foam (AFFF) Extinguisher",
              //     //           "description":
              //     //               "AFFF extinguishers contain a foam solution that forms a blanket or film over the fuel, suppressing the fire by smothering it and cutting off the oxygen supply.",
              //     //           "certificate_permission": "yes",
              //     //           "issuance_date": "2024-07-03",
              //     //           "expiry_date": "2025-07-03",
              //     //           "equipment_img":
              //     //               "https:\/\/inspectoshield.com\/public\/uploads\/c94b72ad0f88e3f0ed4bd3ad2f970abb1719948133.jpg",
              //     //           "certificate_img":
              //     //               "https:\/\/inspectoshield.com\/public\/uploads\/6d600bd036cca887fd71d396910b60d11719948133.png",
              //     //           "tags": [
              //     //             "Pressure Gauge",
              //     //             "Label and Instructions",
              //     //             "Nozzle and Hose",
              //     //             "Tamper Seal",
              //     //             "Pressure Test",
              //     //             "Siphon Tube",
              //     //             "Seals and Pins"
              //     //           ]
              //     //         },
              //     //         id: widget.id,
              //     //         name: widget.name,
              //     //         branch: widget.branch,
              //     //         company: widget.company,
              //     //         email: widget.email,
              //     //         password: widget.password,
              //     //         image: widget.image,
              //     //         contact: widget.contact,
              //     //       ),
              //     //     ),
              //     //   ),
              //     // );
              //   },
              //   child: Text('New Inspection'),
              // ),

              //Moving to new inspection
              Padding(
                  padding: const EdgeInsets.all(12.0),
                  child:
                  //  ArgonButton(
                  //     width: MediaQuery.of(context).size.width,
                  //     height: 50,
                  //     borderRadius: 8.0,
                  //     elevation: 10,
                  //     color: Colors.black,
                  //     borderSide: BorderSide(color: Colors.blue),
                  //     child: Text(
                  //       AppLocalizations.of(context)!
                  //           .translate('NEW INSPECTION'),

                  //       style: TextStyle(
                  //           color: Colors.white,
                  //           fontSize: 15,
                  //           fontWeight: FontWeight.w500),
                  //     ),
                  //     onTap: (startLoading, stopLoading, btnState) {

                     
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (context) => NewInspection(
                  //             data: const {
                  //               "report_id": 78,
                  //               "equipment_id": "6",
                  //               "location": "1st Floor",
                  //               "location_description": "account office",
                  //               "equipment_name": "PowerGuard Inverter 3000",
                  //               // "report_id": 12,A
                  //               // "equipment_id": "6",
                  //               // // "checklist_id": "6",
                  //               // // "equipment_category": "Electrical Equipment's",
                  //               // // "equipment_sub_category":
                  //               // //     "Power Supply Systems",
                  //               // // "equipment_type": "Inverter",
                  //               // // "checklist": "Inverter Testing",
                  //               // // "area_id": "7",
                  //               // // "area": "Electrical Room",
                  //               // "location":
                  //               //     "Adjacent to the Main Distribution Panel",
                  //               // "location_description":
                  //               //     "he PowerGuard Inverter 3000 is installed in the electrical room of the PC Hotel, specifically in the backup power section adjacent to the main distribution panel.",
                  //               // // "location_id": "7",
                  //               // "equipment_name": "PowerGuard Inverter 3000",
                  //               // // "description":
                  //               // //     "To ensure the PowerGuard Inverter 3000 operates reliably and safely, a comprehensive testing process is conducted. This involves several stages, each designed to assess different aspects of the inverter's performance and functionality.",
                  //               // // "certificate_permission": "no",
                  //               // // "issuance_date": null,
                  //               // // "expiry_date": null,
                  //               // // "equipment_img":
                  //               // //     "https:\/\/inspectoshield.com\/public\/uploads\/e940e867f5b3c741a67d004a114977e61719829599.jpg",
                  //               // // "certificate_img":
                  //               // //     "https:\/\/inspectoshield.com\/public\/uploads\/",
                  //               // // "tags": [
                  //               // //   "Output Voltage",
                  //               // //   "Output Frequency",
                  //               // //   "Switching and Control",
                  //               // //   "Automatic Transfer Switch (ATS)",
                  //               // //   "Battery Charging",
                  //               // //   "Noise Level",
                  //               // //   "Efficiency"
                  //               // // ]
                  //             },
                  //             id: widget.id,
                  //             name: widget.name,
                  //             branch: widget.branch,
                  //             company: widget.company,
                  //             email: widget.email,
                  //             password: widget.password,
                  //             image: widget.image,
                  //             contact: widget.contact,
                  //           ),
                  //         ),
                  //       );

                  //     }



                  //     )


ArgonButton(
  width: MediaQuery.of(context).size.width,
  height: 50,
  borderRadius: 8.0,
  elevation: 10,
  color: Colors.black,
  borderSide: BorderSide(color: Colors.blue),
  child: Text(
    'NEW INSPECTION',
    style: TextStyle(
      color: Colors.white,
      fontSize: 15,
      fontWeight: FontWeight.w500,
    ),
  ),
  onTap: (startLoading, stopLoading, btnState) async {
    bool isNavigated = false; // Flag to prevent multiple navigations

    Alert(
      context: context,
      title: "Scan QR Code",
      content: SizedBox(
        height: 400,
        width: 300,
        child: MobileScanner(
          onDetect: (BarcodeCapture barcodeCapture) {
            if (isNavigated) return; // Prevent multiple scans
            isNavigated = true;

            final String? code = barcodeCapture.barcodes.first.rawValue;
            print('Raw QR Code Data: \$code');

            if (code != null && code.trim().startsWith('{')) {
              try {
                final decodedData = json.decode(code);

                if (decodedData is Map) {
                  Navigator.pop(context); // Close scanner dialog

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NetworkWrapper(
                        child: NewInspection(
                          data: decodedData,
                          id: widget.id,
                          name: widget.name,
                          branch: widget.branch,
                          company: widget.company,
                          email: widget.email,
                          password: widget.password,
                          image: widget.image,
                          contact: widget.contact,
                        ),
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Unexpected QR code format.'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to decode QR code data.'),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            } else {
              print("Invalid QR code format.");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Ensure QR code is scanned under optimal conditions (lighting, angle, distance).',
                  ),
                  duration: Duration(seconds: 5),
                ),
              );
            }
          },
        ),
      ),
      buttons: [
        DialogButton(
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.red,
        ),
      ],
    ).show();
  },
),




                      ),






              // Padding(
              //   padding: const EdgeInsets.all(12.0),
              //   child: ArgonButton(
              //       width: MediaQuery.of(context).size.width,
              //       height: 50,
              //       borderRadius: 8.0,
              //       elevation: 10,
              //       color: Colors.black,
              //       borderSide: BorderSide(color: Colors.blue),
              //       child: Text(
              //         AppLocalizations.of(context)!.translate('EQUIPMENT INFO'),
              //         style: TextStyle(
              //             color: Colors.white,
              //             fontSize: 15,
              //             fontWeight: FontWeight.w500),
              //       ),
              //       //   loader: Container(
              //       //   padding: EdgeInsets.all(10),
              //       //   child: SpinKitRotatingCircle(
              //       //   color: tWhite,
              //       //   // size: loaderWidth ,
              //       //   ),
              //       //   )   ,

                  
                  
              //       onTap: (startLoading, stopLoading, btnState) {
              //         _qrBarCodeScannerDialogPlugin.getScannedQrBarCode(
              //             context: context,
              //             onCode: (code) {
              //               Navigator.push(
              //                 context,
              //                 MaterialPageRoute(
              //                   builder: (context) => NetworkWrapper(
              //                     child: EquipementInfo(
              //                       data: json.decode(code!),
              //                     ),
              //                   ),
              //                 ),
              //               );
              //             });
              //         // Navigator.push(
              //         //   context,
              //         //   MaterialPageRoute(
              //         //     builder: (context) => EquipementInfo(
              //         //       data: const {
              //         //         "report_id": 14,
              //         //         // "equipment_id": "7",
              //         //         // "checklist_id": "7",
              //         //         // "equipment_category": "Fire Extinguisher",
              //         //         // "equipment_sub_category":
              //         //         //     "Water-Based Extinguishers",
              //         //         // "equipment_type":
              //         //         //     "For ordinary combustibles like wood, paper, and textiles",
              //         //         // "checklist": "Testing Fire Estinguishers",
              //         //         // "area_id": "8",
              //         //         // "area": "Elevator Lobbies",
              //         //         // "location":
              //         //         //     "Every 75 feet along guest room corridors",
              //         //         // "location_description":
              //         //         //     "This ensures immediate access as guests and staff enter or exit the building, providing a quick response point in case of a fire.",
              //         //         // "location_id": "8",
              //         //         // "equipment_name":
              //         //         //     "Aqueous Film-Forming Foam (AFFF) Extinguisher",
              //         //         // "description":
              //         //         //     "AFFF extinguishers contain a foam solution that forms a blanket or film over the fuel, suppressing the fire by smothering it and cutting off the oxygen supply.",
              //         //         // "certificate_permission": "yes",
              //         //         // "issuance_date": "2024-07-03",
              //         //         // "expiry_date": "2025-07-03",
              //         //         // "equipment_img":
              //         //         //     "https:\/\/inspectoshield.com\/public\/uploads\/c94b72ad0f88e3f0ed4bd3ad2f970abb1719948133.jpg",
              //         //         // "certificate_img":
              //         //         //     "https:\/\/inspectoshield.com\/public\/uploads\/6d600bd036cca887fd71d396910b60d11719948133.png",
              //         //         // "tags": [
              //         //         //   "Pressure Gauge",
              //         //         //   "Label and Instructions",
              //         //         //   "Nozzle and Hose",
              //         //         //   "Tamper Seal",
              //         //         //   "Pressure Test",
              //         //         //   "Siphon Tube",
              //         //         //   "Seals and Pins"
              //         //         // ]
              //         //       },
              //         //     ),
              //         //   ),
              //         // );
              //       }




              //   ),
              // ),





// //  new code below
// Padding(
//   padding: const EdgeInsets.all(12.0),
//   child: ArgonButton(
//     width: MediaQuery.of(context).size.width,
//     height: 50,
//     borderRadius: 8.0,
//     elevation: 10,
//     color: Colors.black,
//     borderSide: BorderSide(color: Colors.blue),
//     child: Text(
//       AppLocalizations.of(context)!.translate('EQUIPMENT INFO'),
//       style: TextStyle(
//         color: Colors.white,
//         fontSize: 15,
//         fontWeight: FontWeight.w500,
//       ),
//     ),
//     onTap: (startLoading, stopLoading, btnState) async {
//       await showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text('Scan QR Code'),
//             content: SizedBox(
//               height: 400,
//               width: 300,
//               child: MobileScanner(
//                 onDetect: (BarcodeCapture barcodeCapture) {
//                   final String? code = barcodeCapture.barcodes.first.rawValue;
//                   print('Raw QR Code Data: $code');

//                   if (code != null && code.trim().startsWith('{')) {
//                     try {
//                       final decodedData = json.decode(code);

//                       if (decodedData is Map) {
//                         Navigator.pop(context); // Close scanner dialog first

//                         // Navigate to Equipment Info screen
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => NetworkWrapper(
//                               child: EquipementInfo(
//                                 data: decodedData,
//                               ),
//                             ),
//                           ),
//                         );
//                       } else {
//                         _showError(context, 'Unexpected QR code format.');
//                       }
//                     } catch (e) {
//                       _showError(context, 'Failed to decode QR code data.');
//                     }
//                   } else {
//                     _showError(context, 'Invalid QR code format.');
//                   }
//                 },
//               ),
//             ),
//           );
//         },
//       );
//     },
//   ),
// ),

Padding(
  padding: const EdgeInsets.all(12.0),
  child: ArgonButton(
    width: MediaQuery.of(context).size.width,
    height: 50,
    borderRadius: 8.0,
    elevation: 10,
    color: Colors.black,
    borderSide: BorderSide(color: Colors.blue),
    child: Text(
      AppLocalizations.of(context)!.translate('EQUIPMENT INFO'),
      style: TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    ),
    onTap: (startLoading, stopLoading, btnState) async {
      Alert(
        context: context,
        title: "Scan QR Code",
        content: SizedBox(
          height: 400,
          width: 300,
          child: MobileScanner(
            onDetect: (BarcodeCapture barcodeCapture) {
              final String? code = barcodeCapture.barcodes.first.rawValue;
              print('Raw QR Code Data: \$code');

              if (code != null && code.trim().startsWith('{')) {
                try {
                  final decodedData = json.decode(code);

                  if (decodedData is Map) {
                    Navigator.pop(context); // Close scanner dialog first

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NetworkWrapper(
                          child: EquipementInfo(
                            data: decodedData,
                          ),
                        ),
                      ),
                    );
                  } else {
                    _showError(context, 'Unexpected QR code format.');
                  }
                } catch (e) {
                  _showError(context, 'Failed to decode QR code data.');
                }
              } else {
                _showError(context, 'Invalid QR code format.');
              }
            },
          ),
        ),
        buttons: [
          DialogButton(
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            onPressed: () => Navigator.pop(context),
            color: Colors.red,
          ),
        ],
      ).show();
    },
  ),
),


    Padding(
                padding: const EdgeInsets.all(12.0),
                child: ArgonButton(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  borderRadius: 8.0,
                  elevation: 10,
                  color:  Colors.black,
                  borderSide: BorderSide(color: Colors.blue),
                  child: Text(
                    AppLocalizations.of(context)!.translate('MY RECORD'),
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NetworkWrapper(
                                child: MyRecords(id: widget.id))));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ArgonButton(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  borderRadius: 8.0,
                  elevation: 10,
                  color: Colors.black,
                  borderSide: BorderSide(color: Colors.blue),
                  child: Text(
                    AppLocalizations.of(context)!.translate('MY ACCOUNT'),
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NetworkWrapper(
                                  child: Profile(
                                    id: widget.id,
                                    name: widget.name,
                                    company: widget.company,
                                    branch: widget.branch,
                                    email: widget.email,
                                    password: widget.password,
                                    image: widget.image,
                                    contact: widget.contact,
                                  ),
                                )));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ArgonButton(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  borderRadius: 8.0,
                  elevation: 10,
                  color: Colors.black,
                  borderSide: BorderSide(color: Colors.blue),
                  child: Text(
                    AppLocalizations.of(context)!.translate('LOGOUT'),
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
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  
}
