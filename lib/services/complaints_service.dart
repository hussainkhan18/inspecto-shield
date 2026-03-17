import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:hash_mufattish/constants/api_constants.dart';
import 'package:hash_mufattish/services/secure_storage_service.dart';

class ComplaintService {
  /// Returns:
  ///   {'success': true,  'data': {...}}      on success
  ///   {'success': false, 'message': '...'}   on any failure
  static Future<Map<String, dynamic>> submitComplaint({
    required String companyEquipmentId,
    required String priority,
    String? remarks,
    List<File>? images,
    File? voiceNote,
  }) async {
    try {
      final token = await SecureStorageService.getToken();
      final uri = Uri.parse(ApiConstants.complaints);
      final request = http.MultipartRequest('POST', uri);

      // Headers
      request.headers.addAll({
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });

      // Fields
      request.fields['company_equipment_id'] = companyEquipmentId;
      request.fields['priority'] = priority;
      if (remarks != null && remarks.trim().isNotEmpty) {
        request.fields['remarks'] = remarks.trim();
      }

      // Images (multiple)
      if (images != null && images.isNotEmpty) {
        for (final file in images) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'images[]',
              file.path,
              contentType: MediaType('image', 'jpeg'),
            ),
          );
        }
      }

      // Voice note — explicitly set audio/m4a mime type
      if (voiceNote != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'voice_note',
            voiceNote.path,
            contentType: MediaType('audio', 'wav'),
          ),
        );
      }

      final streamed = await request.send().timeout(
            const Duration(seconds: 60),
          );
      final response = await http.Response.fromStream(streamed);
      final body = json.decode(response.body) as Map<String, dynamic>;
      // print('=== COMPLAINT API RESPONSE ===');
      // print('Status Code: ${response.statusCode}');
      // print('Body: ${response.body}');
      // print('==============================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (body['success'] == true) {
          return {'success': true, 'data': body};
        }
        return {
          'success': false,
          'message': body['message'] ?? 'Submission failed.',
        };
      }

      if (response.statusCode == 422) {
        final errors = body['errors'] as Map<String, dynamic>? ?? {};
        String message = body['message'] ?? 'Validation failed.';
        if (errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) {
            message = first.first.toString();
          }
        }
        return {'success': false, 'message': message};
      }

      if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      }

      return {
        'success': false,
        'message': body['message'] ?? 'Something went wrong. Try again.',
      };
    } on SocketException {
      return {
        'success': false,
        'message': 'No internet connection. Please check your network.',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Request timed out. Please try again.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unexpected error. Please try again.',
      };
    }
  }
}
