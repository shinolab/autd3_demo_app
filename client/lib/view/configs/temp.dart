/*
 * File: temp.dart
 * Project: configs
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

import '../../controller/controller.dart';
import '../../settings.dart';

class TempPage extends StatefulWidget {
  const TempPage({Key? key, required this.controller, required this.settings})
      : super(key: key);

  final Controller controller;
  final Settings settings;

  @override
  State<TempPage> createState() => _PageState();
}

class _PageState extends State<TempPage> {
  bool isSending = false;

  double temp = 15.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Temperature'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('temperature: ${temp.toStringAsFixed(1)}'),
            Slider(
              value: temp,
              min: 0,
              max: 40,
              divisions: 400,
              label: temp.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  temp = value;
                });
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: isSending
            ? null
            : () {
                setState(() {
                  isSending = true;
                });
                widget.controller.send('temp', '$temp').then((value) {
                  setState(() {
                    isSending = false;
                  });
                  if (!value.success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.redAccent.withOpacity(0.8),
                        content: const Text('Failed to send data'),
                      ),
                    );
                  }
                });
              },
        child: isSending
            ? Container(
                width: 24,
                height: 24,
                padding: const EdgeInsets.all(2.0),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : const Icon(Icons.send),
      ),
    );
  }
}
