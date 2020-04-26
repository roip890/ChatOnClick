import 'dart:async';
import 'package:flutter/services.dart';

class Launcher {
  static const MethodChannel _channel = const MethodChannel('com.aptenobytes/launcher_plugin');

  static Future<bool> sendWhatsappMessage({String number = '', String message = ''}) async {
    print('sendWhatsappMessage ' + DateTime.now().toIso8601String());
    return await _channel.invokeMethod('sendWhatsappMessage',{
      'number' : number,
      'message' : message + 'Sent by Chat On Click',
    });
//    print('sendWhatsappMessage ' + DateTime.now().toIso8601String());
//    return await _channel.invokeMethod('launch',{});
  }

  static void printWhatsapp() {
    print('WhatsappSchedule!! ' + DateTime.now().toIso8601String());
  }

}
