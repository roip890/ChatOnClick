import 'package:equatable/equatable.dart';
import 'package:flutter_complete_guide/models/message.dart';

abstract class MessageEvent extends Equatable {
  const MessageEvent();
}

class LoadMessages extends MessageEvent {
  @override
  List<Object> get props => [];
}

class AddMessage extends MessageEvent {
  final Message message;

  const AddMessage(this.message);

  @override
  List<Object> get props => [message];
}

class UpdateMessage extends MessageEvent {
  final Message updatedMessage;

  const UpdateMessage(this.updatedMessage);

  @override
  List<Object> get props => [updatedMessage];
}

class DeleteMessage extends MessageEvent {
  final Message message;

  const DeleteMessage(this.message);

  @override
  List<Object> get props => [message];
}
