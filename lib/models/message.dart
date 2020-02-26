import 'dart:convert';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_complete_guide/helpers/contact_helper.dart';
import 'package:flutter_complete_guide/models/phone_number.dart';
import 'package:http/http.dart' as http;

class Message {

  // Id will be gotten from the database.
  // It's automatically generated & unique for every stored Message.
  int id;

  final MessagePhoneNumber phoneNumber;
  final String content;
  final DateTime timestamp;
  final Contact contact;

  Message({
    @required this.phoneNumber,
    @required this.content,
    @required this.timestamp,
    @required this.contact,
  });

  Map<String, dynamic> toMap() {
    return {
      'phoneNumber': phoneNumber.toMap(),
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'contact': contact != null ? ContactHelper.toMap(contact) : null,
    };
  }

  static Message fromMap(Map<String, dynamic> map) {
    return Message(
      phoneNumber: MessagePhoneNumber.fromMap(map['phoneNumber']),
      content: map['content'],
      timestamp: DateTime.parse(map['timestamp']),
      contact: map['contact'] != null ? ContactHelper.fromMap(map['contact']) : null,
    );
  }

}
