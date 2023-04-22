/*
 * File: silent.dart
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

class SilentPage extends StatefulWidget {
  const SilentPage({Key? key, required this.controller, required this.settings})
      : super(key: key);

  final Controller controller;
  final Settings settings;

  @override
  State<SilentPage> createState() => _PageState();
}

class _PageState extends State<SilentPage> {
  bool isSending = false;

  int step = 10;
  int cycle = 4096;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Silencer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('step: $step'),
            Slider(
              value: step.toDouble(),
              min: 0,
              max: 4096,
              divisions: 4096,
              label: step.toString(),
              onChanged: (value) {
                setState(() {
                  step = value.toInt();
                });
              },
            ),
            Text('cycle: $cycle'),
            Slider(
              value: cycle.toDouble(),
              min: 0,
              max: 4096,
              divisions: 4096,
              label: cycle.toString(),
              onChanged: (value) {
                setState(() {
                  cycle = value.toInt();
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
                widget.controller.send('silent', '$step,$cycle').then((value) {
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
