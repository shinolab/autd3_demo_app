/*
 * File: handrail_circle.dart
 * Project: demos
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

class HandrailCirclePage extends StatefulWidget {
  const HandrailCirclePage(
      {Key? key, required this.controller, required this.settings})
      : super(key: key);

  final Controller controller;
  final Settings settings;

  @override
  State<HandrailCirclePage> createState() => _PageState();
}

class _PageState extends State<HandrailCirclePage> {
  bool isSending = false;

  double freq = 20.0;
  double len = 200.0;
  double sampleLen = 20.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Handrail (Circle)'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('freq: $freq'),
            Slider(
              value: freq,
              min: 0,
              max: 1000,
              divisions: 1000,
              label: freq.toString(),
              onChanged: (value) {
                setState(() {
                  freq = value;
                });
              },
            ),
            Text('len: $len'),
            Slider(
              value: len,
              min: 0,
              max: 1000,
              divisions: 1000,
              label: len.toString(),
              onChanged: (value) {
                setState(() {
                  len = value;
                });
              },
            ),
            Text('sample len: $sampleLen'),
            Slider(
              value: sampleLen,
              min: 0,
              max: 1000,
              divisions: 1000,
              label: sampleLen.toString(),
              onChanged: (value) {
                setState(() {
                  sampleLen = value;
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
                    .send('handrail_circle', '$freq,$len,$sampleLen')
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
