/*
 * File: gain.dart
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

import '../controller/controller.dart';
import '../settings.dart';
import 'gains/bessel.dart';
import 'gains/focus.dart';

class GainPage extends StatefulWidget {
  const GainPage({Key? key, required this.controller, required this.settings})
      : super(key: key);

  final Controller controller;
  final Settings settings;

  @override
  State<GainPage> createState() => _GainPageState();
}

class _GainPageState extends State<GainPage> {
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
                                      builder: (context) => FocusPage(
                                          controller: widget.controller,
                                          settings: widget.settings)))
                            },
                        child: const Text('Focus',
                            style: TextStyle(fontSize: 14)))),
                SizedBox(
                    child: FilledButton(
                        onPressed: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BesselPage(
                                          controller: widget.controller,
                                          settings: widget.settings)))
                            },
                        child: const Text('BesselBeam',
                            style: TextStyle(fontSize: 14)))),
              ],
            ))
          ],
        ));
  }
}
