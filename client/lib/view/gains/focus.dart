/*
 * File: focus.dart
 * Project: gains
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

class FocusPage extends StatefulWidget {
  const FocusPage({Key? key, required this.controller, required this.settings})
      : super(key: key);

  final Controller controller;
  final Settings settings;

  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {
  bool isSending = false;

  double x = 0.0;
  double y = 0.0;
  double z = 200.0;
  double amp = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus'),
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
              min: 0,
              max: 1000,
              divisions: 1000,
              label: z.toString(),
              onChanged: (value) {
                setState(() {
                  z = value;
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
              onChangeEnd: (value) {},
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
                widget.controller.send('focus', '$x,$y,$z,$amp').then((value) {
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
