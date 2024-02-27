import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/item_provider.dart';

class LoadingWrapper extends StatelessWidget {
  final Widget child;

  LoadingWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        child, // Your main content
        Consumer<ItemProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return AbsorbPointer(
                absorbing: true,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            } else {
              return SizedBox.shrink(); // Return an empty widget when not loading
            }
          },
        ),
      ],
    );
  }
}
