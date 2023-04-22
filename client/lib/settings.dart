/*
 * File: settings.dart
 * Project: lib
 * Created Date: 22/04/2023
 * Author: Shun Suzuki
 * -----
 * Last Modified: 22/04/2023
 * Modified By: Shun Suzuki (suzuki@hapis.k.u-tokyo.ac.jp)
 * -----
 * Copyright (c) 2023 Shun Suzuki. All rights reserved.
 * 
 */

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class Geometry {
  Geometry(
      {required this.x,
      required this.y,
      required this.z,
      required this.rz1,
      required this.ry,
      required this.rz2});

  double x = 0;
  double y = 0;
  double z = 0;
  double rz1 = 0;
  double ry = 0;
  double rz2 = 0;

  Geometry.fromJson(Map<String, dynamic> json)
      : x = json['x'],
        y = json['y'],
        z = json['z'],
        rz1 = json['rz1'],
        ry = json['ry'],
        rz2 = json['rz2'];

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'z': z,
        'rz1': rz1,
        'ry': ry,
        'rz2': rz2,
      };
}

class Settings {
  Settings();

  String ip = '';
  List<Geometry> geometries = [];

  fromJson(Map<String, dynamic> json) {
    ip = json['ip'];
    geometries = List<Geometry>.from(
        json['geometries'].map((geometry) => Geometry.fromJson(geometry)));
  }

  Map<String, dynamic> toJson() => {
        'ip': ip,
        'geometries': geometries,
      };

  Future load(String jsonPath) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, jsonPath));
    if (!(await file.exists())) {
      _setDefault();
      return;
    }

    try {
      final jsonStr = await file.readAsString();
      Map<String, dynamic> settingMap = json.decode(jsonStr);
      fromJson(settingMap);
    } catch (e) {
      _setDefault();
      return;
    }
  }

  Future save(String jsonPath) async {
    final directory = await getApplicationDocumentsDirectory();
    final jsonStr = json.encode(toJson());
    await File(p.join(directory.path, jsonPath)).writeAsString(jsonStr);
  }

  _setDefault() {
    ip = '';
    geometries = [];
  }
}
