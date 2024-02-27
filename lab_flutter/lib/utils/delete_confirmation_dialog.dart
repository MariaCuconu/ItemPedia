import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../model/item.dart';
import '../providers/item_provider.dart';
import 'custom_log_printer.dart';
import 'loading_screen.dart';

class DeleteConfirmationDialog extends StatefulWidget {
  final Item item;


  DeleteConfirmationDialog({required this.item});

  @override
  _DeleteConfirmationDialogState createState() => _DeleteConfirmationDialogState();
}

class _DeleteConfirmationDialogState extends State<DeleteConfirmationDialog> {

  final LOG =  Logger(printer: CustomLogPrinter());

  @override
  Widget build(BuildContext context) {
    return LoadingWrapper(
      child: AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Do you want to delete this item?'),
        actions: <Widget>[
          TextButton(
            child: Text('No'),
            onPressed: () => Navigator.of(context).pop(), // Close the dialog
          ),
          TextButton(
            child: Text('Yes'),
            onPressed: () async {
              try {
                await Provider.of<ItemProvider>(context, listen: false).removeItem(
                    widget.item.id!, widget.item.synced!);
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Go back to previous screen
              } catch (e) {
                LOG.w("$e"); // Logging the error
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
