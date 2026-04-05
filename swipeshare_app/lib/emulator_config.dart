import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

const String _emulatorHost = '127.0.0.1';

Future<void> connectToEmulators() async {
  // On Android, localhost on the device refers to the emulator itself.
  // Use 10.0.2.2 to reach the host machine where Firebase emulators run.
  final host = Platform.isAndroid ? '10.0.2.2' : _emulatorHost;
  debugPrint('[Emulator] Connecting to emulators on $host...');

  await FirebaseAuth.instance.useAuthEmulator(host, 9099);
  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
}
