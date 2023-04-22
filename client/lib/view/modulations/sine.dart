/*
 * File: sine.dart
 * Project: modulations
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

class SinePage extends StatefulWidget {
  const SinePage({Key? key, required this.controller, required this.settings})
      : super(key: key);

  final Controller controller;
  final Settings settings;

  @override
  State<SinePage> createState() => _SinePageState();
}

class _SinePageState extends State<SinePage> {
  bool isSending = false;

  int freq = 150;
  double amp = 1.0;
  double offset = 0.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sine'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('freq: $freq'),
            Slider(
              value: freq.toDouble(),
              min: 0,
              max: 2000,
              divisions: 2000,
              label: freq.toString(),
              onChanged: (value) {
                setState(() {
                  freq = value.toInt();
                });
              },
            ),
            Text('amp: $amp'),
            Slider(
              value: amp,
              min: 0,
              max: 1,
              divisions: 100,
              label: amp.toString(),
              onChanged: (value) {
                setState(() {
                  amp = value;
                });
              },
            ),
            Text('offset: $offset'),
            Slider(
              value: offset,
              min: 0,
              max: 1,
              divisions: 100,
              label: offset.toString(),
              onChanged: (value) {
                setState(() {
                  offset = value;
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
                widget.controller
                    .send('sine', '$freq,$amp,$offset')
                    .then((value) {
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
