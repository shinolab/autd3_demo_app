/*
 * File: app.dart
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

import 'package:autd3_demo_app/view/gain.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../controller/controller.dart';
import '../settings.dart';
import 'config.dart';
import 'demo.dart';
import 'modulation.dart';

class AppPage extends StatefulWidget {
  const AppPage({Key? key, required this.controller, required this.settings})
      : super(key: key);

  final Settings settings;
  final Controller controller;

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  bool isSending = false;
  bool configuringGeometry = true;

  @override
  void initState() {
    super.initState();
    widget.settings.save('settings.json').then((_) {
      var data = widget.settings.geometries
          .map<String>((Geometry geometry) =>
              '${geometry.x},${geometry.y},${geometry.z},${geometry.rz1},${geometry.ry},${geometry.rz2}')
          .join('/');
      return widget.controller
          .send('geo', data, timeout: const Duration(seconds: 10))
          .then((value) {
        if (value.cmd == 'geo' && value.success) {
          setState(() {
            configuringGeometry = false;
          });
        } else {
          throw Exception('Failed to configure Geometry');
        }
      });
    }).catchError((e) {
      Navigator.of(context).pop(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return configuringGeometry
        ? Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Theme.of(context).indicatorColor,
                size: 100,
              ),
            ),
          )
        : WillPopScope(
            onWillPop: () async {
              var exit = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('${widget.controller.ipAddress}との接続を切りますか？'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('キャンセル'),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () {
                          widget.controller
                              .disconnect()
                              .then((_) => Navigator.of(context).pop(true));
                        },
                      ),
                    ],
                  );
                },
              );
              return exit ?? false;
            },
            child: Column(children: <Widget>[
              Expanded(
                  child: DefaultTabController(
                      length: 4,
                      child: Scaffold(
                        appBar: AppBar(
                          title: const Text('AUTD3デモアプリ'),
                          bottom: const TabBar(
                            labelStyle: TextStyle(fontSize: 20),
                            isScrollable: true,
                            tabs: <Widget>[
                              Tab(text: 'Demos'),
                              Tab(text: 'Gain'),
                              Tab(text: 'Modulation'),
                              Tab(text: 'Config'),
                            ],
                          ),
                        ),
                        body: TabBarView(
                          children: <Widget>[
                            DemoPage(
                                controller: widget.controller,
                                settings: widget.settings),
                            GainPage(
                                controller: widget.controller,
                                settings: widget.settings),
                            ModulationPage(
                                controller: widget.controller,
                                settings: widget.settings),
                            ConfigPage(
                                controller: widget.controller,
                                settings: widget.settings),
                          ],
                        ),
                      ))),
              Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          FloatingActionButton(
                              onPressed: isSending
                                  ? null
                                  : () {
                                      setState(() {
                                        isSending = true;
                                      });
                                      widget.controller
                                          .send('stop', null)
                                          .then((value) {
                                        setState(() {
                                          isSending = false;
                                        });
                                        if (!value.success) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              backgroundColor: Colors.redAccent
                                                  .withOpacity(0.8),
                                              content: const Text(
                                                  'Failed to send data'),
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
                                  : const Icon(Icons.pause)),
                        ],
                      )))
            ]));
  }
}
