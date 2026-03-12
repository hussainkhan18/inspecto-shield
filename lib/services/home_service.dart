import 'dart:convert';
import 'package:hash_mufattish/constants/api_constants.dart';
import 'package:http/http.dart' as http;

class HomeService {
  // ── GET PENDING INSPECTIONS ─────────────────────────────────
  // Pehle: HomeScreen.dart mein directly tha
  static Future<Map<String, dynamic>?> getPendingInspections(int userId) async {
    final response = await http
        .get(
          Uri.parse('${ApiConstants.pending}/$userId'),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['success'] == true && jsonData['data'] != null) {
        return jsonData;
      }
    }
    return null;
  }
}
