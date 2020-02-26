import 'dart:convert';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_complete_guide/models/phone_number.dart';
import 'package:http/http.dart' as http;

class PhoneContact extends Contact {

  // Id will be gotten from the database.
  // It's automatically generated & unique for every stored Message.
  int id;

  PhoneContact.fromMap(Map m) {
    identifier = m["identifier"];
    displayName = m["displayName"];
    givenName = m["givenName"];
    middleName = m["middleName"];
    familyName = m["familyName"];
    prefix = m["prefix"];
    suffix = m["suffix"];
    company = m["company"];
    jobTitle = m["jobTitle"];
    androidAccountTypeRaw = m["androidAccountType"];
    androidAccountType = accountTypeFromString(androidAccountTypeRaw);
    androidAccountName = m["androidAccountName"];
    emails = (m["emails"] as Iterable)?.map((m) => Item.fromMap(m));
    phones = (m["phones"] as Iterable)?.map((m) => Item.fromMap(m));
    postalAddresses = (m["postalAddresses"] as Iterable)
        ?.map((m) => PostalAddress.fromMap(m));
//    avatar = m["avatar"];
    try {
      birthday = DateTime.parse(m["birthday"]);
    } catch (e) {
      birthday = null;
    }
  }

}
