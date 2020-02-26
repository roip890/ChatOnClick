import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../models/message.dart';
import './message_state.dart';
import '../../data/message_dao.dart';
import '../bloc.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {

  MessageDao _messageDao = MessageDao();

  @override
  MessageState get initialState => MessagesUninitialized();

  // This is where we place the logic.
  @override
  Stream<MessageState> mapEventToState(MessageEvent event,) async* {
    final currentState = state;
    if (event is LoadMessages && !_hasReachedMax(currentState)) {

      try {
        if (currentState is MessagesUninitialized) {
          final messages = await _fetchMessages(0, 20);
          yield MessagesLoaded(messages: messages, hasReachedMax: false);
          return;
        }
        if (currentState is MessagesLoaded) {
          final messages = await _fetchMessages(currentState.messages.length, 20);
          yield messages.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : MessagesLoaded(
                messages: currentState.messages + messages,
                hasReachedMax: false,
              );
        }
      } catch (e) {
        yield MessagesError(e.toString());
      }

    } else if (event is AddMessage) {

      try {
        await _messageDao.insert(event.message);
        final messages = await _fetchMessages(0, 20);
        yield MessagesLoaded(messages: messages, hasReachedMax: false);
      } catch(e) {
        yield MessagesError(e.toString());
      }

    } else if (event is UpdateMessage) {

      try {
        await _messageDao.update(event.updatedMessage);
        final messages = await _fetchMessages(0, 20);
        yield MessagesLoaded(messages: messages, hasReachedMax: false);
      } catch(e) {
        yield MessagesError(e.toString());
      }

    } else if (event is DeleteMessage) {

      try {
        await _messageDao.delete(event.message);
        final messages = await _fetchMessages(0, 20);
        yield MessagesLoaded(messages: messages, hasReachedMax: false);
      } catch(e) {
        yield MessagesError(e.toString());
      }

    }
  }

  Future<List<Message>>  _fetchMessages(int startIndex, int limit) async {
    final messages = await _messageDao.getAllSortedByTimestamp(startIndex, limit);
    return messages;
  }

  bool _hasReachedMax(MessageState state) =>
      state is MessagesLoaded && state.hasReachedMax;



}
