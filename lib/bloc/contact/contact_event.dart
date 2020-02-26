import 'package:equatable/equatable.dart';
import 'package:contacts_service/contacts_service.dart';

abstract class ContactEvent extends Equatable {
  const ContactEvent();
}

class FetchContacts extends ContactEvent {
  @override
  List<Object> get props => [];
}

class LoadContacts extends ContactEvent {
  @override
  List<Object> get props => [];
}

class AddContact extends ContactEvent {
  final Contact contact;

  const AddContact(this.contact);

  @override
  List<Object> get props => [contact];
}

class UpdateContact extends ContactEvent {
  final Contact updatedContact;

  const UpdateContact(this.updatedContact);

  @override
  List<Object> get props => [updatedContact];
}

class DeleteContact extends ContactEvent {
  final Contact contact;

  const DeleteContact(this.contact);

  @override
  List<Object> get props => [contact];
}
