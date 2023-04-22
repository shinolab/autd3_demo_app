/*
 * File: connect.dart
 * Project: view
 * Created Date: 22/04/2023
 * Author: Shun Suzuki
 * -----
 * Last Modified: 22/04/2023
 * Modified By: Shun Suzuki (suzuki@hapis.k.u-tokyo.ac.jp)
 * -----
 * Copyright (c) 2023 Shun Suzuki. All rights reserved.
 * 
 */

import 'package:flutter/material.dart';

import '../controller/network_controller.dart';
import '../settings.dart';
import 'geometry.dart';

class ConnectPage extends StatefulWidget {
  const ConnectPage({super.key, required this.title});

  final String title;

  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  final _ipv4Reg = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])$');

  bool loading = true;
  String _ipAddress = '';
  bool _isValudIp = false;

  Settings settings = Settings();

  @override
  void initState() {
    super.initState();
    settings.load('settings.json').then((value) {
      setState(() {
        loading = false;
        _ipAddress = settings.ip;
        _isValudIp = _ipv4Reg.hasMatch(_ipAddress);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Focus(
                    child: TextField(
                      controller: TextEditingController(text: _ipAddress),
                      decoration: const InputDecoration(
                        labelText: 'IPv4アドレスを入力してください',
                        hintText: 'xxx.xxx.xxx.xxx',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _ipAddress = value;
                      },
                      maxLength: 15,
                    ),
                    onFocusChange: (value) {
                      if (!value) {
                        setState(() {
                          _isValudIp = _ipv4Reg.hasMatch(_ipAddress);
                        });
                      }
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  FilledButton(
                    onPressed: _isValudIp
                        ? () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GeometryPage(
                                    controller: NetworkController(
                                        ipAddress: _ipAddress,
                                        timeout: const Duration(seconds: 5)),
                                    settings: settings,
                                  ),
                                )).then((value) {
                              if (value is Exception) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor:
                                        Colors.redAccent.withOpacity(0.8),
                                    content: Text('$value'),
                                  ),
                                );
                              }
                            });
                          }
                        : null,
                    child: const Text('接続'),
                  ),
                ],
              ),
            ));
  }
}
