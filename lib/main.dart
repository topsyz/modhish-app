import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:untitled3/BluetoothDeviceListEntry.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:untitled3/MyHomePage.dart';
import 'package:untitled3/detailpage.dart';
import 'package:untitled3/speech.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute:'SpeechScreen',
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  MyHomePage (title: ' Demo Home Page'),
    );
  }
}
