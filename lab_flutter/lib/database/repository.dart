import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../model/item.dart';
import '../server/api_service.dart';
import '../utils/custom_log_printer.dart';
import 'database_helper.dart';

class Repository {
  bool needToSync = true;
  bool isOffline = true;
  ValueNotifier<bool> isOfflineNotifier = ValueNotifier(true);

  final DatabaseHelper databaseHelper;
  final ApiService apiService;

  int _failedHealthChecks = 0; // Add this counter

  final LOG =  Logger(printer: CustomLogPrinter());

  Repository(this.databaseHelper, this.apiService) {
    startHealthCheck();
  }

  // initial fetch before connection to server
  Future<List<Item>> getItems() async {

    return await databaseHelper.getItems();

  }

  // Sync unsynced changes to the server
  Future<List<Item>> syncWithServer() async {
    try {
      // Fetch all unsynced items
      LOG.i('Fetching unsynced items from local db');
      var unsyncedItems = await databaseHelper.getUnsyncedItems();

      // Sync each item
      LOG.i('Sending unsynced items from local db to update on server');
      for (var item in unsyncedItems) {
        if (item.markedForDeletion == 1) {
          await apiService.deleteItem(item.id!);
        } else if (item.synced == 0) {
          //must be created
          try {
            File imageFile = File(item.localItemPicture!);
            String? imageUrl = await apiService.uploadImage(imageFile);
            item.itemPicture =
                imageUrl!; // Update the item picture with the server URL for the server request
          } catch (e) {
            LOG.w('Couldnt upload image ${item.localItemPicture!}');
            item.itemPicture="/uploads/16d4920e-1900-4d66-8a0a-a6997bf98080.jpg";
          }
          await apiService.addItem(item);
        } else if (item.synced == 2) {
          //must be updated
          try {
            File imageFile = File(item.localItemPicture!);
            String? imageUrl = await apiService.uploadImage(imageFile);
            item.itemPicture =
                imageUrl!; // Update the item picture with the server URL for the server request
          } catch (e) {
            LOG.w('Couldnt upload image ${item.itemPicture}');
            item.itemPicture="/uploads/16d4920e-1900-4d66-8a0a-a6997bf98080.jpg";
          }
          await apiService.updateItem(item.id!, item);
        }
      }

      // Fetch fresh data from server
      var freshItems = await apiService.getItems();
      LOG.i('Downloading images');
      for (var item in freshItems) {
        if (item.itemPicture != null &&
            item.itemPicture!.isNotEmpty) {
          try {
            item.localItemPicture = await _downloadAndStoreImage(
                item.itemPicture!, item.id!);
          }
          catch(e){
            LOG.i('Failed to download new image: ${e.toString()}. Setting placeholder...');
            item.localItemPicture='assets/placeholder.jpg';
          }
        }
        item.synced = 1;
        item.markedForDeletion = 0;
      }
      LOG.i('Repopulating local db');
      await databaseHelper.replaceAllItems(freshItems);
      return databaseHelper.getItems();
    } catch (e) {
      // Handle failure to sync
      LOG.w('Failed to sync with server: $e');
      // On failure, fallback to local database
      return await databaseHelper.getItems();
    }
  }

  // Adds an item, tries server first, falls back to local DB
  Future<String?> addItem(Item item) async {
    File imageFile = File(item.localItemPicture!);

    try {
      String? imageUrl = await apiService.uploadImage(imageFile);
      item.itemPicture =
          imageUrl!; // Update the item picture with the server URL for the server request
    } catch (e) {
      LOG.w('Couldnt upload image');
      item.itemPicture="/uploads/16d4920e-1900-4d66-8a0a-a6997bf98080.jpg";
    }

    try {
      String localItemPicture = item.localItemPicture!;
      var response = await apiService.addItem(item);
      // item.markedForDeletion = 0; // Not marked for deletion
      // item.synced = 1; // Mark as synced
      item.id=response.id;
      item.markedForDeletion = 0; // Not marked for deletion
      item.synced = 1; // Mark as synced
      item.localItemPicture = localItemPicture;

      // item.itemPicture=localItemPicture;
      await databaseHelper.insertItem(item); // Save to local DB
      return item.id;
    } catch (e) {
      //OFFLINE
      item.markedForDeletion = 0; // Not marked for deletion
      item.synced = 0; // Mark as unsynced
      var uuid = Uuid();
      String id = uuid.v4();
      item.setId(id);

      // item.itemPicture=localItemPicture;
      await databaseHelper.insertItem(item); // Save to local DB
      //throw Exception("Simulated database errorrrrr");
      return item.id;
    }
  }

  Future<Item?> updateItem(Item newItem, String originalLocalItemPicture,
      String originalItemPicture, int syncStatus) async {
    // Only upload the image if it has been changed
    if (newItem.localItemPicture != null &&
        newItem.localItemPicture!.isNotEmpty &&
        newItem.localItemPicture != originalLocalItemPicture) {
      File imageFile = File(newItem.localItemPicture!);

      try {
        String? imageUrl = await apiService.uploadImage(imageFile);
        newItem.itemPicture =
            imageUrl!; // Update the item picture with the server URL for the server request
      } catch (e) {
        LOG.w('Couldnt upload image');
        newItem.itemPicture="/uploads/16d4920e-1900-4d66-8a0a-a6997bf98080.jpg";
      }
    } else {
      //image hasnt been changed
      newItem.itemPicture = originalItemPicture;
    }

    try {
      String localItemPicture = newItem.localItemPicture!;
      var response = await apiService.updateItem(newItem.id!, newItem);
      if(response!=null){
      response.synced = 1;
      response.markedForDeletion = 0;
      response.localItemPicture = localItemPicture;
      await databaseHelper.updateItem(response);
      newItem=response;
      return newItem;
      }
      else{
        //item was not found on server, delete locally as well
        await databaseHelper.deleteItem(newItem.id!);
        return null;
      }
    } catch (e) {
      //OFFLINE
      if (syncStatus == 0) {
        newItem.synced = 0; //hasnt been created yet
      } else {
        newItem.synced = 2; //has been created, must be only updated
      }
      newItem.markedForDeletion = 0;
      await databaseHelper.updateItem(newItem);
      return newItem;
    }
  }

  // Marks an item for deletion
  Future<void> deleteItem(String id, int synced) async {
    try {
      await apiService.deleteItem(id);
      await databaseHelper.deleteItem(id);
    } catch (e) {
      if (synced != 0) {
        await databaseHelper.markItemForDeletion(id);
      } else //if synced==0, it means item was created only locally, can be removed only locally
      {
        await databaseHelper.deleteItem(id);
      }
    }
  }

  Future<String> _downloadAndStoreImage(
      String imageUrl, String fileName) async {

    fileName='image_${fileName}_${extractUuid(imageUrl)}';

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';

    // Concatenate the base URL with the relative image URL
    final fullImageUrl = apiService.baseUrl + imageUrl;

    final response = await http.get(Uri.parse(fullImageUrl));

    if (response.statusCode == 200) {
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return filePath;
    } else {
      throw Exception('Failed to download image');
    }
  }

  String extractUuid(String path) {
    final uuidPattern = RegExp(r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}');
    final match = uuidPattern.firstMatch(path);
    return match != null ? match.group(0)! : '';
  }

  Timer? _healthCheckTimer;

  void startHealthCheck() {
    _healthCheckTimer = Timer.periodic(Duration(seconds: 5), (Timer t) async {
      // print('IN REPO isOffline=' + isOffline.toString() + "\n");
      // print('IN REPO needToSync=' + needToSync.toString() + "\n");
      try {
        await apiService.healthCheck();
        _failedHealthChecks = 0; // Reset the counter on successful health check
        if (isOffline) {
          //was offline
          LOG.i('Health check successful. Going ONLINE');
          isOffline = false; //go online
          isOfflineNotifier.value = isOffline;
          needToSync = true; //must sync
        }
      } catch (e) {
        _failedHealthChecks++; // Increment the counter on failure
        if (_failedHealthChecks >= 3 && !isOffline) { // Check if failed 3 times
          LOG.w('Health check failed 3 times. Going OFFLINE');
          isOffline = true; //go offline
          isOfflineNotifier.value = isOffline;
          needToSync = true; //must sync
        }
      }
    });
  }

  //old health check, one healthCheck unanswered->sync
  // void startHealthCheck() {
  //   _healthCheckTimer = Timer.periodic(Duration(seconds: 5), (Timer t) async {
  //     // print('IN REPO isOffline=' + isOffline.toString() + "\n");
  //     // print('IN REPO needToSync=' + needToSync.toString() + "\n");
  //     try {
  //       await apiService.healthCheck();
  //       if (isOffline) {
  //         //was offline
  //         isOffline = false; //go online
  //         isOfflineNotifier.value=isOffline;
  //         needToSync = true; //must sync
  //       }
  //     } catch (e) {
  //       if (!isOffline) {
  //         print('Health check failed. Going offline');
  //         isOffline = true; //go offline
  //         isOfflineNotifier.value=isOffline;
  //         needToSync = true; //must sync
  //       }
  //     }
  //   });
  // }

  ///SOCKET LOGIC
  Future<int?> insertItemFromSocket(Item newItem) async {
    try {
      var existingItem = await databaseHelper.getItemById(newItem.id!);
      if(existingItem==null) { //new item, add
        try {
          String localImagePath = await _downloadAndStoreImage(newItem.itemPicture!, newItem.id!);
          newItem.localItemPicture = localImagePath;
        } catch (e) {
          LOG.w('Failed to download new image: ${e.toString()}. Setting placeholder...');
          newItem.localItemPicture='assets/placeholder.jpg';
        }
        newItem.synced=1;
        return await databaseHelper.insertItem(newItem);
      }
      else {
        return null;
      }
    }
    catch(e){
      //item already exists, is the one we added
      return null;
    }
  }
  ///SOCKET LOGIC
  Future<String?> updateItemFromSocket(Item updatedItem) async {
    // Fetch the current item from the local database
    var existingItem = await databaseHelper.getItemById(updatedItem.id!);

    if (existingItem != null) {
      // Check if the image has changed
      if (existingItem.itemPicture != updatedItem.itemPicture) {
        // Download the new image and update the local path
        try {
          String newImagePath = await _downloadAndStoreImage(updatedItem.itemPicture!, updatedItem.id!);
          updatedItem.localItemPicture = newImagePath;
          updatedItem.synced=1;
          updatedItem.markedForDeletion=0;
        } catch(e){
          LOG.w('Failed to download new image: ${e.toString()}. Setting placeholder...');
          updatedItem.localItemPicture='assets/placeholder.jpg';
        }
      }
      else{ //localItemPicture hasnt changed
        updatedItem.localItemPicture=existingItem.localItemPicture;
        updatedItem.synced=1;
        updatedItem.markedForDeletion=0;
      }
      // Update the item in the local database
      var response=await databaseHelper.updateItem(updatedItem);
      return response;
    } else {
      //LOG.w('Item not found for update from socket');
      return null;
    }
  }
  ///SOCKET LOGIC
  Future<String?> deleteItemFromSocket(String id) async {
    try{
    var existingItem = await databaseHelper.getItemById(id);
    if (existingItem != null) {
      await databaseHelper.deleteItem(id);
      return id;
    } else {
      return null;
    }
    }
    catch(e){
      return null;
    }
  }

  Future<Item?> getItemById(String id) async{
    var existingItem = await databaseHelper.getItemById(id);
      return existingItem;

  }

}
