import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/life_hub_app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final firebaseState = await _initializeFirebase();

  runApp(LifeHubApp(firebaseState: firebaseState));
}

Future<FirebaseStartupState> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    return const FirebaseStartupState.ready();
  } on UnsupportedError catch (error) {
    return FirebaseStartupState.notConfigured(error.toString());
  } on FirebaseException catch (error) {
    return FirebaseStartupState.failed(error.message ?? error.code);
  } catch (error) {
    return FirebaseStartupState.failed(error.toString());
  }
}
