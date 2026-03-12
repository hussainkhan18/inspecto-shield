import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hash_mufattish/LanguageTranslate/app_localizations.dart';
import 'package:hash_mufattish/services/record_service.dart';
import 'package:intl/intl.dart';

class MyRecords extends StatefulWidget {
  final int id;
  const MyRecords({super.key, required this.id});

  @override
  State<MyRecords> createState() => _MyRecordsState();
}

class _MyRecordsState extends State<MyRecords> {
  List<dynamic> recordList = [];
  bool isLoading = true;

  // ✅ File 1: static const — best practice
  static const primaryColor = Color(0xff0DC5B9);

  @override
  void initState() {
    super.initState();
    getRecordList();
  }

  Future<void> getRecordList() async {
    try {
      final records = await RecordService.getRecordList(widget.id);
      if (!mounted) return;
      setState(() {
        recordList = records;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2FAFA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(8, 10, 20, 10),
              color: Colors.white,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CupertinoButton(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.chevron_back, size: 25),
                        SizedBox(width: 2),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.translate("My Records"),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff1C2B2B),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  if (!isLoading && recordList.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${recordList.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 44),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── List ─────────────────────────────────────────
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                        strokeWidth: 2.5,
                      ),
                    )
                  : recordList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.folder_open_outlined,
                                  size: 44,
                                  color: primaryColor.withOpacity(0.35)),
                              const SizedBox(height: 10),
                              Text(
                                AppLocalizations.of(context)!
                                    .translate("No Records Found"),
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
                          itemCount: recordList.length,
                          itemBuilder: (context, index) {
                            return _buildRecordCard(index);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ File 1: Clean alag function — maintainable
  Widget _buildRecordCard(int index) {
    // ── Parse date ──────────────────────────────────────────
    String datetimeStr = recordList[index][1].toString();
    DateTime datetime = DateTime.parse(datetimeStr);
    String formattedDate = DateFormat('dd MMM yy').format(datetime);
    String formattedTime = DateFormat('hh:mm a').format(datetime);

    String equipmentText = recordList[index][0].toString();
    String locationText = recordList[index][2].toString();
    String areaText = recordList[index][4].toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.28),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Equipment name ───────────────────────────────
            Text(
              equipmentText,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.35,
              ),
            ),

            const SizedBox(height: 10),

            // ── Thin divider ─────────────────────────────────
            Container(
              height: 1,
              color: Colors.white.withOpacity(0.25),
            ),

            const SizedBox(height: 10),

            // ── Bottom row: WHEN | LOCATION | AREA ───────────
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // WHEN
                  Expanded(
                    flex: 3,
                    child: _cardCell(
                      label: "WHEN",
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            formattedTime,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.80),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  _vDivider(),

                  // LOCATION
                  Expanded(
                    flex: 4,
                    child: _cardCell(
                      label: "LOCATION",
                      child: Text(
                        locationText,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),

                  _vDivider(),

                  // AREA
                  Expanded(
                    flex: 4,
                    child: _cardCell(
                      label: "AREA",
                      child: Text(
                        areaText,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardCell({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.65),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }

  Widget _vDivider() {
    return Container(
      width: 1,
      color: Colors.white.withOpacity(0.25),
    );
  }
}
