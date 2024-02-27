import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lab_flutter/screens/update_item_screen.dart';

import '../model/item.dart';
import '../utils/delete_confirmation_dialog.dart';
import '../utils/loading_screen.dart';

class ItemDetailsScreen extends StatelessWidget {
  final Item item;

  ItemDetailsScreen({required this.item});

  Color textColor = const Color(0xFFDBBABA);
  TextStyle textStyle = TextStyle(
      color: const Color(0xFFDBBABA),
      fontFamily: 'Caladea',
      fontWeight: FontWeight.bold,
      fontSize: 20);
  Color fillColor = const Color(0xff403434);
  TextStyle altTextstyle = TextStyle(
      color: const Color(0xff403434),
      fontFamily: 'Caladea',
      fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return LoadingWrapper(
      child: Scaffold(
        backgroundColor: const Color(0xFF2A221E),
        appBar: AppBar(
          //title: Text(item.itemName),
          backgroundColor: const Color(0xFF2A221E),
          leading: BackButton(color: textColor),
          actions: [
            IconButton(
              icon: Icon(Icons.delete, color: textColor),
              onPressed: () => _showDeleteConfirmation(context, item),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedItem = await Navigator.push<Item>(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditItemScreen(itemToEdit: item)),
                );
                if (updatedItem != null) {
                  // Refresh the screen with the updated item details
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (_) => ItemDetailsScreen(item: updatedItem)),
                  );
                }
              },
              child: Text('Edit Item', style: altTextstyle),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(textColor),
                  textStyle: MaterialStateProperty.all(altTextstyle)),
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: item.localItemPicture!.startsWith('/data/user/0/')
                    ? Image.file(File(item.localItemPicture!), scale: 0.5)
                    : Image.asset(item.localItemPicture!, scale: 0.5),
              ),
              Padding(
                  padding: const EdgeInsets.only(top:10,bottom: 16.0), // Add padding at the bottom of the text
                  child:Text("${item.itemName}",
                      style: TextStyle(
                        color: Color(0xFFDBBABA),
                        fontFamily: 'CinzelDecorative',
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: const Offset(1.0, 1.0),
                            blurRadius: 3.0,
                            color: Colors.white10.withOpacity(0.5),
                          ),
                        ],
                      )),
              ),

              // Text("Rarity: ${item.itemRarity}",style:textStyle),
              // Text("Type: ${item.itemType}",style:textStyle),
              // Text("Effect: ${item.itemEffect}",style: textStyle,),
              // Text("Level: ${item.itemLevel}\n",style: textStyle,),
              // Text("Description: ${item.description}\n",style: textStyle,),
              // Text("Location: ${item.itemLocation}\n",style: textStyle,),

              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                // Add padding at the bottom of the text
                child: RichText(
                  text: TextSpan(
                    style: textStyle, // Default text style for all spans
                    children: <TextSpan>[
                      TextSpan(
                          text: "Rarity: ",
                          style: TextStyle(
                            fontSize: textStyle.fontSize! * 1.2,
                            shadows: [
                              Shadow(
                                offset: const Offset(1.0, 1.0),
                                blurRadius: 3.0,
                                color: Colors.white10.withOpacity(0.5),
                              ),
                            ],
                          )),

                      // 20% larger font size for the label
                      TextSpan(text: "${item.itemRarity}"),
                      // The actual data in default style
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                // Add padding at the bottom of the text
                child: RichText(
                  text: TextSpan(
                    style: textStyle,
                    children: <TextSpan>[
                      TextSpan(
                          text: "Type: ",
                          style: TextStyle(
                            fontSize: textStyle.fontSize! * 1.2,
                            shadows: [
                              Shadow(
                                offset: const Offset(1.0, 1.0),
                                blurRadius: 3.0,
                                color: Colors.white10.withOpacity(0.5),
                              ),
                            ],
                          )),
                      TextSpan(text: "${item.itemType}"),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                // Add padding at the bottom of the text
                child: RichText(
                  text: TextSpan(
                    style: textStyle,
                    children: <TextSpan>[
                      TextSpan(
                          text: "Effect: ",
                          style: TextStyle(
                            fontSize: textStyle.fontSize! * 1.2,
                            shadows: [
                              Shadow(
                                offset: const Offset(1.0, 1.0),
                                blurRadius: 3.0,
                                color: Colors.white10.withOpacity(0.5),
                              ),
                            ],
                          )),
                      TextSpan(text: "${item.itemEffect}"),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                // Add padding at the bottom of the text
                child: RichText(
                  text: TextSpan(
                    style: textStyle,
                    children: <TextSpan>[
                      TextSpan(
                          text: "Level: ",
                          style: TextStyle(
                            fontSize: textStyle.fontSize! * 1.2,
                            shadows: [
                              Shadow(
                                offset: const Offset(1.0, 1.0),
                                blurRadius: 3.0,
                                color: Colors.white10.withOpacity(0.5),
                              ),
                            ],
                          )),
                      TextSpan(text: "${item.itemLevel}"),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                // Add padding at the bottom of the text
                child: RichText(
                  text: TextSpan(
                    style: textStyle,
                    children: <TextSpan>[
                      TextSpan(
                          text: "Description: ",
                          style: TextStyle(
                            fontSize: textStyle.fontSize! * 1.2,
                            shadows: [
                              Shadow(
                                offset: const Offset(1.0, 1.0),
                                blurRadius: 3.0,
                                color: Colors.white10.withOpacity(0.5),
                              ),
                            ],
                          )),
                      TextSpan(text: "${item.description}"),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                // Add padding at the bottom of the text
                child: RichText(
                  text: TextSpan(
                    style: textStyle,
                    children: <TextSpan>[
                      TextSpan(
                          text: "Location: ",
                          style: TextStyle(
                            fontSize: textStyle.fontSize! * 1.2,
                            shadows: [
                              Shadow(
                                offset: const Offset(1.0, 1.0),
                                blurRadius: 3.0,
                                color: Colors.white10.withOpacity(0.5),
                              ),
                            ],
                          )),
                      TextSpan(text: "${item.itemLocation}"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Item item) {
    showDialog(
      context: context,
      builder: (ctx) => DeleteConfirmationDialog(item: item),
    );
  }

// void _showDeleteConfirmation(BuildContext context, Item item) {
//   showDialog(
//     context: context,
//     builder: (ctx) => AlertDialog(
//       title: Text('Confirm Deletion'),
//       content: Text('Do you want to delete this item?'),
//       actions: <Widget>[
//         TextButton(
//           child: Text('No'),
//           onPressed: () {
//             Navigator.of(ctx).pop(); // Close the dialog
//           },
//         ),
//         TextButton(
//           child: Text('Yes'),
//           onPressed: () async {
//             try
//             {
//               await Provider.of<ItemProvider>(context, listen: false).removeItem(
//                   item.id!,item.synced!);
//               Navigator.of(ctx).pop(); // Close the dialog
//               Navigator.of(context).pop(); // Go back to previous screen
//             } catch (e){
//               print("Error: $e"); // Logging the error
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text(e.toString())),
//               );
//             }
//           },
//         ),
//       ],
//     ),
//   );
// }
}
