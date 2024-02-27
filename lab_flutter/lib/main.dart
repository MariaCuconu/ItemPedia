import 'package:flutter/material.dart';
import 'package:lab_flutter/providers/connectivity_provider.dart';
import 'package:lab_flutter/server/api_service.dart';
import 'package:lab_flutter/utils/loading_screen.dart';
import 'database/database_helper.dart';
import 'database/repository.dart';
import 'list/list_item_screen.dart';
import 'providers/item_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final ItemProvider _itemProvider;
  late final ConnectivityProvider _connectivityProvider;

  @override
  void initState() {
    super.initState();
    var repository = Repository(DatabaseHelper.instance, ApiService());
    _itemProvider = ItemProvider(repository);
    _connectivityProvider = ConnectivityProvider(repository);

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _itemProvider.startCheckingForSync();
    });
  }

  @override
  void dispose() {
    // Perform asynchronous disconnect in a non-blocking manner
    _itemProvider.disconnectWebSocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _itemProvider),
        ChangeNotifierProvider.value(value: _connectivityProvider),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Item List',
        home: LoadingWrapper(child: ItemListPage()),
      ),
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   return ChangeNotifierProvider.value(
  //     value: _itemProvider,
  //     child: MaterialApp(
  //       title: 'Flutter Item List',
  //       home: LoadingWrapper(
  //         child: ItemListPage(),
  //       ),
  //     ),
  //   );
  // }
}


// class _MyAppState extends State<MyApp> {
//
//   @override
//   Widget build(BuildContext context) {
//     final repository = Repository(DatabaseHelper.instance, ApiService());
//
//     return ChangeNotifierProvider(
//       create: (context) => ItemProvider(repository),
//       child: Builder(
//         builder: (newContext) {
//           // Start checking for sync after the first frame has been rendered
//           WidgetsBinding.instance!.addPostFrameCallback((_) {
//             Provider.of<ItemProvider>(newContext, listen: false).startCheckingForSync();
//           });
//
//           return MaterialApp(
//             title: 'Flutter Item List',
//             home: LoadingWrapper(
//               child: ItemListPage(),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
// }

/*
void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late Repository repository;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    repository = Repository(DatabaseHelper.instance, ApiService());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    repository.disconnectWebSocket(); // Clean up WebSocket connection
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // Optionally handle other lifecycle states like inactive or resumed
      repository.disconnectWebSocket();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ItemProvider(repository),
      child: Builder(
        builder: (newContext) {
          // Start checking for sync after the first frame has been rendered
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<ItemProvider>(newContext, listen: false).startCheckingForSync();
          });

          return MaterialApp(
            title: 'Flutter Item List',
            home: LoadingWrapper(
              child: ItemListPage(),
            ),
          );
        },
      ),
    );
  }
}
 */



// void main() {
//   runApp(MyApp());
// }
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final repository = Repository(DatabaseHelper.instance, ApiService());
//
//     return ChangeNotifierProvider(
//       create: (context) => ItemProvider(repository),
//       child: MaterialApp(
//         title: 'Flutter Item List',
//         home: LoadingWrapper(
//           child: ItemListPage(),
//         ),
//       ),
//     );
//   }
// }
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final repository = Repository(DatabaseHelper.instance,ApiService());
//
//     return ChangeNotifierProvider(
//       create: (context) => ItemProvider(repository),
//       child: MaterialApp(
//         title: 'Flutter Item List',
//         home: ItemListPage(),
//       ),
//     );
//   }
// }
