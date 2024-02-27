import 'package:flutter/cupertino.dart';

import '../database/repository.dart';

class ConnectivityProvider with ChangeNotifier {
  final Repository repository;

  ConnectivityProvider(this.repository) {
    repository.isOfflineNotifier.addListener(_handleConnectivityChange);
  }

  void _handleConnectivityChange() {
    notifyListeners();
  }

  bool get isOffline => repository.isOffline;

  @override
  void dispose() {
    repository.isOfflineNotifier.removeListener(_handleConnectivityChange);
    super.dispose();
  }
}
