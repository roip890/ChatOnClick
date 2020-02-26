import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:contacts_service/contacts_service.dart';
import './contact_state.dart';
import '../../data/contact_dao.dart';
import '../bloc.dart';
import './contact_event.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {

  ContactDao _contactDao = ContactDao();

  @override
  ContactState get initialState => ContactsUninitialized();

  // This is where we place the logic.
  @override
  Stream<ContactState> mapEventToState(ContactEvent event,) async* {
    final currentState = state;
    if (event is LoadContacts) {

      try {
        if (currentState is ContactsUninitialized) {
          final contacts = await _fetchSnapshotContacts();
          yield ContactsSnapshotLoaded(contacts: contacts);
        } else if (currentState is ContactsSnapshotLoaded || currentState is ContactsLoaded) {
          final contacts = await _fetchContacts();
          yield ContactsLoaded(contacts: contacts);
        }
      } catch (e) {
        yield ContactsError(e.toString());
      }

    } else if (event is AddContact) {

      try {
        await _contactDao.insert(event.contact);
        final contacts = await _fetchContacts();
        yield ContactsLoaded(contacts: contacts);
      } catch(e) {
        yield ContactsError(e.toString());
      }

    } else if (event is UpdateContact) {

      try {
        await _contactDao.update(event.updatedContact);
        final contacts = await _fetchContacts();
        yield ContactsLoaded(contacts: contacts);
      } catch(e) {
        yield ContactsError(e.toString());
      }

    } else if (event is DeleteContact) {

      try {
        await _contactDao.update(event.contact);
        final contacts = await _fetchContacts();
        yield ContactsLoaded(contacts: contacts);
      } catch(e) {
        yield ContactsError(e.toString());
      }

    }
  }

  Future<List<Contact>>  _fetchContacts() async {
//    final contacts = await _contactDao.getAllContacts();
    final Iterable<Contact> contacts = await ContactsService.getContacts(withThumbnails: false);
    await _contactDao.clear();
    await _contactDao.insertAll(contacts.toList());
    return contacts.toList();
  }

  Future<List<Contact>>  _fetchSnapshotContacts() async {
//    final contacts = await _contactDao.getAllContacts();
    final contacts = await _contactDao.getAllSortedByName();
    return contacts;
  }


}
