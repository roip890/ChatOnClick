import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_complete_guide/bloc/message/message_event.dart';
import 'package:flutter_complete_guide/bloc/scheluedmessage/scheduled_message_bloc.dart';
import 'package:flutter_complete_guide/bloc/scheluedmessage/scheduled_message_event.dart';
import 'package:flutter_complete_guide/bloc/scheluedmessage/scheduled_message_state.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import '../widgets/message_list_item.dart';

import '../bloc/message/message_bloc.dart';
import '../bloc/message/message_state.dart';
import '../models/message.dart';
import '../widgets/list_bottom_loader.dart';
import '../screens/messages_screen.dart';

class ScheduledMessagesScreen extends StatefulWidget {
  static const routeName = '/scheduledMessages';

  @override
  _ScheduledMessagesScreenState createState() => _ScheduledMessagesScreenState();
}

class _ScheduledMessagesScreenState extends State<ScheduledMessagesScreen> {
  final _scrollController = ScrollController();
  final _scrollThreshold = 200.0;
  ScheduledMessageBloc _scheduledMessageBloc;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _scheduledMessageBloc = BlocProvider.of<ScheduledMessageBloc>(context);
    _scheduledMessageBloc.add(LoadScheduledMessages());
  }


  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).accentColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          BlocBuilder<ScheduledMessageBloc, ScheduledMessageState>(
            builder: (context, state) {
              if (state is ScheduledMessagesUninitialized) {
                return _buildLoading();
              }
              if (state is ScheduledMessagesError) {
                return _buildError();
              }
              if (state is ScheduledMessagesLoaded) {
                if (state.scheduledMessages.isEmpty) {
                  return _buildEmptyList();
                }
                return _buildMessagesList(state.scheduledMessages, state.hasReachedMax);
              }
              return _buildEmptyList();
            },
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        marginRight: 20,
        marginBottom: 20,
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),
        visible: true,
        closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        tooltip: 'Menu',
        backgroundColor: Theme.of(context).accentColor,
        foregroundColor: Colors.black,
        elevation: 8.0,
        shape: CircleBorder(),
        children: [
          SpeedDialChild(
            child: Icon(Icons.home),
            backgroundColor: Theme.of(context).accentColor,
            label: 'Home',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => Navigator.of(context)
                .pop(),
          ),
          SpeedDialChild(
            child: Icon(Icons.message),
            backgroundColor: Theme.of(context).accentColor,
            label: 'Messages',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => Navigator.of(context)
                .pushReplacementNamed(MessagesScreen.routeName),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Text('failed to fetch messages'),
    );
  }

  Widget _buildEmptyList() {
    return Center(
      child: Text('no messages'),
    );
  }

  Widget _buildMessagesList(List<Message> messages, bool hasReachedMax) {
    return BlocProvider.value(
      value: BlocProvider.of<MessageBloc>(context),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15.0),
        child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return MessageListItem(message: messages[index], isScheduled: true,);
          },
          itemCount: messages.length,
          controller: _scrollController,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      _scheduledMessageBloc.add(LoadScheduledMessages());
    }
  }
}
