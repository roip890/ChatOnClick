import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_complete_guide/bloc/scheluedmessage/scheduled_message_bloc.dart';
import 'package:flutter_complete_guide/bloc/scheluedmessage/scheduled_message_event.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/message/message_bloc.dart';
import '../models/message.dart';
import '../bloc/message/message_event.dart';

enum DialogResult {
  Cancel,
  Confirm,
  Send,
  Schedule
}

class MessageListItem extends StatelessWidget {
  final Message message;
  final bool isScheduled;
  ScheduledMessageBloc _scheduledMessageBloc;

  MessageListItem({Key key, @required this.message, @required this.isScheduled}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _scheduledMessageBloc = BlocProvider.of<ScheduledMessageBloc>(context);
    _scheduledMessageBloc.add(LoadScheduledMessages());

    return Dismissible(
      key: ValueKey(message.id),
      background: _buildDeleteSwipeBackground(context),
      secondaryBackground: _buildSendSwipeBackground(context),
      confirmDismiss: (direction) {
        if (direction == DismissDirection.endToStart) {
          return _onSendSwipe(context);
        } else if (direction == DismissDirection.startToEnd) {
          return _onDeleteSwipe(context);
        }
        return _dummyBoolFuture(false);
      },
      onDismissed: (direction) {
        isScheduled
            ? BlocProvider.of<ScheduledMessageBloc>(context).add(DeleteScheduledMessage(message))
            : BlocProvider.of<MessageBloc>(context).add(DeleteMessage(message));
      },
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(5.0),
                      child: message.contact != null
                          ? Row(
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                message.contact.displayName,
                                style: Theme.of(context).textTheme.title,
                              ),
                              Text(
                                '(${message.phoneNumber.formatted})',
                                style: Theme.of(context).textTheme.title,
                              ),
                            ],
                          )
                        ],
                      )
                          : Text(
                        message.phoneNumber.formatted,
                        style: Theme.of(context).textTheme.title,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(5.0),
                      child: Text(
                        message.content,
                        style: Theme.of(context).textTheme.subtitle,
                      ),
                    ),
                    isScheduled
                    ? Container(
                  padding: EdgeInsets.all(5.0),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.timer,
                        color: Theme.of(context).primaryColor,
                        size: Theme.of(context).textTheme.subtitle.fontSize,
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy hh:mm').format(message.timestamp),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontStyle: FontStyle.italic,
                          fontSize: Theme.of(context).textTheme.subtitle.fontSize,
                          fontFamily: Theme.of(context).textTheme.subtitle.fontFamily,
                          fontFamilyFallback: Theme.of(context).textTheme.subtitle.fontFamilyFallback,
                          fontFeatures: Theme.of(context).textTheme.subtitle.fontFeatures,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
                    : Container(
                      padding: EdgeInsets.all(5.0),
                      child: Text(
                        DateFormat('dd/MM/yyyy hh:mm').format(message.timestamp),
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                          fontSize: Theme.of(context).textTheme.subtitle.fontSize,
                          fontFamily: Theme.of(context).textTheme.subtitle.fontFamily,
                          fontFamilyFallback: Theme.of(context).textTheme.subtitle.fontFamilyFallback,
                          fontFeatures: Theme.of(context).textTheme.subtitle.fontFeatures,
                          fontWeight: Theme.of(context).textTheme.subtitle.fontWeight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(5.0),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteSwipeBackground(BuildContext context) {
    return Container(
      color: Theme.of(context).errorColor,
      child: Icon(
        Icons.delete,
        color: Colors.white,
        size: 30,
      ),
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: 20),
      margin: EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 4,
      ),
    );
  }

  Widget _buildSendSwipeBackground(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Icon(
        Icons.send,
        color: Colors.white,
        size: 30,
      ),
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20),
      margin: EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 4,
      ),
    );
  }

  Future<bool> _onSendSwipe(BuildContext context) async {

    DialogResult result = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text(
          'Do you want to send this message?',
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(ctx).pop(DialogResult.Cancel);
            },
          ),
          FlatButton(
            child: Text('Send'),
            onPressed: () {
              Navigator.of(ctx).pop(DialogResult.Send);
            },
          ),
          FlatButton(
            child: Text('Schedule'),
            onPressed: () {
              Navigator.of(ctx).pop(DialogResult.Schedule);
            },
          ),
        ],
      ),
    );

    if (result == DialogResult.Send) {
      await _onSendMessage(context);
    } else if (result == DialogResult.Schedule) {
      await _onScheduleMessage(context);
    }

    return false;

  }

  Future<void> _onScheduleMessage(BuildContext context) async {

    // go to send message
    try {

      final date = await showDatePicker(
          context: context,
          firstDate: DateTime.now(),
          initialDate: DateTime.now(),
          lastDate: DateTime(2030));
      if (date != null) {
        final time = await showTimePicker(
          context: context,
          initialTime:
          TimeOfDay.fromDateTime(DateTime.now()),
        );
        DateTime pickedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        Message scheduledMessage = Message(
            contact: message.contact,
            content: message.content,
            phoneNumber: message.phoneNumber,
            timestamp: pickedDateTime
        );

        _scheduledMessageBloc.add(AddScheduledMessage(scheduledMessage));

      }

    } catch (error) {
      _showErrorDialog(context, 'Failed to send message');
    }

  }

  Future<void> _onSendMessage(BuildContext context) async {

    // go to send message
    try {
      if (message != null && message.phoneNumber != null && message.phoneNumber.formatted != null) {
        final url = 'https://api.whatsapp.com/send?phone=${message.phoneNumber.formatted}'
            + (message != null && message.content != null && message.content.isNotEmpty ? '&text=${message.content}': '')
            + '\nSent by Chat On Click';
        print(url);
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          _showErrorDialog(context, 'Failed to send message');
        }
      }

    } catch (error) {
      _showErrorDialog(context, 'Failed to send message');
    }

  }

  Future<bool> _onDeleteSwipe(BuildContext context) async {
    DialogResult result = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text(
          'Do you want to delete this message?',
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('No'),
            onPressed: () {
              Navigator.of(ctx).pop(DialogResult.Cancel);
            },
          ),
          FlatButton(
            child: Text('Yes'),
            onPressed: () {
              Navigator.of(ctx).pop(DialogResult.Confirm);
            },
          ),
        ],
      ),
    );

    return result == DialogResult.Confirm;
  }

  Future<bool> _dummyBoolFuture(bool futureResult) async {
    return futureResult;
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

}
