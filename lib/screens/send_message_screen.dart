import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_complete_guide/bloc/scheluedmessage/scheduled_message_bloc.dart';
import 'package:flutter_complete_guide/screens/scheuled_messages_screen.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../bloc/deeplink/DeepLinkBloc.dart';
import 'package:provider/provider.dart';
import '../bloc/message/message_bloc.dart';
import '../screens/messages_screen.dart';
import '../bloc/contact/contact_bloc.dart';
import '../screens/send_message_card.dart';

class SendMessageScreen extends StatelessWidget {
  static const routeName = '/sendMessage';

  SendMessageScreen();

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
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 45.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      // ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Row(
                        children: <Widget>[
                          Container(
                            height: 50,
                            child: Image.asset(
                              'assets/images/chat_on_click_logo_wrap.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          Text(
                            'hat On Click',
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontSize: 40,
                              fontFamily: 'Anton',
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: BlocProvider.value(
                      value: BlocProvider.of<ContactBloc>(context),
                      child: BlocProvider.value(
                        value: BlocProvider.of<MessageBloc>(context),
                        child: BlocProvider.value(
                            value: Provider.of<ScheduledMessageBloc>(context),
                            child: Provider.value(
                              value: Provider.of<DeepLinkBloc>(context),
                              child: MessageCard(),
                            ),
                        )
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
            child: Icon(Icons.message),
            backgroundColor: Theme.of(context).accentColor,
            label: 'Messages',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => Navigator.of(context)
                .pushNamed(MessagesScreen.routeName),
          ),
          SpeedDialChild(
            child: Icon(Icons.timer),
            backgroundColor: Theme.of(context).accentColor,
            label: 'Scheduled Messages',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => Navigator.of(context)
                .pushNamed(ScheduledMessagesScreen.routeName),
          ),
        ],
      ),
    );
  }
}

