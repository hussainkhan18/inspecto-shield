class ApiConstants {
  static const String baseUrl = 'https://inspectoshield.com/api';

  // Authentication & User
  static const String login = '$baseUrl/login';
  // profile update
  static const String profileUpdate = '$baseUrl/profile_update';
  // My Records
  static const String myRecords = '$baseUrl/my_records';
  // Generate report
  static const String generate = '$baseUrl/generate';
  // Inspections
  static const String inspection = '$baseUrl/equipment_inspection';
  // Certificate
  static const String certificate = '$baseUrl/equipment_certificate';
  // Pending Inspections for popup
  static const String pending = '$baseUrl/inspector/pending-inspections';
  //certificate download
  static const String getCertificate = '$baseUrl/certificate';
  //upcoming inspection
  static const String upcomingInspection = '$baseUrl/inspector/weekly-pending';
}
