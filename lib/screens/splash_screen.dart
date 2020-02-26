import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              height: 50,
              child: Image.asset(
                'assets/images/chat_on_click_logo_wrap.png',
                fit: BoxFit.cover,
              ),
            ),
            Text('Welcome!')
          ],
        ),
      ),
    );
  }
}
