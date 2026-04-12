import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Finds a text input field regardless of platform.
/// iOS uses [CupertinoTextField]; Android uses [TextField].
Finder findTextField() => find.byWidgetPredicate(
      (w) => w is TextField || w is CupertinoTextField,
    );
