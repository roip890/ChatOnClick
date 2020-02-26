import 'package:contacts_service/contacts_service.dart';
import 'package:equatable/equatable.dart';

abstract class ContactState extends Equatable {
  const ContactState();
}

class ContactsUninitialized extends ContactState {
  const ContactsUninitialized();
  @override
  List<Object> get props => [];
}

class ContactsError extends ContactState {
  final String errorContact;
  const ContactsError(this.errorContact);

  @override
  List<Object> get props => [errorContact];

  @override
  String toString() =>
      'ContactsError { errorContact: $errorContact }';

}

class ContactsSnapshotLoaded extends ContactState {

  final List<Contact> contacts;

  const ContactsSnapshotLoaded({
    this.contacts,
  });

  ContactsSnapshotLoaded copyWith({
    List<Contact> contacts,
  }) {
    return ContactsSnapshotLoaded(
      contacts: contacts ?? this.contacts,
    );
  }

  @override
  List<Object> get props => [contacts];

  @override
  String toString() =>
      'ContactsSnapshotLoaded { contacts: ${contacts.length} }';

}

class ContactsLoaded extends ContactState {

  final List<Contact> contacts;

  const ContactsLoaded({
    this.contacts,
  });

  ContactsLoaded copyWith({
    List<Contact> contacts,
  }) {
    return ContactsLoaded(
      contacts: contacts ?? this.contacts,
    );
  }

  @override
  List<Object> get props => [contacts];

  @override
  String toString() =>
      'ContactsLoaded { contacts: ${contacts.length} }';

}