
import 'package:dogo/data/services/localHost.dart';
import 'package:flutter/material.dart';

class TestinglocalHost extends StatefulWidget {
  const TestinglocalHost({super.key});

  @override
  State<TestinglocalHost> createState() => _TestinglocalHostState();
}

class _TestinglocalHostState extends State<TestinglocalHost> {
  String _output = "Ready to test localhost communication...\n\n";
  final ScrollController _scrollController = ScrollController();

  void _addToOutput(String message) {
    setState(() {
      _output += "${DateTime.now().toString().substring(11, 19)}: $message\n";
    });
    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void sendData() async {
    _addToOutput("Sending POST request...");

    Map<String, dynamic> data = {
      "user": "John",
      "duration": 2000,
      "interval": 1,
      "startNow": true,
      "sessionid": "123465",
    };

    try {
      final resp = await Localhost.postToLocalhost("/api/start", data);
      print(resp);

      _addToOutput("POST Response: $resp");
      print("POST Response: $resp");
    } catch (e) {
      _addToOutput("POST Error: $e");
      print("POST Error: $e");
    }
  }


  void getData() async {
    _addToOutput("Sending GET request...");

    try {
      final resp = await Localhost.getFromLocalhost();
      _addToOutput("GET Response: $resp");
      print("GET Response: $resp");
    } catch (e) {
      _addToOutput("GET Error: $e");
      print("GET Error: $e");
    }
  }

  void _clearOutput() {
    setState(() {
      _output = "Output cleared.\n\n";
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Localhost Testing"),
          backgroundColor: Colors.grey[200],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Control buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: sendData,
                      child: const Text("Send POST Data"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: getData,
                      child: const Text("Get Data"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _clearOutput,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[100],
                    ),
                    child: const Text("Clear"),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Output display
              const Text(
                "Output:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey[50],
                  ),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Text(
                      _output,
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
