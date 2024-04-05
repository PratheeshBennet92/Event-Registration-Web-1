import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_downloader_web/image_downloader_web.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

class SuccessScreen extends StatelessWidget {
  final ScreenshotController screenshotController = ScreenshotController();
  final QrImageView qrImageView;

  SuccessScreen({Key? key, required this.qrImageView}) : super(key: key);

  Future<Uint8List?> _captureAndConvertToImage() async {
    // Capture the QRImageView as an image using the ScreenshotController
    await screenshotController.capture();
    // Retrieve the captured image as Uint8List
    return await screenshotController.capture();
  }

  Future<void> _downloadImage(BuildContext context) async {
    try {
      // Capture and convert the QRImageView to an image
      final Uint8List? imageData = await _captureAndConvertToImage();
      if (imageData != null) {
        // Download the image using image_downloader_web
        await WebImageDownloader.downloadImageFromUInt8List(uInt8List: imageData, name:'qr_code.png');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture QR code image'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Success'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
                Icons.check,
                color: Colors.green,
                size: 48, // Adjust size as needed
              ),
            const Text(
              'Registration successful',
              style: TextStyle(fontSize: 20),
            ),
            const Text(
              'Please download the entry pass QR code',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            Screenshot(
              controller: screenshotController,
              child: Container(
                color: Colors.white,
                child: qrImageView,
              ), // Display the QR code image
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _downloadImage(context),
        child: Icon(Icons.download),
      ),
    );
  }
}
