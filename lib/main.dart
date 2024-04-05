import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:event_registration_web/form.dart';
import 'dart:html' as html;
import 'formviewmodel.dart'; // Import your FormViewModel class

void main() {
  runApp(
    // Wrap MyApp with Provider and provide the FormViewModel
    ChangeNotifierProvider(
      create: (context) => FormViewModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // String initialUrl = 'https://example.com/register?eventId=YOUR_EVENT_ID_HERE&eventName=YOUR_EVENT_NAME_HERE';
    String initialUrl = html.window.location.href;
    // Extract the event ID and event name from the URL
    Uri uri = Uri.parse(initialUrl);
    String? eventId = uri.queryParameters['eventId'];
    String? eventName = uri.queryParameters['eventName'];
    String? parentDeviceId = uri.queryParameters['parentDeviceId'];
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 2, 9, 153)),
          useMaterial3: true,
        ),
        home: FormWidget(
          eventName: eventName ?? "",
          eventId: eventId ?? "",
          parentDeviceId: parentDeviceId ?? ""
        ));
  }
}
