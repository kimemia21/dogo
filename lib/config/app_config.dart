import 'package:dogo/core/constants/initializer.dart';
import 'package:dogo/data/models/Pod.dart';
import 'package:dogo/features/Pod/Homepage.dart';
import 'package:dogo/main.dart';
import 'package:dogo/features/Pod/select_pod.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

getPodId() {
  final uri = Uri.parse(web.window.location.href);
  final segments = uri.pathSegments;
  podId = segments.isNotEmpty ? int.tryParse(segments.last) : null;
}

Widget getDevice() {
  return podId != null ? HomePage() : PodSelectionForm() ;
}
