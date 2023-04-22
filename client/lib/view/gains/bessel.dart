/*
 * File: bessel.dart
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

class BesselPage extends StatefulWidget {
  const BesselPage({Key? key, required this.controller, required this.settings})
      : super(key: key);

  final Controller controller;
  final Settings settings;

  @override
  State<BesselPage> createState() => _BesselPageState();
}

class _BesselPageState extends State<BesselPage> {
  bool isSending = false;

  double x = 0.0;
  double y = 0.0;
  double z = 0.0;
  double nx = 0.0;
  double ny = 0.0;
  double nz = 1.0;
  double theta = 18.0;
  double amp = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bessel Beam'),
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
            Row(
              children: <Widget>[
                Expanded(
                    child: Slider(
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
                )),
                IconButton(
                    onPressed: () {
                      setState(() {
                        z = 0;
                      });
                    },
                    icon: const Icon(Icons.center_focus_strong))
              ],
            ),
            Text('nx: $nx'),
            Slider(
              value: nx,
              min: 0,
              max: 1,
              divisions: 100,
              label: nx.toString(),
              onChanged: (value) {
                setState(() {
                  nx = value;
                });
              },
            ),
            Text('ny: $ny'),
            Slider(
              value: ny,
              min: 0,
              max: 1,
              divisions: 100,
              label: ny.toString(),
              onChanged: (value) {
                setState(() {
                  ny = value;
                });
              },
            ),
            Text('nz: $nz'),
            Slider(
              value: nz,
              min: 0,
              max: 1,
              divisions: 100,
              label: nz.toString(),
              onChanged: (value) {
                setState(() {
                  nz = value;
                });
              },
            ),
            Text('theta: $theta'),
            Slider(
              value: theta,
              min: 0,
              max: 360,
              divisions: 360,
              label: theta.toString(),
              onChanged: (value) {
                setState(() {
                  theta = value;
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
                    .send('bessel', '$x,$y,$z,$nx,$ny,$nz,$theta,$amp')
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
