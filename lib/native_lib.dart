import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:ffi'; // For FFI
import 'package:ffi/ffi.dart';
import 'dart:io';

// https://medium.com/flutter-community/using-ffi-on-flutter-plugins-to-run-native-rust-code-d64c0f14f9c2
// https://github.com/brickpop/flutter-rust-ffi

class NativeLib {
  static final DynamicLibrary nativeLib = Platform.isAndroid
      ? DynamicLibrary.open("libsmov.so")
      : DynamicLibrary.process();

  static DeviceList listDevices() {
    return new DeviceList(nativeLib);
  }
}

class DeviceList {
  Pointer<Pointer<Utf8>> Function() _listDevices;
  void Function(Pointer<Pointer<Utf8>>) _freeDevices;
  Pointer<Pointer<Utf8>> _inner;
  int len;

  DeviceList(DynamicLibrary nativeLib) {
    final Pointer<Pointer<Utf8>> Function() _listDevices = nativeLib
        .lookup<NativeFunction<Pointer<Pointer<Utf8>> Function()>>("smov_list_devices")
        .asFunction();
    _freeDevices = nativeLib
        .lookup<NativeFunction<Void Function(Pointer<Pointer<Utf8>>)>>("smov_free_devices")
        .asFunction();
    _inner = _listDevices();
    len = 0;
    while (_inner.elementAt(len) != Pointer.fromAddress(0)) len++;
  }

  String get(int idx) {
    if (idx >= len) return null;
    return Utf8.fromUtf8(_inner.elementAt(idx).value);
  }

  void clear() {
    _freeDevices(_inner);
  }
}


