import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/message/message_bloc.dart';
import '../models/message.dart';
import '../bloc/message/message_event.dart';

class MessageListItem extends StatelessWidget {
  final Message message;

  MessageListItem({Key key, @required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        Provider.of<MessageBloc>(context, listen: false).add(DeleteMessage(message));
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(5.0),
                    child: message.contact != null
                        ? Row(
                      children: <Widget>[
                        Icon(
                          Icons.contact_phone,
                          color: Theme.of(context).primaryColor,
                          size: Theme.of(context).textTheme.title.fontSize,
                        ),
                        SizedBox(
                          width: 5,
                        ),
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
                  Container(
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

    // go to send message
    try {
      if (message != null && message.phoneNumber != null && message.phoneNumber.formatted != null) {
        final url = 'https://api.whatsapp.com/send?phone=${message.phoneNumber.formatted}'
            + (message != null && message.content != null && message.content.isNotEmpty ? '&text=${message.content}': '');
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

    return false;
  }

  Future<bool> _onDeleteSwipe(BuildContext context) async {
    return showDialog(
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
              Navigator.of(ctx).pop(false);
            },
          ),
          FlatButton(
            child: Text('Yes'),
            onPressed: () {
              Navigator.of(ctx).pop(true);
            },
          ),
        ],
      ),
    );
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
