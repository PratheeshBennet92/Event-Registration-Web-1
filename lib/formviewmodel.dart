import 'dart:convert';
import 'package:event_registration_web/encryption.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

// Model class representing the data fields of the form
class FormData {
  String? eventId;
  String? eventName;
  String? parentDeviceId;
  String? name;
  String? designation;
  String? contactNumber;
  String? email;
  String? city;
  String? institution;
  String? participantId;
  String? remarks;
}

// ViewModel class responsible for form logic and data manipulation
class FormViewModel extends ChangeNotifier {
  QrImageView? _qrImage;
  QrImageView? get qrImage => _qrImage;
  bool _isLoading = false;
  bool _isSucsess = false;
  bool get isLoading => _isLoading;
  bool get isSuccess => _isSucsess;
  final _formData = FormData();

  // Getters for accessing form data
  FormData get formData => _formData;

  // Form validation methods
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a name';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    } else if (!_isValidEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Submit form method
  Future<void> submitForm() async {
    _isLoading = true; // Set isLoading to true before making the API request
    notifyListeners(); // Notify listeners immediately
    String? parentDeviceId = _formData.parentDeviceId;
    if (parentDeviceId != null) {
      parentDeviceId = parentDeviceId.unscrambleUUID();
     // Now parentDeviceId is unscrambled if it was not null initially
    }
    Uint8List key = parentDeviceId!.generateEncryptionKey();
    String name = _formData.name ?? '';
    String designation = _formData.designation ?? '';
    String email = _formData.email ?? '';
    String contactNumber = _formData.contactNumber ?? '';
    String city = _formData.city ?? '';
    String institution = _formData.institution ?? '';
    String eventId = _formData.eventId ?? '';
    String remarks = _formData.remarks ?? '';
    _formData.participantId = generateCurrentTimeStamp();
    Map<String, dynamic> participants = {
      "participantName": name.encryptString(key),
      "eventId": eventId,
      "designation": designation,
      "contact": contactNumber.encryptString(key),
      "city": city,
      "institution": institution,
      "participantId": _formData.participantId,
      "participantEmail": email.encryptString(key),
      "status": "registered",
      "remarks": remarks
      // Add other form fields as needed
    };

    Map<String, dynamic> requestBody = {
      "parentDeviceId": _formData.parentDeviceId ?? '',
      "eventId": _formData.eventId ?? '',
      "name":  _formData.eventName ?? "",
      "participants": [participants]
    };
    print({requestBody, _isLoading});
    try {
      // Make the API request
      final url = Uri.https('zjk4kiwx8h.execute-api.us-east-1.amazonaws.com', 'dev/item');
      //final url = Uri.parse(
      //    'https://zjk4kiwx8h.execute-api.us-east-1.amazonaws.com/dev/item/');
      final response = await http.put(
        url,
        body: json.encode(requestBody),
        headers: {
          'Content-Type': 'application/json',
          "Access-Control-Allow-Origin": "*",
          "Accept": "*/*"
          },
      );
      // After the request is complete, set isLoading to false
      _isLoading = false;
      notifyListeners();
      // Check the response status
      if (response.statusCode == 200) {
        _isSucsess = true;
        notifyListeners();
        generateQRCode();
        print('Form data submitted successfully');
      } else {
        _isSucsess = false;
        notifyListeners();
        print('Failed to submit form data: ${response.body}');
      }
    } catch (e) {
      _isSucsess = false;
      notifyListeners();
      print('Error submitting form data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String generateCurrentTimeStamp() {
    DateFormat formatter = DateFormat('ddMMyyyyHHmmssSSS');
    return formatter.format(DateTime.now());
  }

  void setLoading(bool bool) {
    _isLoading = bool;
    notifyListeners();
  }

  // Method to generate QR code
  void generateQRCode() {
    final qrData = '${_formData.name ?? ''}-${_formData.eventName ?? ''}-${_formData.eventId ?? ''}-${_formData.participantId ?? ''}'; // Customize as needed
    _qrImage = QrImageView(
      data: qrData,
      version: QrVersions.auto,
      size: 200.0,
    );
    notifyListeners();
  }
}
