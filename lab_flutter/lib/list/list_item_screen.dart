import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/item.dart';
import '../providers/connectivity_provider.dart';
import '../providers/item_provider.dart';
import '../screens/add_item_screen.dart';
import '../screens/details_item_screen.dart';
import '../utils/gradient_border_container.dart';

class ItemListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A221E),
      appBar: AppBar(
        title: const Text('ITEMPEDIA',style: TextStyle(color: Color(0xFFDBBABA), fontFamily: 'CinzelDecorative',
            fontSize: 35 ),),
        backgroundColor: const Color(0xFF2A221E),
        actions: [
          // Spinning circle indicator
          ValueListenableBuilder<bool>(
            valueListenable:
                Provider.of<ItemProvider>(context, listen: false).isUpdating,
            builder: (context, isUpdating, child) {
              return isUpdating ? CircularProgressIndicator() : Container();
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: Provider.of<ItemProvider>(context, listen: false).loadItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            // Error handling
          }
          return Consumer<ItemProvider>(
            builder: (context, itemProvider, child) {
              return Container(
                  color: const Color(0xFF2A221E),
                  child: Column(
                    children: [
                      Consumer<ConnectivityProvider>(
                        builder: (context, connectivityProvider, child) {
                          return _buildConnectivityBanner(
                              connectivityProvider.isOffline);
                        },
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: itemProvider.items.length,
                          itemBuilder: (context, index) {
                            return _buildListItem(itemProvider.items[index]);
                          },
                        ),
                      ),
                    ],
                  ));
            },
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 55.0), // Adjust the padding as needed
        child: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddItemScreen()),
          ),
          backgroundColor: Color(0xFFDBBABA),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          mini: true,
          child: Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
    );
  }

  Widget _buildConnectivityBanner(bool isOffline) {
    return Visibility(
      visible: isOffline,
      child: Container(
        color: Colors.red,
        width: double.infinity,
        padding: EdgeInsets.all(8),
        child: Text(
          "OFFLINE",
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildListItem(ValueNotifier<Item> itemNotifier) {
    return ValueListenableBuilder<Item>(
      valueListenable: itemNotifier,
      builder: (context, item, child) {
        Color textColor = _getBorderColor(item.itemRarity);
        Color subtitleColor = Color(0xFFDBBABA);

        // Adjust padding to avoid overlapping the gradient borders with the ListTile
        double padding = 20.0;

        Widget imageWidget = item.localItemPicture!.startsWith('/data/user/0/')
            ? Image.file(File(item.localItemPicture!),scale: 0.1)
            : Image.asset(item.localItemPicture!,scale: 0.1);

        return Container(
          child: CustomPaint(
            painter: GradientBorderPainter(borderColor: textColor),
            child: SizedBox(
              width: double.infinity,
              // space for the gradient borders
              child: Padding(
                padding: EdgeInsets.only(top: 20, bottom: 20),
                child:
                Stack(children:
                [listTile(
                    context, item, imageWidget, textColor, subtitleColor),
                    Positioned(
                      top: 0,
                      right: 10,
                      child: Text(
                        item.itemLevel.toString(),
                        style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            fontFamily: 'Caladea'),
                      ),
                    ),
                  ])
              ),
            ),
          ),
        );
      },
    );
  }

  ListTile listTile(BuildContext context, Item item, Widget imageWidget,
      Color textColor, Color subtitleColor) {
    return ListTile(
      // contentPadding: EdgeInsets.zero, // Reset the default padding of the ListTile
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ItemDetailsScreen(item: item),
          ),
        );
      },
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: imageWidget,
      ),
      title: Text(
        item.itemName,
        style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontFamily: 'Caladea'),
      ),
      subtitle: Text(
        'Type: ${item.itemType}\nEffect: ${item.itemEffect}',
        style: TextStyle(color: subtitleColor, fontFamily: 'Caladea'),
      ),
    );
  }

  //todo best one with best painter
  // Widget _buildListItem(ValueNotifier<Item> itemNotifier) {
  //   return ValueListenableBuilder<Item>(
  //     valueListenable: itemNotifier,
  //     builder: (context, item, child) {
  //       Color textColor = _getBorderColor(item.itemRarity);
  //       Color subtitleColor = Color(0xFFDBBABA);
  //
  //       // Adjust padding to avoid overlapping the gradient borders with the ListTile
  //       double padding = 20.0;
  //
  //       Widget imageWidget = item.localItemPicture!.startsWith('/data/user/0/')
  //           ? Image.file(File(item.localItemPicture!))
  //           : Image.asset(item.localItemPicture!);
  //
  //       return Padding(
  //         padding: EdgeInsets.all(0.0),
  //         child: CustomPaint(
  //           painter:
  //               GradientBorderPainter(borderColor: textColor),
  //           child: SizedBox(
  //             width: double.infinity,
  //             // space for the gradient borders
  //             child: Padding(
  //               padding: EdgeInsets.only(top:20,bottom: 20),
  //               child: ListTile(
  //                 // contentPadding: EdgeInsets.zero, // Reset the default padding of the ListTile
  //                 onTap: () {
  //                   Navigator.of(context).push(
  //                     MaterialPageRoute(
  //                       builder: (context) => ItemDetailsScreen(item: item),
  //                     ),
  //                   );
  //                 },
  //                 leading: ClipRRect(
  //                   borderRadius: BorderRadius.circular(4.0),
  //                   child: imageWidget,
  //                 ),
  //                 title: Text(
  //                   item.itemName,
  //                   style: TextStyle(
  //                       color: textColor,
  //                       fontWeight: FontWeight.bold,
  //                       fontFamily: 'Caladea'),
  //                 ),
  //                 subtitle: Text(
  //                   'Type: ${item.itemType}\nEffect: ${item.itemEffect}',
  //                   style: TextStyle(color: subtitleColor, fontFamily: 'Caladea'),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  // Widget _buildListItem(ValueNotifier<Item> itemNotifier) {
  //   return ValueListenableBuilder<Item>(
  //     valueListenable: itemNotifier,
  //     builder: (context, item, child) {
  //       //Color borderColor = _getBorderColor(item.itemRarity);
  //       Color textColor = _getBorderColor(
  //           item.itemRarity); // Text color for level and item name
  //       Color subtitleColor = Color(0xFFDBBABA); // For type and effect
  //
  //       // Define a widget for the image, handling both file and asset cases
  //       Widget imageWidget = item.localItemPicture!.startsWith('/data/user/0/')
  //           ? Image.file(
  //               File(item.localItemPicture!)) // Display image from file system
  //           : Image.asset(item.localItemPicture!); // Display image from assets
  //
  //       return Container(
  //           margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
  //           child: CustomPaint(
  //             painter: GradientBorderPainter(
  //               borderColor: textColor,
  //               lineHeight: 20.0 //border thickness
  //             ),
  //             // color: const Color(0xFF2A221E),
  //             child: Stack(
  //               children: [
  //                 ListTile(
  //                   onTap: () {
  //                     Navigator.of(context).push(
  //                       MaterialPageRoute(
  //                         builder: (context) => ItemDetailsScreen(item: item),
  //                       ),
  //                     );
  //                   },
  //                   leading: ClipRRect(
  //                     borderRadius: BorderRadius.circular(4.0),
  //                     child: imageWidget,
  //                   ),
  //                   title: Text(
  //                     item.itemName,
  //                     style: TextStyle(
  //                         color: textColor,
  //                         fontWeight: FontWeight.bold,
  //                         fontFamily: 'Caladea'),
  //                   ),
  //                   subtitle: Text(
  //                     'Type: ${item.itemType}\nEffect: ${item.itemEffect}',
  //                     style:
  //                         TextStyle(color: Colors.white, fontFamily: 'Caladea'),
  //                   ),
  //                 ),
  //                 Positioned(
  //                   top: 0,
  //                   right: 8,
  //                   child: Text(
  //                     item.itemLevel.toString(),
  //                     style: TextStyle(
  //                         color: textColor,
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 18,
  //                         fontFamily: 'Caladea'),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ));
  //     },
  //   );
  // }
  //

  Color _getBorderColor(String rarity) {
    switch (rarity) {
      case 'Legendary':
        return Colors.deepOrange;
      case 'Epic':
        return Colors.deepPurple;
      case 'Rare':
        return Colors.blue;
      case 'Uncommon':
        return Colors.green;
      case 'Common':
        return Colors.grey;
      default:
        return Colors.white; // Default color if none of the above
    }
  }

// Widget _buildListItem(ValueNotifier<Item> itemNotifier) {
//   return ValueListenableBuilder<Item>(
//     valueListenable: itemNotifier,
//     builder: (context, item, child) {
//       return Container(
//         color: item.synced != 1 ? Colors.grey : Colors.transparent,
//         // Grey background for unsynced items
//         child: ListTile(
//           onTap: () {
//             Navigator.of(context).push(
//               MaterialPageRoute(
//                 builder: (context) => ItemDetailsScreen(item: item),
//               ),
//             );
//           },
//           leading: item.localItemPicture!.startsWith('/data/user/0/')
//               ? Image.file(File(
//                   item.localItemPicture!)) // Display image from file system
//               : Image.asset(item.localItemPicture!),
//           // Display image from assets
//           title: Text(item.itemName),
//           subtitle: Text(
//               'Level: ${item.itemLevel}  Type: ${item.itemType}\nEffect: ${item.itemEffect}'),
//         ),
//       );
//     },
//   );
// }
}

//pre connectivity banner
// class ItemListPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Item List')),
//         body: FutureBuilder(
//         future: Provider.of<ItemProvider>(context, listen: false).loadItems(),
//     builder: (context, snapshot) {
//     if (snapshot.connectionState == ConnectionState.waiting) {
//     return CircularProgressIndicator(); // Show loading indicator while loading items
//     }
//     if (snapshot.hasError) {
//       print('Error loading items: ${snapshot.error}');
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//     ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(content: Text('Error: ${snapshot.error}')),
//     );
//     });
//
//       // Continue with an empty list of items
//       // Provider.of<ItemProvider>(context, listen: false).setItems([]);
//       // Schedule a microtask to set items to an empty list after the current build cycle because you cannot call setState on a widget when the widget is in the middle of rebuilding
//       Future.microtask(() =>
//           Provider.of<ItemProvider>(context, listen: false).setItems([])
//       );
//     }
//     return Consumer<ItemProvider>(
//         builder: (context, itemProvider, child) {
//           return ListView.builder(
//             itemCount: itemProvider.items.length,
//             itemBuilder: (context, index) {
//               return ValueListenableBuilder<Item>(
//                 valueListenable: itemProvider.items[index],
//                 builder: (context, item, child) {
//                   return Container(
//                     color: item.synced != 1 ? Colors.grey : Colors.transparent, // Grey background for unsynced items
//                     child: ListTile(
//                       onTap: () {
//                     Navigator.of(context).push(
//                       MaterialPageRoute(
//                         builder: (context) => ItemDetailsScreen(item: item),
//                       ),
//                     );
//                   },
//                   leading: item.localItemPicture!.startsWith('/data/user/0/')
//                   ? Image.file(File(item.localItemPicture!)) // Display image from file system
//                       : Image.asset(item.localItemPicture!),      // Display image from assets
//                   title: Text(item.itemName),
//                   subtitle: Text('Level: ${item.itemLevel}  Type: ${item.itemType}\nEffect: ${item.itemEffect}'),
//                   ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//     );
//     },
//         ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => AddItemScreen()),
//         ),
//         child: Icon(Icons.add),
//       ),
//     );
//   }
// }

/*
Pre handling loadItems db error

class ItemListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Item List')),
      body: Consumer<ItemProvider>(
        builder: (context, itemProvider, child) {
          return ListView.builder(
            itemCount: itemProvider.items.length,
            itemBuilder: (context, index) {
              return ValueListenableBuilder<Item>(
                valueListenable: itemProvider.items[index],
                builder: (context, item, child) {
                  return ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ItemDetailsScreen(item: item),
                        ),
                      );
                    },
                    leading: item.itemPicture.startsWith('/data/user/0/')
                        ? Image.file(File(item.itemPicture)) // Display image from file system
                        : Image.asset(item.itemPicture),      // Display image from assets
                    title: Text(item.itemName),
                    subtitle: Text('Level: ${item.itemLevel}  Type: ${item.itemType}\nEffect: ${item.itemEffect}'),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddItemScreen()),
        ),
        child: Icon(Icons.add),
      ),
    );
  }
}

 */
