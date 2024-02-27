import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../database/repository.dart';
import '../model/item.dart';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

import '../utils/custom_log_printer.dart';

class ItemProvider with ChangeNotifier {
  final Repository repository;
  List<ValueNotifier<Item>> items = [];

  bool isLoading = false;

  WebSocketChannel? _channel;
  final Queue<String> _messageQueue = Queue<String>();

  // notifier for socket updates
  ValueNotifier<bool> isUpdating = ValueNotifier(false);

  final LOG =  Logger(printer: CustomLogPrinter());

  ItemProvider(this.repository) {
    //_loadItems();
  }

  void setItems(List<Item> newItems) {
    items = newItems.map((item) => ValueNotifier(item)).toList();
    notifyListeners();
  }

  // Load items from the database
  Future<void> loadItems() async {
    try {
      List<Item> itemList = await repository.getItems();
      items = itemList.map((item) => ValueNotifier(item)).toList();
    } catch (e) {
      // Throw the error to be caught in the UI layer
      throw Exception('Failed to load items from local db: ${e.toString()}');
    } finally {
      notifyListeners();
    }
  }

  // Add item
  Future<void> addItem(Item item) async {
    try {
      String? id = await repository.addItem(item);
      item.setId(id!);
      items.add(ValueNotifier(item));
    } catch (e) {
      // Throw the error to be caught in the UI layer
      throw Exception('Failed to add item: ${e.toString()}');
    } finally {
      notifyListeners();
    }
  }

  // Remove item
  Future<void> removeItem(String id, int synced) async {
    try {
      await repository.deleteItem(id,synced);
      items.removeWhere((item) => item.value.id == id);
    } catch (e) {
      // Throw the error to be caught in the UI layer
      throw Exception('Failed to remove item: ${e.toString()}');
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateItem(Item newItem) async {
    final index = items.indexWhere((item) => item.value.id == newItem.id);
    if (index >= 0) {
      try {
        // Get the original image path
        String originalLocalItemPicture = items[index].value.localItemPicture ?? ""; //compare with local saved file
        String originalItemPicture = items[index].value.itemPicture ?? ""; //keep server image for request
        int syncStatus = items[index].value.synced ?? 0;
        Item? updatedItem=await repository.updateItem(newItem, originalLocalItemPicture, originalItemPicture, syncStatus);
        if(updatedItem!=null){
          items[index].value = updatedItem;
        }
      } catch (e) {
        // Throw the error to be caught in the UI layer
        throw Exception('Failed to update item: ${e.toString()}');
      } finally {
        // ValueNotifier will handle notifying listeners
      }
    }
    else{
      //item was deleted mid update
      throw Exception('Item has been deleted in the meantime ');
    }
  }

  void checkForSync() async {
    while(true)
    {
      //print('IN PROVIDER isOffline='+repository.isOffline.toString()+"\n");
      //print('IN PROVIDER needToSync='+repository.needToSync.toString()+"\n");
      if (repository.needToSync && !repository.isOffline) {
        isLoading = true;
        LOG.i('App loading...sync started');
        notifyListeners(); // Notify widgets to rebuild

        await connectToWebSocket();
        var newItems = await repository.syncWithServer(); //sync with server

        setItems(newItems);

        isLoading = false;
        repository.isOffline = false;
        repository.isOfflineNotifier.value=repository.isOffline;
        repository.needToSync = false;

        notifyListeners(); // Notify widgets again after sync is complete

        _processQueue(); // Process any messages that arrived during synchronization
      }
      await Future.delayed(Duration(seconds: 2));
    }
  }

  // Call this method in your UI when appropriate, e.g., in initState() of a widget
  void startCheckingForSync() {
    //Timer.periodic(Duration(seconds: 2), (timer) => checkForSync());
    checkForSync();
  }
/*
  // _channel!.stream.listen((message) {
    //   if (isLoading || _messageQueue.isNotEmpty) {
    //     // Add message to queue if syncing or messages still left to process
    //     _messageQueue.add(message);
    //     if(!isLoading & _messageQueue.isNotEmpty){
    //       _processWebSocketMessage(_messageQueue.removeAt(0));
    //     }
    //   } else {
    //     // Process message immediately if not syncing
    //     _processWebSocketMessage(message);
    //   }
    // });
 */

  // void connectToWebSocket() {
  //   _channel = WebSocketChannel.connect(
  //     Uri.parse('ws://192.168.1.184:8080/ws'),
  //   );
  //
  //   _channel!.stream.listen((message) {
  //     print('SOCKET: ${message}\n');
  //     _messageQueue.add(message);
  //     if (!isLoading) {
  //       _processQueue();
  //     }
  //   });
  //
  //   // Send STOMP connect frame
  //   _channel!.sink.add('CONNECT\naccept-version:1.2\n\n\x00');
  //
  //   // Wait for the server to acknowledge the connection
  //   Future.delayed(Duration(seconds: 1), () {
  //     // Send STOMP subscribe frame
  //     _channel!.sink.add('SUBSCRIBE\nid:sub-0\ndestination:/topic/itemUpdate\n\n\x00');
  //   });
  // }
  Future<void> connectToWebSocket() async {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.1.184:8080/ws'),
    );

    bool isConnected = false;

    // Single listener for handling all WebSocket messages
    _channel!.stream.listen((message) {
      // Check for server's connection acknowledgment
      if (!isConnected && message.contains('CONNECTED')) {
        isConnected = true;
        LOG.i('Websocket connected');
        // Server acknowledged the connection
        // Send STOMP subscribe frame
        _channel!.sink.add('SUBSCRIBE\nid:sub-0\ndestination:/topic/itemUpdate\n\n\x00');
      } else if (isConnected) {
        // Handle regular messages once connected and subscribed
        //print('SOCKET: ${message}\n');
        _messageQueue.add(message);
        if (!repository.needToSync) {
          _processQueue();
        }
      }
    },
      onDone: () {
        // Handle WebSocket closing
        LOG.i('WebSocket connection closed by the server');
        _channel!.sink.close();
      },
      onError: (error) {
        // Handle errors
        LOG.w('WebSocket error: $error');
        _channel!.sink.close();
      },

    );

    // Send STOMP connect frame
    _channel!.sink.add('CONNECT\naccept-version:1.2\n\n\x00');
  }



  void _processQueue() async {
    while (_messageQueue.isNotEmpty) {
      var message = _messageQueue.removeFirst();
      await _processWebSocketMessage(message);
    }
    // Notify listeners after processing the queue
    //notifyListeners(); will happen in _processWebSocketMessage
  }

  //todo notifyListeners() after modifications
  Future<void> _processWebSocketMessage(String message) async {
    try {
      // Find the start index of the JSON payload
      var jsonStartIndex = message.indexOf('{"operation":');
      if (jsonStartIndex >= 0) {
        // Extract JSON from the start index
        var jsonString = message.substring(jsonStartIndex);

        // Remove any trailing NUL characters
        jsonString = jsonString.replaceAll('\x00', '').trim();

        // Decode the JSON string
        var data = json.decode(jsonString);
        switch (data['operation']) {
          case 'CREATE':
            LOG.i('Processing SOCKET create\n');
            Item newItem=Item.fromMap(data['item']);
            var result=await repository.insertItemFromSocket(newItem);
            if(result!=null){
              items.add(ValueNotifier(newItem));
              notifyUpdate();
            }
            break;
          case 'UPDATE':
            LOG.i('Processing SOCKET update\n');
            String? index=await repository.updateItemFromSocket(Item.fromMap(data['item']));
            await updateItemFromSocket(index);
            break;
          case 'DELETE':
            LOG.i('Processing SOCKET delete\n');
            String id=data['id'];
            var result=await repository.deleteItemFromSocket(id);
            if(result!=null){
              items.removeWhere((item) => item.value.id == id);
              notifyUpdate();
            }
            break;
          default:
            LOG.i('Unknown operation received from WebSocket');
            break;
        }
      } else {
        LOG.d('Error: JSON payload not found in the message.');
      }
    } catch (e) {
      LOG.d('Error processing WebSocket message: $e');
    }
    finally {
      notifyListeners();
    }
  }

  Future<void> updateItemFromSocket(String? index) async {
    if(index!=null) {
      Item? newItem = await repository.getItemById(index);
      if (newItem != null) {
        final index = items.indexWhere((item) => item.value.id == newItem.id);
        items[index].value = newItem;
        notifyUpdate();
      }
    }
  }

  void disconnectWebSocket() {
    // Send STOMP disconnect frame
    _channel!.sink.add('DISCONNECT\n\n\x00');

    // Close the WebSocket connection after a short delay
    Future.delayed(Duration(seconds: 1), () {
      _channel!.sink.close();
      LOG.i('Websocket disconnected');
    });
  }

  //for ui notify process of socket
  void notifyUpdate() {
    isUpdating.value = true;
    // Hide the indicator after 2 seconds
    Future.delayed(Duration(seconds: 1), () {
      isUpdating.value = false;
    });
  }

}
