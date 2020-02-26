import 'dart:typed_data';
import 'package:contacts_service/contacts_service.dart';

class ContactHelper {

  static Map<String, dynamic> toMap(Contact contact) {

    final Map<String, dynamic> map = Map<String, dynamic>();
    final Map contactMap = contact.toMap();

    contactMap.forEach((key, value) {
      map[key.toString()] = value;
    });

    return map;

  }

  static Contact fromMap(Map<String, dynamic> map) {

    String identifier = map["identifier"];
    String displayName = map["displayName"];
    String givenName = map["givenName"];
    String middleName = map["middleName"];
    String familyName = map["familyName"];
    String prefix = map["prefix"];
    String suffix = map["suffix"];
    String company = map["company"];
    String jobTitle = map["jobTitle"];
    String androidAccountTypeRaw = map["androidAccountType"];
    String androidAccountName = map["androidAccountName"];
    AndroidAccountType androidAccountType = ContactHelper.accountTypeFromString(androidAccountTypeRaw);
    Iterable<Item> emails = (map["emails"] as Iterable)?.map((m) => Item.fromMap(m));
    Iterable<Item> phones = (map["phones"] as Iterable)?.map((m) => Item.fromMap(m));
    Iterable<PostalAddress> postalAddresses = (map["postalAddresses"] as Iterable)
        ?.map((m) => PostalAddress.fromMap(m));
//    Uint8List avatar = map["avatar"];
    DateTime birthday = null;
    try {
      birthday = DateTime.parse(map["birthday"]);
    } catch (e) {
      birthday = null;
    }

    Contact contact = Contact(
      displayName: displayName,
      givenName: givenName,
      middleName: middleName,
      prefix: prefix,
      suffix: suffix,
      familyName: familyName,
      company: company,
      jobTitle: jobTitle,
      emails: emails,
      phones: phones,
      postalAddresses: postalAddresses,
//      avatar,
      birthday: birthday,
      androidAccountType: androidAccountType,
      androidAccountTypeRaw: androidAccountTypeRaw,
      androidAccountName: androidAccountName,
    );
    contact.identifier = identifier;
    return contact;

  }

  static AndroidAccountType accountTypeFromString(String androidAccountType) {
    if (androidAccountType == null) {
      return null;
    }
    if (androidAccountType.startsWith("com.google")) {
      return AndroidAccountType.google;
    } else if (androidAccountType.startsWith("com.whatsapp")) {
      return AndroidAccountType.whatsapp;
    } else if (androidAccountType.startsWith("com.facebook")) {
      return AndroidAccountType.facebook;
    }
    /// Other account types are not supported on Android
    /// such as Samsung, htc etc...
    return AndroidAccountType.other;
  }


}
