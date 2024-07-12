import 'package:permission_handler/permission_handler.dart';

import 'package:testexercice/models/ussdresponse.dart';
import 'package:url_launcher/url_launcher.dart';

class UssdController {
  Future<void> requestPermissions() async {
    var status = await Permission.phone.status;
    if (!status.isGranted) {
      await Permission.phone.request();
    }
  }

  Future<UssdResponse> sendUssdRequest(String code, {required int subscriptionId}) async {
    final startTime = DateTime.now();
    try {
      String ussdCode = "tel:$code";
      if (await canLaunch(ussdCode)) {
        await launch(ussdCode);
        final endTime = DateTime.now();
        final responseTime = endTime.difference(startTime);
        return UssdResponse(response: 'Request Sent', responseTime: responseTime);
      } else {
        throw 'Could not launch $ussdCode';
      }
    } catch (e) {
      final endTime = DateTime.now();
      final responseTime = endTime.difference(startTime);
      return UssdResponse(response: 'Error: $e', responseTime: responseTime);
    }
  }

  Future<List<UssdResponse>> sendMultipleUssdRequests(String code, int count, {required int subscriptionId}) async {
    List<UssdResponse> responses = [];
    for (int i = 0; i < count; i++) {
      UssdResponse response = await sendUssdRequest(code, subscriptionId: subscriptionId);
      responses.add(response);
    }
    return responses;
  }
  
}
