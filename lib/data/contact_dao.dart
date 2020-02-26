import 'dart:math';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_complete_guide/helpers/contact_helper.dart';
import 'package:sembast/sembast.dart';
import '../data/app_database.dart';

class ContactDao {
  static const String CONTACTS_STORE_NAME = 'contacts';

  // A Store with int keys and Map<String, dynamic> values.
  // This Store acts like a persistent map, values of which are Contact objects converted to Map
  final _contactStore = stringMapStoreFactory.store(CONTACTS_STORE_NAME);

  // Private getter to shorten the amount of code needed to get the
  // singleton instance of an opened database.
  Future<Database> get _db async => await AppDatabase.instance.database;

  Future insert(Contact contact) async {
    await _contactStore.add(await _db, ContactHelper.toMap(contact));
  }

  Future insertAll(List<Contact> contacts) async {
    List<Map<String, dynamic>> contactsMaps = contacts.map((contact) => ContactHelper.toMap(contact)).toList();
    await _contactStore.addAll(await _db, contactsMaps);

//
//    try {
//      await _contactStore.addAll(await _db, contactsMaps);
//    } catch (e) {
//      contactsMaps.forEach((contactsMap) async => await _contactStore.add(await _db, contactsMap));
//    }
  }

  Future update(Contact contact) async {
    // For filtering by key (ID), RegEx, greater than, and many other criteria,
    // we use a Finder.
    final finder = Finder(filter: Filter.byKey(contact.identifier));
    await _contactStore.update(
      await _db,
      ContactHelper.toMap(contact),
      finder: finder,
    );
  }

  Future delete(Contact contact) async {
    final finder = Finder(filter: Filter.byKey(contact.identifier));
    await _contactStore.delete(
      await _db,
      finder: finder,
    );
  }

  Future clear() async {
    await _contactStore.delete(
      await _db,
    );
  }

  Future<List<Contact>> getAllSortedByName() async {
    // Finder object can also sort data.
    final finder = Finder(sortOrders: [
      SortOrder('displayName'),
    ]);

    final recordSnapshots = await _contactStore.find(
      await _db,
      finder: finder,
    );

    // Making a List<Contact> out of List<RecordSnapshot>
    return recordSnapshots.map((snapshot) {
      final contact = ContactHelper.fromMap(snapshot.value);
      // An ID is a key of a record from the database.
      if (contact.identifier == null || contact.identifier.isEmpty) {
        if (snapshot.value.containsKey('identifier')) {
          contact.identifier = snapshot.value['identifier'];
        } else {
          contact.identifier = snapshot.key.toString();
        }
      }
      return contact;
    }).toList();
  }

}

