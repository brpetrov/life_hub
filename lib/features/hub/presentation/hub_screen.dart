import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../auth/auth_service.dart';
import '../data/firestore_hub_item_repository.dart';
import 'hub_dashboard.dart';

class HubScreen extends StatelessWidget {
  const HubScreen({required this.authService, required this.user, super.key});

  final AuthService authService;
  final User user;

  @override
  Widget build(BuildContext context) {
    return HubDashboard(
      repository: FirestoreHubItemRepository(userId: user.uid),
      signedInEmail: user.email,
      onSignOut: authService.signOut,
    );
  }
}
