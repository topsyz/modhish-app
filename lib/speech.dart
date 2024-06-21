import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'navbar.dart';

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({Key? key, required String title});

  @override
  State<SpeechScreen> createState() => _SpeechScreen();
}

class _SpeechScreen extends State<SpeechScreen> {
  final SpeechToText _speechToText = SpeechToText();

  bool _speechEnabled = false;
  String _wordsSpoken = "";
  double _confidenceLevel = 0;

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void initSpeech() async {
    final PermissionStatus status = await Permission.microphone.request();
    if (status == PermissionStatus.granted) {
      _speechEnabled = await _speechToText.initialize();
      setState(() {});
    } else {
      print('Microphone permission not granted');
    }
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      _confidenceLevel = 0;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _wordsSpoken = "${result.recognizedWords}";
      _confidenceLevel = result.confidence;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7EDF4),
      drawer: const NavBar(),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE7EDF4),
        title: const Center(child: Text('Voice Controlled Home Automation App')),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                _speechToText.isListening
                    ? "listening..."
                    : _speechEnabled
                    ? "Tap to start listening..."
                    : "Speech not available",
                style: const TextStyle(fontSize: 20.0),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _wordsSpoken,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
          MaterialButton(onPressed: (){

          },
          child: Text('Send To Arduino'),)
          ],
        ),
      ),
      floatingActionButton: Center(
        child: FloatingActionButton(
          shape: const CircleBorder(),
          highlightElevation: 20,
          onPressed: _speechToText.isListening ? _stopListening : _startListening,
          tooltip: 'Listen',
          backgroundColor: const Color(0xFF0F94E3),
          child: Icon(
            _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
            color: Colors.white,
            size: 34,
          ),
        ),
      ),
    );
  }
}
