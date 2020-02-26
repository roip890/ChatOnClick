import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class MessagePhoneNumber with ChangeNotifier {

  final String prefix;
  final String number;
  final String formatted;

  MessagePhoneNumber({
    @required this.prefix,
    @required this.number,
    @required this.formatted,
  });

  Map<String, dynamic> toMap() {
    return {
      'prefix': prefix,
      'number': number,
      'formatted': formatted,
    };
  }

  static MessagePhoneNumber fromMap(Map<String, dynamic> map) {
    return MessagePhoneNumber(
      prefix: map['prefix'],
      number: map['number'],
      formatted: map['formatted'],
    );
  }

}
