import 'package:flutter/material.dart';

import 'package:testexercice/controllers/ussdcontrol.dart';


import 'package:testexercice/models/ussdresponse.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _ussdCodeController = TextEditingController();
  String _ussdResponse = '';
  UssdController _ussdController = UssdController();
  int _subscriptionId = 1; // Default subscription ID for SIM card

  @override
  void initState() {
    super.initState();
    _ussdController.requestPermissions();
    _setDefaultSimForMTN();
  }

  Future<void> _setDefaultSimForMTN() async {
    String simCountryCode = await FlutterSimCountryCode.simCountryCode;
    if (simCountryCode == 'CM') { // Assuming 'CM' for Cameroon (MTN)
      setState(() {
        _subscriptionId = 1; // Update as per actual MTN SIM slot
      });
    }
  }

  void _sendUssdRequest() async {
    final startTime = DateTime.now();
    UssdResponse response = await _ussdController.sendUssdRequest(_ussdCodeController.text, subscriptionId: _subscriptionId);
    final endTime = DateTime.now();
    final responseTime = endTime.difference(startTime);

    setState(() {
      _ussdResponse = '${response.response}\nTime: ${responseTime.inMilliseconds} ms';
    });
  }

  void _sendMultipleUssdRequests() async {
    setState(() {
      _ussdResponse = '';
    });
    List<UssdResponse> responses = await _ussdController.sendMultipleUssdRequests(_ussdCodeController.text, 1000, subscriptionId: _subscriptionId);
    setState(() {
      for (int i = 0; i < responses.length; i++) {
        _ussdResponse += 'Request $i: ${responses[i].response} (Time: ${responses[i].responseTime.inMilliseconds} ms)\n';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('USSD App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _ussdCodeController,
              decoration: InputDecoration(
                labelText: 'Enter USSD Code',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendUssdRequest,
              child: Text('Send USSD Request'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Response:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _ussdResponse,
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FlutterSimCountryCode {
  static var simCountryCode;
}
