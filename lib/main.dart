import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_complete_guide/bloc/bloc.dart';
import 'package:flutter_complete_guide/bloc/contact/contact_bloc.dart';
import 'package:flutter_complete_guide/bloc/contact/contact_event.dart';
import 'package:flutter_complete_guide/bloc/scheluedmessage/scheduled_message_bloc.dart';
import 'package:flutter_complete_guide/bloc/scheluedmessage/scheduled_message_event.dart';
import 'package:flutter_complete_guide/screens/messages_screen.dart';
import 'package:flutter_complete_guide/screens/scheuled_messages_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:launcher/launcher.dart';
import 'package:workmanager/workmanager.dart';
import './screens/splash_screen.dart';
import './screens/send_message_screen.dart';
import './helpers/custom_route.dart';
import './bloc/deeplink/DeepLinkBloc.dart';

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) {
    print('sendWhatsapp');
    print(task);
    if (task == 'sendWhatsapp'
        && inputData['number'] != null
        && inputData['message'] != null) {
      Launcher.sendWhatsappMessage(
        number: inputData['number'],
        message: inputData['message'],
      );
    }
    return Future.value(true);
  });
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager.initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode: true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
  );
  runApp(MyApp());
}

void sendSchedule() async {

  print(DateTime.now().toIso8601String());
//  Launcher.launch(tag: 'Tag!!!', route: '/');
//  Launcher.sendWhatsappMessage(number: '+972526039309', message: 'Ahalan!');
//  Launcher.print(text: 'Hiiii');
//  final url = 'https://api.whatsapp.com/send?phone+972526039309=&text=Hi!!' + '\nSent by Chat On Click';
//  if (await canLaunch(url)) {
//    await launch(url);
//  }
}

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
          BlocProvider<ScheduledMessageBloc>(
            create: (context) => ScheduledMessageBloc()..add(LoadScheduledMessages()),
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
            ScheduledMessagesScreen.routeName: (ctx) => ScheduledMessagesScreen(),
          },
        ),
      ),
    );
  }
}
