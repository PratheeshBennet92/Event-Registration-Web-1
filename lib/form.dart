// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:event_registration_web/formviewmodel.dart';
import 'package:provider/provider.dart';
import 'success.dart';
import 'failure.dart';

class FormWidget extends StatefulWidget {
  const FormWidget(
      {super.key,
      required this.eventName,
      required this.eventId,
      required this.parentDeviceId});
  final String eventName;
  final String eventId;
  final String parentDeviceId;
  @override
  State<FormWidget> createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormWidget> {
  final _formKey = GlobalKey<FormState>();

  String? get eventId => widget.eventId;
  String? get eventName => widget.eventName;
  String? get parentDeviceId => widget.parentDeviceId;
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<FormViewModel>(context);
    viewModel.formData.eventId = eventId ?? "";
    viewModel.formData.eventName = eventName ?? "";
    viewModel.formData.parentDeviceId = parentDeviceId ?? "";
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Registration - ${widget.eventName}'),
      ),
      body: Center(
          child: SingleChildScrollView(
        child: Container(
          width: 400, // Set a fixed width
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildTextField('Name', viewModel.validateName,
                    (value) => viewModel.formData.name = value),
                _buildTextField('Designation', null,
                    (value) => viewModel.formData.designation = value),
                _buildTextField('Contact #', null,
                    (value) => viewModel.formData.contactNumber = value),
                _buildTextField('Email id', viewModel.validateEmail,
                    (value) => viewModel.formData.email = value),
                _buildTextField(
                    'City', null, (value) => viewModel.formData.city = value),
                _buildTextField('Institution', null,
                    (value) => viewModel.formData.institution = value),
                _buildTextField('Remarks', null,
                    (value) => viewModel.formData.remarks = value),
                const SizedBox(height: 20.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        // Form is valid, submit the data
                        if (!viewModel.isLoading) {
                          await viewModel.submitForm();
                          // Check if form submission is successful
                          if (viewModel.isSuccess) {
                            // Navigate to success screen
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SuccessScreen(
                                      qrImageView: viewModel.qrImage!)),
                            );
                          } else {
                            // Navigate to failure screen
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const FailureScreen()),
                            );
                          }
                        }
                      }
                    },
                    child: viewModel.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }

  Widget _buildTextField(String labelText, String? Function(String?)? validator,
      void Function(String?)? onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextFormField(
        maxLength: 30,
        decoration: InputDecoration(
            labelText: labelText, border: const OutlineInputBorder()),
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }
}
