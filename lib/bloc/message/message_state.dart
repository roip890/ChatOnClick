import 'package:equatable/equatable.dart';
import '../../models/message.dart';

abstract class MessageState extends Equatable {
  const MessageState();
}

class MessagesUninitialized extends MessageState {
  const MessagesUninitialized();
  @override
  List<Object> get props => [];
}

class MessagesError extends MessageState {
  final String errorMessage;
  const MessagesError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];

  @override
  String toString() =>
      'MessagesError { errorMessage: $errorMessage }';

}

class MessagesLoaded extends MessageState {

  final List<Message> messages;
  final bool hasReachedMax;

  const MessagesLoaded({
    this.messages,
    this.hasReachedMax,
  });

  MessagesLoaded copyWith({
    List<Message> messages,
    bool hasReachedMax,
  }) {
    return MessagesLoaded(
      messages: messages ?? this.messages,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [messages, hasReachedMax];

  @override
  String toString() =>
      'MessagesLoaded { messages: ${messages.length}, hasReachedMax: $hasReachedMax }';

}
