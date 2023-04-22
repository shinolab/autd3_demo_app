/*
 * File: geometry.dart
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../controller/controller.dart';
import '../settings.dart';
import 'app.dart';

class GeometryPage extends StatefulWidget {
  const GeometryPage(
      {Key? key, required this.controller, required this.settings})
      : super(key: key);

  final Controller controller;
  final Settings settings;

  @override
  State<GeometryPage> createState() => _GeometryPageState();
}

class _GeometryPageState extends State<GeometryPage> {
  bool connecting = true;

  @override
  void initState() {
    super.initState();
    widget.controller.connect().then((connected) async {
      widget.settings.ip = widget.controller.ipAddress;
      await widget.settings.save('settings.json');
      setState(() {
        connecting = false;
      });
    }).catchError((e) {
      Navigator.of(context).pop(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return connecting
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
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Geometry設定'),
              ),
              body: Column(children: <Widget>[
                const SizedBox(height: 16),
                ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    final geometry = widget.settings.geometries[index];
                    return Dismissible(
                      key: ValueKey<Geometry>(geometry),
                      onDismissed: (direction) {
                        setState(() {
                          widget.settings.geometries.removeAt(index);
                        });
                      },
                      child: GeometryCard(
                        index: index,
                        geometry: geometry,
                      ),
                    );
                  },
                  shrinkWrap: true,
                  itemCount: widget.settings.geometries.length,
                ),
                const SizedBox(height: 16),
                FilledButton(
                    onPressed: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const _GeometryAddPage()),
                          ).then((value) => {
                                if (value != null)
                                  {
                                    setState(() {
                                      widget.settings.geometries.add(value);
                                    })
                                  }
                              })
                        },
                    child: const Icon(Icons.add))
              ]),
              floatingActionButton: FloatingActionButton(
                onPressed: widget.settings.geometries.isEmpty
                    ? null
                    : () async {
                        final completer = Completer();
                        final result = Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AppPage(
                                controller: widget.controller,
                                settings: widget.settings,
                              ),
                            ),
                            result: completer.future);
                        completer.complete(result);
                      },
                child: const Icon(Icons.navigate_next),
              ),
            ),
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
            });
  }
}

class GeometryCard extends StatelessWidget {
  const GeometryCard({Key? key, required this.index, required this.geometry})
      : super(key: key);

  final int index;
  final Geometry geometry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('Device $index'),
        subtitle: Text(
            'pos: (${geometry.x}, ${geometry.y}, ${geometry.z}), rot: (${geometry.rz1}, ${geometry.ry}, ${geometry.rz2})'),
      ),
    );
  }
}

class _GeometryAddPage extends StatefulWidget {
  const _GeometryAddPage({Key? key}) : super(key: key);

  @override
  State<_GeometryAddPage> createState() => _GeometryAddPageState();
}

class _GeometryAddPageState extends State<_GeometryAddPage> {
  _GeometryAddPageState();

  Geometry geometry = Geometry(x: 0, y: 0, z: 0, ry: 0, rz1: 0, rz2: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geometry追加'),
      ),
      body: Container(
        padding: const EdgeInsets.all(64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).textTheme.bodyMedium?.color ??
                        Colors.white,
                    width: 1.0,
                  ),
                ),
              ),
              child: const Text('Position',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.left),
            ),
            Row(
              children: [
                const Text('x: '),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller:
                        TextEditingController(text: geometry.x.toString()),
                    onChanged: (value) {
                      setState(() {
                        geometry.x = double.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
                FilledButton(
                    onPressed: () {
                      setState(() {
                        geometry.x += 192;
                      });
                    },
                    child: const Text('+W')),
                const SizedBox(width: 4),
                FilledButton(
                    onPressed: () {
                      setState(() {
                        geometry.x += 151.4;
                      });
                    },
                    child: const Text('+H'))
              ],
            ),
            Row(
              children: [
                const Text('y: '),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller:
                        TextEditingController(text: geometry.y.toString()),
                    onChanged: (value) {
                      setState(() {
                        geometry.y = double.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
                FilledButton(
                    onPressed: () {
                      setState(() {
                        geometry.y += 192;
                      });
                    },
                    child: const Text('+W')),
                const SizedBox(width: 4),
                FilledButton(
                    onPressed: () {
                      setState(() {
                        geometry.y += 151.4;
                      });
                    },
                    child: const Text('+H'))
              ],
            ),
            Row(
              children: [
                const Text('z: '),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller:
                        TextEditingController(text: geometry.z.toString()),
                    onChanged: (value) {
                      setState(() {
                        geometry.z = double.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
                FilledButton(
                    onPressed: () {
                      setState(() {
                        geometry.z += 192;
                      });
                    },
                    child: const Text('+W')),
                const SizedBox(width: 4),
                FilledButton(
                    onPressed: () {
                      setState(() {
                        geometry.z += 151.4;
                      });
                    },
                    child: const Text('+H'))
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.only(bottom: 0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).textTheme.bodyMedium?.color ??
                        Colors.white,
                    width: 1.0,
                  ),
                ),
              ),
              child: const Text('Rotation',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.left),
            ),
            Row(
              children: [
                const Text('rz1: '),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller:
                        TextEditingController(text: geometry.rz1.toString()),
                    onChanged: (value) {
                      setState(() {
                        geometry.rz1 = double.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
                FilledButton(
                    onPressed: () {
                      setState(() {
                        geometry.rz1 += 90;
                      });
                    },
                    child: const Text('+90°')),
              ],
            ),
            Row(
              children: [
                const Text(' ry: '),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller:
                        TextEditingController(text: geometry.ry.toString()),
                    onChanged: (value) {
                      setState(() {
                        geometry.ry = double.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
                FilledButton(
                    onPressed: () {
                      setState(() {
                        geometry.ry += 90;
                      });
                    },
                    child: const Text('+90°')),
              ],
            ),
            Row(
              children: [
                const Text('rz2: '),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller:
                        TextEditingController(text: geometry.rz2.toString()),
                    onChanged: (value) {
                      setState(() {
                        geometry.rz2 = double.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
                FilledButton(
                    onPressed: () {
                      setState(() {
                        geometry.rz2 += 90;
                      });
                    },
                    child: const Text('+90°')),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(geometry);
                },
                child: const Text('追加'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('キャンセル'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
