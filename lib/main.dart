import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_complete_guide/bloc/bloc.dart';
import 'package:flutter_complete_guide/bloc/contact/contact_bloc.dart';
import 'package:flutter_complete_guide/bloc/contact/contact_event.dart';
import 'package:flutter_complete_guide/screens/messages_screen.dart';
import 'package:provider/provider.dart';
import './screens/splash_screen.dart';
import './screens/send_message_screen.dart';
import './helpers/custom_route.dart';
import './bloc/deeplink/DeepLinkBloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<DeepLinkBloc>(
      create: (BuildContext context) => DeepLinkBloc(),
      dispose: (context, bloc) => bloc.dispose(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<MessageBloc>(
            create: (context) => MessageBloc()..add(LoadMessages()),
          ),
          BlocProvider<ContactBloc>(
            create: (context) => ContactBloc()..add(LoadContacts()),
          ),
        ],
        child: MaterialApp(
          title: 'ChatOnClick',
          theme: ThemeData(
            primaryColor: Color(0xff118971),
            accentColor: Color(0xff89c541),
            fontFamily: 'Lato',
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CustomPageTransitionBuilder(),
                TargetPlatform.iOS: CustomPageTransitionBuilder(),
              },
            ),
          ),
          home: SendMessageScreen(),
          routes: {
            SendMessageScreen.routeName: (ctx) => SendMessageScreen(),
            MessagesScreen.routeName: (ctx) => MessagesScreen(),
          },
        ),
      ),
    );
  }
}
