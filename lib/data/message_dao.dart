import 'dart:math';

import 'package:sembast/sembast.dart';
import '../data/app_database.dart';
import '../models/message.dart';

class MessageDao {
  static const String MESSAGE_STORE_NAME = 'messages';

  // A Store with int keys and Map<String, dynamic> values.
  // This Store acts like a persistent map, values of which are Message objects converted to Map
  final _messageStore = intMapStoreFactory.store(MESSAGE_STORE_NAME);

  // Private getter to shorten the amount of code needed to get the
  // singleton instance of an opened database.
  Future<Database> get _db async => await AppDatabase.instance.database;

  Future insert(Message message) async {
    await _messageStore.add(await _db, message.toMap());
  }

  Future update(Message message) async {
    // For filtering by key (ID), RegEx, greater than, and many other criteria,
    // we use a Finder.
    final finder = Finder(filter: Filter.byKey(message.id));
    await _messageStore.update(
      await _db,
      message.toMap(),
      finder: finder,
    );
  }

  Future delete(Message message) async {
    final finder = Finder(filter: Filter.byKey(message.id));
    await _messageStore.delete(
      await _db,
      finder: finder,
    );
  }

  Future<List<Message>> getAllSortedByTimestamp(int startIndex, int limit) async {
    // Finder object can also sort data.
    final finder = Finder(sortOrders: [
      SortOrder('timestamp'),
    ]);

    final recordSnapshots = await _messageStore.find(
      await _db,
      finder: finder,
    );

    // Making a List<Message> out of List<RecordSnapshot>
    return recordSnapshots.map((snapshot) {
      final message = Message.fromMap(snapshot.value);
      // An ID is a key of a record from the database.
      message.id = snapshot.key;
      return message;
    }).toList().sublist(startIndex, min(startIndex + limit, recordSnapshots.length));
  }
}
