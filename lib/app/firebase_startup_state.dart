enum FirebaseStartupStatus { ready, notConfigured, failed }

class FirebaseStartupState {
  const FirebaseStartupState._({required this.status, this.message});

  const FirebaseStartupState.ready()
    : this._(status: FirebaseStartupStatus.ready);

  const FirebaseStartupState.notConfigured(String message)
    : this._(status: FirebaseStartupStatus.notConfigured, message: message);

  const FirebaseStartupState.failed(String message)
    : this._(status: FirebaseStartupStatus.failed, message: message);

  final FirebaseStartupStatus status;
  final String? message;
}
