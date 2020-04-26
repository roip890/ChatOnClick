import 'dart:async';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class AppDatabase {
  // Singleton instance
  static final AppDatabase _singleton = AppDatabase._();

  // Singleton accessor
  static AppDatabase get instance => _singleton;

  // Completer is used for transforming synchronous code into asynchronous code.
  Completer<Database> _dbOpenCompleter;

  // A private constructor. Allows us to create instances of AppDatabase
  // only from within the AppDatabase class itself.
  AppDatabase._();

  // Database object accessor
  Future<Database> get database async {
    // If completer is null, AppDatabaseClass is newly instantiated, so database is not yet opened
    if (_dbOpenCompleter == null) {
      _dbOpenCompleter = Completer();
      // Calling _openDatabase will also complete the completer with database instance
      _openDatabase();
    }
    // If the database is already opened, awaiting the future will happen instantly.
    // Otherwise, awaiting the returned future will take some time - until complete() is called
    // on the Completer in _openDatabase() below.
    return _dbOpenCompleter.future;
  }

  Future _openDatabase() async {
    // Get a platform-specific directory where persistent app data can be stored
    final appDocumentDir = await getApplicationDocumentsDirectory();
    // Path with the form: /platform-specific-directory/demo.db
    final dbPath = join(appDocumentDir.path, 'chat_on_click.db');
    var messagesStore = intMapStoreFactory.store("messages");
    var scheduledMessagesStore = intMapStoreFactory.store("scheduled_messages");
    var contactsStore = intMapStoreFactory.store("contacts");
//    final database = await databaseFactoryIo.openDatabase(dbPath);
    final database = await databaseFactoryIo.openDatabase(dbPath, version: 1,
        onVersionChanged: (Database db, int oldVersion, int newVersion) async {
          // if (oldVersion == 1) {
//          await messagesStore.delete(db);
          // }
        });
//    await messagesStore.delete(database);
//    await contactsStore.delete(database);

    // Any code awaiting the Completer's future will now start executing
    _dbOpenCompleter.complete(database);
  }
}
