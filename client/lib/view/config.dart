/*
 * File: config.dart
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
import 'configs/silent.dart';
import 'configs/temp.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({Key? key, required this.controller, required this.settings})
      : super(key: key);

  final Controller controller;
  final Settings settings;

  @override
  State<ConfigPage> createState() => _PageState();
}

class _PageState extends State<ConfigPage> {
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
                                      builder: (context) => TempPage(
                                          controller: widget.controller,
                                          settings: widget.settings)))
                            },
                        child: const Text('Temp',
                            style: TextStyle(fontSize: 14)))),
                SizedBox(
                    child: FilledButton(
                        onPressed: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SilentPage(
                                          controller: widget.controller,
                                          settings: widget.settings)))
                            },
                        child: const Text('Silent',
                            style: TextStyle(fontSize: 14)))),
              ],
            ))
          ],
        ));
  }
}
