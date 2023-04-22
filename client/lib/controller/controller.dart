/*
 * File: controller.dart
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

class Response {
  Response({required this.cmd, required this.success});

  final String cmd;
  final bool success;
}

class Controller {
  Controller({required ipAddress, this.timeout = const Duration(seconds: 1)})
      : _ipAddress = ipAddress;

  final String _ipAddress;
  Duration timeout;

  String get ipAddress => _ipAddress;

  Future<void> connect() async {
    print('connect');
    return await Future.delayed(timeout);
  }

  Future<void> disconnect() async {
    print('disconnect');
    return await Future.delayed(timeout);
  }

  Future<Response> send(String cmd, String? data, {Duration? timeout}) async {
    print('cmd: $cmd');
    print('data: $data');
    final timeout_ = timeout ?? this.timeout;
    await Future.delayed(timeout_);
    return Response(cmd: cmd, success: true);
  }
}
