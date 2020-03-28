import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_lib/native_lib.dart';

void main() {
  const MethodChannel channel = MethodChannel('native_lib');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await NativeLib.platformVersion, '42');
  });
}
