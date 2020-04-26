import 'package:equatable/equatable.dart';
import '../../models/message.dart';

abstract class ScheduledMessageState extends Equatable {
  const ScheduledMessageState();
}

class ScheduledMessagesUninitialized extends ScheduledMessageState {
  const ScheduledMessagesUninitialized();
  @override
  List<Object> get props => [];
}

class ScheduledMessagesError extends ScheduledMessageState {
  final String errorScheduledMessage;
  const ScheduledMessagesError(this.errorScheduledMessage);

  @override
  List<Object> get props => [errorScheduledMessage];

  @override
  String toString() =>
      'ScheduledMessagesError { errorScheduledMessage: $errorScheduledMessage }';

}

class ScheduledMessagesLoaded extends ScheduledMessageState {

  final List<Message> scheduledMessages;
  final bool hasReachedMax;

  const ScheduledMessagesLoaded({
    this.scheduledMessages,
    this.hasReachedMax,
  });

  ScheduledMessagesLoaded copyWith({
    List<Message> scheduledMessages,
    bool hasReachedMax,
  }) {
    return ScheduledMessagesLoaded(
      scheduledMessages: scheduledMessages ?? this.scheduledMessages,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [scheduledMessages, hasReachedMax];

  @override
  String toString() =>
      'ScheduledMessagesLoaded { scheduledMessages: ${scheduledMessages.length}, hasReachedMax: $hasReachedMax }';

}
