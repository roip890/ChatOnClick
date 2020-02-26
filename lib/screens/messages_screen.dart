import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_complete_guide/bloc/message/message_event.dart';
import 'package:provider/provider.dart';
import '../widgets/message_list_item.dart';

import '../bloc/message/message_bloc.dart';
import '../bloc/message/message_state.dart';
import '../models/message.dart';
import '../widgets/list_bottom_loader.dart';

class MessagesScreen extends StatefulWidget {
  static const routeName = '/messages';

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _scrollController = ScrollController();
  final _scrollThreshold = 200.0;
  MessageBloc _messageBloc;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _messageBloc = BlocProvider.of<MessageBloc>(context);
    _messageBloc.add(LoadMessages());
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
          BlocBuilder<MessageBloc, MessageState>(
            builder: (context, state) {
              if (state is MessagesUninitialized) {
                return _buildLoading();
              }
              if (state is MessagesError) {
                return _buildError();
              }
              if (state is MessagesLoaded) {
                if (state.messages.isEmpty) {
                  return _buildEmptyList();
                }
                return _buildMessagesList(state.messages, state.hasReachedMax);
              }
              return _buildEmptyList();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context)
                .pop();
          }),
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
            return MessageListItem(message: messages[index]);
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
      _messageBloc.add(LoadMessages());
    }
  }
}


