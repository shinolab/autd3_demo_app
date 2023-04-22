/*
 * File: demo.dart
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

import 'package:autd3_demo_app/view/demos/handrail_circle.dart';
import 'package:autd3_demo_app/view/demos/pursuit.dart';
import 'package:flutter/material.dart';

import '../controller/controller.dart';
import '../settings.dart';
import 'demos/handrail_line.dart';
import 'demos/lm.dart';

class DemoPage extends StatefulWidget {
  const DemoPage({Key? key, required this.controller, required this.settings})
      : super(key: key);

  final Controller controller;
  final Settings settings;

  @override
  State<DemoPage> createState() => _PageState();
}

class _PageState extends State<DemoPage> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            const SizedBox(height: 20),
            SingleChildScrollView(
                child: Wrap(
              runSpacing: 16,
              spacing: 16,
              children: <Widget>[
                SizedBox(
                    child: FilledButton(
                        onPressed: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HandrailLinePage(
                                          controller: widget.controller,
                                          settings: widget.settings)))
                            },
                        child: const Text('Virtual Handrail (Line)',
                            style: TextStyle(fontSize: 14)))),
                SizedBox(
                    child: FilledButton(
                        onPressed: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HandrailCirclePage(
                                          controller: widget.controller,
                                          settings: widget.settings)))
                            },
                        child: const Text('Virtual Handrail (Circle)',
                            style: TextStyle(fontSize: 14)))),
                SizedBox(
                    child: FilledButton(
                        onPressed: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PursuitPage(
                                          controller: widget.controller,
                                          settings: widget.settings)))
                            },
                        child: const Text('Haptic Pursuit',
                            style: TextStyle(fontSize: 14)))),
                SizedBox(
                    child: FilledButton(
                        onPressed: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LMPage(
                                          controller: widget.controller,
                                          settings: widget.settings)))
                            },
                        child:
                            const Text('LM', style: TextStyle(fontSize: 14)))),
              ],
            ))
          ],
        ));
  }
}
