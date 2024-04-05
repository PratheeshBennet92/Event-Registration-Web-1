import 'package:flutter/material.dart';

class FailureScreen extends StatelessWidget {
  const FailureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Failure'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Registration failed',
              style: TextStyle(fontSize: 20, color: Colors.red),
            ),
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100, // Adjust width as needed
                  height: 100, // Adjust height as needed
                  color: Colors.white,
                ),
                Icon(
                  Icons.close,
                  color: Colors.red,
                  size: 48, // Adjust size as needed
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
