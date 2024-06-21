import 'dart:async';
import 'dart:typed_data';
import 'dart:convert'; // Added for UTF-8 encoding
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class DetailPage extends StatefulWidget {
  final BluetoothDevice server;

  const DetailPage({required this.server});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late StreamController<List<int>> _dataStreamController;
  String receivedData = '';
  BluetoothConnection? connection;
  bool isConnecting = true;

  bool get isConnected => connection != null && connection!.isConnected;
  bool isDisconnecting = false;

  List<List<int>> chunks = <List<int>>[];
  int contentLength = 0;
  final SpeechToText _speechToText = SpeechToText();

  bool _speechEnabled = false;
  String wordsSpoken = "";
  double _confidenceLevel = 0;

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
      wordsSpoken = "${result.recognizedWords.toLowerCase()}";
      _confidenceLevel = result.confidence;
    });
  }

  late Uint8List _bytes = Uint8List(0);

  late RestartableTimer _timer;
  List<int> allReceivedData = [];

  @override
  void initState() {
    super.initState();
    _dataStreamController = StreamController<List<int>>();
    _getBTConnection();
    _timer = RestartableTimer(Duration(seconds: 1), _writeData);
    initSpeech();
  }

  @override
  void dispose() {
    _dataStreamController.close();
    if (isConnected) {
      isDisconnecting = true;
      connection!.dispose();
      connection = null;
    }
    _timer.cancel();
    super.dispose();
  }

  _getBTConnection() {
    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      connection = _connection;
      isConnecting = false;
      isDisconnecting = false;
      setState(() {});
      connection!.input!.listen((_onDataRecieved)).onDone(() {
        if (isDisconnecting) {
          print("DISCONNECTING Locally");
        } else {
          print("DISCONNECTING REMOTELY!");
        }
        if (this.mounted) {
          setState(() {});
        }
        Navigator.of(context).pop();
      });
    }).catchError((error) {
      Navigator.of(context).pop();
    });
  }

  _writeData() {
    if (chunks.length == 0 || contentLength == 0) {
      return;
    }
    _bytes = Uint8List(contentLength);
    int offset = 0;
    for (final List<int> chunk in chunks) {
      _bytes.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }
    setState(() {});
    contentLength = 0;
    chunks.clear();
  }

  _onDataRecieved(Uint8List data) {
    String receivedString = String.fromCharCodes(data);
    receivedData += receivedString;
    List<String> values = receivedData.split(',');

    if (values.length >= 2) {
      int analogValue = int.tryParse(values[0]) ?? 0;
      allReceivedData.add(analogValue);
      _dataStreamController.add(allReceivedData);
      _timer.reset();
      print("Analog Value: $analogValue");
      receivedData = values[1];
    }

    print("Data Length: ${data.length}");
  }

  void _sendData(String data) {
    if (isConnected) {
      connection!.output.add(Uint8List.fromList(utf8.encode(data + '\r\n')));
      print("Data sent: $data");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Text sent successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send text: No connection')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: isConnecting
              ? Text("Connecting to ${widget.server.name}...")
              : isConnected
              ? Text("Connected with ${widget.server.name}")
              : Text("Disconnected with ${widget.server.name}")),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: SafeArea(
          child: Column(
            children: [
              if (isConnected)
                StreamBuilder<List<int>>(
                  stream: _dataStreamController.stream,
                  initialData: [],
                  builder: (context, snapshot) {
                    final List<int> data = allReceivedData;
                    List<FlSpot> spots = [];
                    int startIndex =
                    data.length > 100 ? data.length - 100 : 0;

                    for (int i = startIndex; i < data.length; i++) {
                      spots.add(FlSpot(
                          (i - startIndex).toDouble(), data[i].toDouble()));
                    }

                    return Container(
                      alignment: Alignment.centerLeft,

                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              _speechToText.isListening
                                  ? "Listening..."
                                  : _speechEnabled
                                  ? "Tap to start listening..."
                                  : "Speech not available",
                              style: const TextStyle(fontSize: 20.0,color: Colors.black),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              wordsSpoken,
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                          Center(
                            child: Container(
                            decoration:BoxDecoration(
                              color:const Color(0xFF0F94E3),
                              borderRadius: BorderRadius.circular(12)
                            ),
                              child: MaterialButton(
                                onPressed: () {

                                    if(
                                    wordsSpoken=='open gate'
                                    ){
                                      print('aaaaaaaaaa');
                                        _sendData('a');}
                                    else if( wordsSpoken=='close gate'){
                                      print('bbbbbbbbb');
                                      _sendData('b');
                                    }
                                    else if( wordsSpoken=='living room on'){
                                      print('cccccccc');
                                      _sendData('c');
                                    }
                                    else if( wordsSpoken=='living room off'){
                                      print('ddddddd');
                                      _sendData('d');
                                    }
                                    else if( wordsSpoken=='bedroom on'){
                                      print('eeeeeee');
                                      _sendData('e');
                                    }
                                    else if( wordsSpoken=='bedroom off'){
                                      print('ffffffff');
                                      _sendData('f');
                                    }
                                    else if( wordsSpoken=='open garage'){
                                      print('gggggggg');
                                      _sendData('g');
                                    }
                                    else if( wordsSpoken=='close garage'){
                                      print('hhhhhhhhhh');
                                      _sendData('h');
                                    }
                                    else if( wordsSpoken=='fan on'){
                                      print('iiiiiiiiii');
                                      _sendData('i');
                                    }
                                    else if( wordsSpoken=='fan off'){
                                      print('jjjjjjjjjj');
                                      _sendData('j');
                                    }
                                    else if( wordsSpoken=='turn on first light'){
                                      print('kkkkkkkkkk');
                                      _sendData('k');
                                    }
                                    else if( wordsSpoken=='turn off first light'){
                                      print('llllllll');
                                      _sendData('l');
                                    }
                                    else if( wordsSpoken=='turn on second light'){
                                      print('mmmmmmmmm');
                                      _sendData('m');
                                    }
                                    else if( wordsSpoken=='turn off second light'){
                                      print('nnnnnnnn');
                                      _sendData('n');
                                    }

                                },
                                child: Text('Send To Arduino',style:TextStyle(
                                  color: Colors.white
                                ),
                              ),

                                ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                )
              else
                Center(
                  child: Column(
                    children: [
                      Text(
                        "Connecting...",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      CircularProgressIndicator(),
                    ],
                  ),
                ),
            ],
          ),
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
