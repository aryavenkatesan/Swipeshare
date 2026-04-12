import 'package:firebase_auth/firebase_auth.dart';
import 'package:swipeshare_app/services/dev_service.dart';

Future<void> signInAs(SeedEmail user) async {
  await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: user.value,
    password: 'password',
  );
}

Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
}
