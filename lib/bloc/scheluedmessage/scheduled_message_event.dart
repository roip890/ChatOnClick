import 'package:equatable/equatable.dart';
import 'package:flutter_complete_guide/models/message.dart';

abstract class ScheduledMessageEvent extends Equatable {
  const ScheduledMessageEvent();
}

class LoadScheduledMessages extends ScheduledMessageEvent {
  @override
  List<Object> get props => [];
}

class AddScheduledMessage extends ScheduledMessageEvent {
  final Message scheduledMessage;

  const AddScheduledMessage(this.scheduledMessage);

  @override
  List<Object> get props => [scheduledMessage];
}

class UpdateScheduledMessage extends ScheduledMessageEvent {
  final Message updatedScheduledMessage;

  const UpdateScheduledMessage(this.updatedScheduledMessage);

  @override
  List<Object> get props => [updatedScheduledMessage];
}

class DeleteScheduledMessage extends ScheduledMessageEvent {
  final Message scheduledMessage;

  const DeleteScheduledMessage(this.scheduledMessage);

  @override
  List<Object> get props => [scheduledMessage];
}
