import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/messages_screen.dart';
import '../helpers/custom_route.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Hello Friend!'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.send),
            title: Text('Send Message'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.message),
            title: Text('My Messages'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(MessagesScreen.routeName);
              // Navigator.of(context).pushReplacement(
              //   CustomRoute(
              //     builder: (ctx) => OrdersScreen(),
              //   ),
              // );
            },
          ),
        ],
      ),
    );
  }
}
