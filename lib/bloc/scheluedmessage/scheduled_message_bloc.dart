import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:launcher/launcher.dart';
import 'package:workmanager/workmanager.dart';
import './scheduled_message_event.dart';
import '../../models/message.dart';
import './scheduled_message_state.dart';
import '../../data/scheduled_message_dao.dart';
import '../bloc.dart';

class ScheduledMessageBloc extends Bloc<ScheduledMessageEvent, ScheduledMessageState> {

  ScheduledMessageDao _scheduledMessageDao = ScheduledMessageDao();

  @override
  ScheduledMessageState get initialState => ScheduledMessagesUninitialized();

  // This is where we place the logic.
  @override
  Stream<ScheduledMessageState> mapEventToState(ScheduledMessageEvent event,) async* {
    final currentState = state;
    if (event is LoadScheduledMessages && !_hasReachedMax(currentState)) {

      try {
        if (currentState is ScheduledMessagesUninitialized) {
          final scheduledMessages = await _fetchScheduledMessages(0, 20);
          yield ScheduledMessagesLoaded(scheduledMessages: scheduledMessages, hasReachedMax: false);
          return;
        }
        if (currentState is ScheduledMessagesLoaded) {
          final scheduledMessages = await _fetchScheduledMessages(currentState.scheduledMessages.length, 20);
          yield scheduledMessages.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : ScheduledMessagesLoaded(
                scheduledMessages: currentState.scheduledMessages + scheduledMessages,
                hasReachedMax: false,
              );
        }
      } catch (e) {
        yield ScheduledMessagesError(e.toString());
      }

    } else if (event is AddScheduledMessage) {

      try {
        int id = await _scheduledMessageDao.insert(event.scheduledMessage);
        if (DateTime.now().isBefore(event.scheduledMessage.timestamp)) {
          Workmanager.registerOneOffTask(
              id.toString(),
              'sendWhatsapp',
              initialDelay: event.scheduledMessage.timestamp.difference(
                DateTime.now()
              ),
              inputData: {
                'number': event.scheduledMessage.phoneNumber.formatted,
                'message': event.scheduledMessage.content
              },
              constraints: Constraints(
                  requiresBatteryNotLow: false,
                  requiresCharging: false,
                  requiresDeviceIdle: false,
                  requiresStorageNotLow: false
              )
          );
        }
        final scheduledMessages = await _fetchScheduledMessages(0, 20);
        yield ScheduledMessagesLoaded(scheduledMessages: scheduledMessages, hasReachedMax: false);
      } catch(e) {
        yield ScheduledMessagesError(e.toString());
      }

    } else if (event is UpdateScheduledMessage) {
      try {
        await _scheduledMessageDao.update(event.updatedScheduledMessage);
        Workmanager.cancelByTag(event.updatedScheduledMessage.id.toString());
        if (DateTime.now().isBefore(event.updatedScheduledMessage.timestamp)) {
          Workmanager.registerOneOffTask(
              event.updatedScheduledMessage.id.toString(),
              'sendWhatsapp',
              initialDelay: event.updatedScheduledMessage.timestamp.difference(
                  DateTime.now()
              ),
              inputData: {
                'number': event.updatedScheduledMessage.phoneNumber.formatted,
                'message': event.updatedScheduledMessage.content
              },
              constraints: Constraints(
                  networkType: NetworkType.connected,
                  requiresBatteryNotLow: false,
                  requiresCharging: false,
                  requiresDeviceIdle: false,
                  requiresStorageNotLow: false
              )
          );
        }
        final scheduledMessages = await _fetchScheduledMessages(0, 20);
        yield ScheduledMessagesLoaded(scheduledMessages: scheduledMessages, hasReachedMax: false);
      } catch(e) {
        yield ScheduledMessagesError(e.toString());
      }

    } else if (event is DeleteScheduledMessage) {

      try {
        await _scheduledMessageDao.delete(event.scheduledMessage);
//        await AndroidAlarmManager.cancel(event.scheduledMessage.id);
        final scheduledMessages = await _fetchScheduledMessages(0, 20);
        yield ScheduledMessagesLoaded(scheduledMessages: scheduledMessages, hasReachedMax: false);
      } catch(e) {
        yield ScheduledMessagesError(e.toString());
      }

    }
  }

  Future<List<Message>>  _fetchScheduledMessages(int startIndex, int limit) async {
    final scheduledMessages = await _scheduledMessageDao.getAllSortedByTimestamp(startIndex, limit);
    scheduledMessages.forEach((scheduledMessage) async {
      try {
        Workmanager.cancelByTag(scheduledMessage.id.toString());
        if (DateTime.now().isBefore(scheduledMessage.timestamp)) {
          Workmanager.registerOneOffTask(
            scheduledMessage.id.toString(),
            'sendWhatsapp',
              initialDelay: scheduledMessage.timestamp.difference(
                  DateTime.now()
              ),
            inputData: {
              'number': scheduledMessage.phoneNumber.formatted,
              'message': scheduledMessage.content
            },
            constraints: Constraints(
                networkType: NetworkType.connected,
                requiresBatteryNotLow: false,
                requiresCharging: false,
                requiresDeviceIdle: false,
                requiresStorageNotLow: false
            ),
          );
        }
      } catch (e) {
        print(e);
      }
    });
    return scheduledMessages;
  }

  bool _hasReachedMax(ScheduledMessageState state) =>
      state is ScheduledMessagesLoaded && state.hasReachedMax;

}
