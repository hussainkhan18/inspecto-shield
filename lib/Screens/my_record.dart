import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hash_mufattish/LanguageTranslate/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class MyRecords extends StatefulWidget {
  final int id;
  const MyRecords({super.key, required this.id});

  @override
  State<MyRecords> createState() => _MyRecordsState();
}

class _MyRecordsState extends State<MyRecords> {
  List<dynamic> recordList = [];

  @override
  void initState() {
    super.initState();

    getRecordList();
  }

  Future<void> getRecordList() async {
    try {
      final response = await http.get(
        Uri.parse('https://inspectoshield.com/api/my_records/${widget.id}'),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        List<dynamic> data = jsonResponse["data"]; // Extract the 'data' list
        List<dynamic> tempEquipments = [];
        for (Map i in jsonResponse["data"]) {
          tempEquipments.add([
            i["equipment_name"],
            i["updated_at"],
            i["location_description"],
            i["location_name"],
            i["area"],
          ]);
          // print("Updated at: ${i["updated_at"]}");
        }

        setState(() {
          recordList = tempEquipments;
        });
      } else {
        // Handle the case when the server doesn't return a 200 OK response
        print("Failed to load data");
      }
    } catch (e) {
      print({"error": e.toString()});
    }
  }

  @override
  Widget build(BuildContext context) {
    print(recordList);
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 50,
          ),
          Text(
            AppLocalizations.of(context)!.translate("My Records"),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.translate("EQUIPMENT"),
                    style: TextStyle(fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Text(
                      AppLocalizations.of(context)!.translate("WHEN"),
                      style: TextStyle(fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center
                      ,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.translate("LOCATION"),
                    style: TextStyle(fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.translate("AREA"),
                    style: TextStyle(fontWeight: FontWeight.w500),
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ), ),
          Expanded(
            child: recordList.isEmpty
                ? Center(
                    child:
                        CircularProgressIndicator()) // Show circular loading indicator when data is loading
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: recordList.length,
                    itemBuilder: (context, index) {
                      String datetimeStr = recordList[index][1].toString();

                      // Parse the datetime string into a DateTime object
                      DateTime datetime = DateTime.parse(datetimeStr);

                      // Format the date and time separately
                      String formattedDate =
                          DateFormat('yyyy-MM-dd').format(datetime);
                      String formattedTime =
                          DateFormat('hh:mm:ss').format(datetime);

                      // Combine date and time with a newline character
                      String formattedDateTime =
                          "$formattedDate\n$formattedTime";

                      String formatWithLineBreaks(String originalString) {
                        List<String> words = originalString
                            .split(' '); // Split the string into words.
                        String result = '';
                        String currentLine = '';

                        for (String word in words) {
                          // If adding the next word exceeds 15 characters, append the current line to result and reset it.
                          if ((currentLine + word).length > 15) {
                            result += currentLine.trim() +
                                '\n'; // Trim to remove any leading spaces before adding a line break.
                            currentLine =
                                '$word '; // Start a new line with the current word.
                          } else {
                            currentLine +=
                                '$word '; // Add the current word to the current line.
                          }
                        }

                        result += currentLine.trim();
                        // Add the last line to the result.
                        return result;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(
                            right: 9.0, left: 9, bottom: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            color: Color(0xff0DC5B9),
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.black,
                                width: 1.0,
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.only(top: 10, bottom: 10, left:15),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // SizedBox(
                              //   width: 1,
                              // ),
                              Expanded(
                                child: Text(
                                  // Equipment Text
                                  recordList[index][0]
                                              .toString()
                                              .split(' ')
                                              .length ==
                                          3
                                      ? recordList[index][0]
                                              .toString()
                                              .split(' ')
                                              .take(2)
                                              .join(' ') +
                                          '\n' +
                                          recordList[index][0]
                                              .toString()
                                              .split(' ')
                                              .last
                                      : recordList[index][0].toString(),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  // Time Text
                                  formattedDateTime,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  // Location Name
                                  recordList[index][2].toString(),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  // Location Description
                                  formatWithLineBreaks(
                                      recordList[index][4].toString()),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
