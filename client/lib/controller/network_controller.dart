/*
 * File: network_controller.dart
 * Project: controller
 * Created Date: 22/04/2023
 * Author: Shun Suzuki
 * -----
 * Last Modified: 22/04/2023
 * Modified By: Shun Suzuki (suzuki@hapis.k.u-tokyo.ac.jp)
 * -----
 * Copyright (c) 2023 Shun Suzuki. All rights reserved.
 * 
 */

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'controller.dart';

class NetworkController extends Controller {
  NetworkController(
      {required ipAddress, super.timeout = const Duration(seconds: 1)})
      : super(ipAddress: ipAddress);

  Socket? socket;
  String? serverResponse;

  @override
  Future<void> connect() async {
    socket =
        await Socket.connect(super.ipAddress, 50632, timeout: super.timeout);
    socket?.listen((Uint8List data) {
      serverResponse = String.fromCharCodes(data).replaceAll('\r\n', '');
    }, onError: (error) {
      socket?.destroy();
    }, onDone: () {
      socket?.destroy();
    });
  }

  @override
  Future<void> disconnect() async {
    try {
      await send('close', null, timeout: const Duration(milliseconds: 100));
    } catch (e) {}
    socket?.close();
  }

  @override
  Future<Response> send(String cmd, String? data, {Duration? timeout}) async {
    final d = data == null ? cmd : '$cmd/$data';
    socket?.write(d);
    final timeout_ = timeout ?? super.timeout;
    return Future(() async {
      bool expired = false;
      Timer(timeout_, () {
        expired = true;
      });
      while (!expired) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (serverResponse != null) {
          final res = serverResponse!.split('/');
          if (res.isEmpty || res.length != 2) {
            return Response(cmd: cmd, success: false);
          }
          return Response(cmd: res[0], success: res[1] == 'ok');
        }
      }
      throw TimeoutException('Failed to receive response');
    });
  }
}
