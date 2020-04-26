import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launcher/launcher.dart';

void main() {
  const MethodChannel channel = MethodChannel('launcher');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

}
