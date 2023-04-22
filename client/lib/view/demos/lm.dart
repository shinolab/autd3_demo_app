/*
 * File: lm.dart
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

class LMPage extends StatefulWidget {
  const LMPage({Key? key, required this.controller, required this.settings})
      : super(key: key);

  final Controller controller;
  final Settings settings;

  @override
  State<LMPage> createState() => _PageState();
}

class _PageState extends State<LMPage> {
  bool isSending = false;

  double x = 0.0;
  double y = 0.0;
  double z = 200.0;

  double freq = 50.0;
  double radius = 5.0;
  int num = 200;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lateral Modulation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('x: $x'),
            Row(
              children: <Widget>[
                Expanded(
                    child: Slider(
                  value: x,
                  min: -500,
                  max: 500,
                  divisions: 1000,
                  label: x.toString(),
                  onChanged: (value) {
                    setState(() {
                      x = value;
                    });
                  },
                )),
                IconButton(
                    onPressed: () {
                      setState(() {
                        x = 0;
                      });
                    },
                    icon: const Icon(Icons.center_focus_strong))
              ],
            ),
            Text('y: $y'),
            Row(
              children: <Widget>[
                Expanded(
                    child: Slider(
                  value: y,
                  min: -500,
                  max: 500,
                  divisions: 1000,
                  label: y.toString(),
                  onChanged: (value) {
                    setState(() {
                      y = value;
                    });
                  },
                )),
                IconButton(
                    onPressed: () {
                      setState(() {
                        y = 0;
                      });
                    },
                    icon: const Icon(Icons.center_focus_strong))
              ],
            ),
            Text('z: $z'),
            Slider(
              value: z,
              min: -500,
              max: 500,
              divisions: 1000,
              label: z.toString(),
              onChanged: (value) {
                setState(() {
                  z = value;
                });
              },
            ),
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
            Text('radius: $radius'),
            Slider(
              value: radius,
              min: 0,
              max: 50,
              divisions: 500,
              label: radius.toString(),
              onChanged: (value) {
                setState(() {
                  radius = value;
                });
              },
            ),
            Text('N: $num'),
            Slider(
              value: num.toDouble(),
              min: 0,
              max: 1000,
              divisions: 1000,
              label: num.toString(),
              onChanged: (value) {
                setState(() {
                  num = value.toInt();
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
                    .send('lm', '$x,$y,$z,$freq,$radius,$num')
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
