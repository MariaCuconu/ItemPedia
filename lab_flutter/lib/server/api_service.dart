import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../model/item.dart';

import 'dart:io';

import '../utils/custom_log_printer.dart';

class ApiService {
  final String baseUrl = 'http://192.168.1.184:8080/api/items';
  final LOG =  Logger(printer: CustomLogPrinter());

  Future<List<Item>> getItems() async {
    LOG.i('Fetching fresh data from the server');
    try {
      LOG.d('Sending GET $baseUrl');
      final response = await http.get(Uri.parse(baseUrl)).timeout(Duration(seconds: 3));
      if (response.statusCode == 200) {
        LOG.i('200 response');
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((item) => Item.fromMap(item)).toList();
      } else {
        LOG.w('Server GET all failed with status code: ${response.statusCode}');
        throw Exception('Failed to load items from server with status code: ${response.statusCode}');
      }
    } on TimeoutException catch (e) {
      LOG.w('Request to server timed out');
      throw Exception('Request to server timed out');
    } catch (e) {
      LOG.d('Failed to fetch items from server: $e');
      throw Exception('Failed to load items from server');
    }
  }

  Future<Item> addItem(Item item) async {
    try {
      LOG.d('Sending POST $baseUrl with ${item.toString()}');
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(item.toMap()),
      ).timeout(Duration(milliseconds: 1500));
      if (response.statusCode != 200) {
        throw Exception('Failed to add item to server');
      } else {
        LOG.d('Added item ${item.toString()} to server');
        var jsonResponse = json.decode(response.body);
        return Item.fromMap(jsonResponse);
      }
    } on TimeoutException catch (e) {
      LOG.d('Request to server timed out');
      throw Exception('Request to server timed out');
    } catch (e) {
      throw Exception('Failed to add item to server: $e');
    }
  }

  Future<Item?> updateItem(String id, Item item) async {
    try {
      LOG.d('Sending PUT $baseUrl/$id with ${item.toString()}');
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(item.toMap()),
      ).timeout(Duration(milliseconds: 1500));

      if(response.statusCode == 200){
        LOG.d('Updated item ${item.toString()} on server');
        var jsonResponse = json.decode(response.body);
        return Item.fromMap(jsonResponse);
      }
      else if(response.statusCode == 404){
        //item was deleted on server, delete it as well
        LOG.i('Item not found on server, should delete locally as well');
        return null;
      }
      else {
        throw Exception('Failed to update item on server');
      }
    } on TimeoutException catch (e) {
      LOG.w('Request to server timed out');
      throw Exception('Request to server timed out');
    } catch (e) {
      throw Exception('Failed to update item on server: $e');
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      LOG.d('Sending DELETE $baseUrl/$id');
      final response = await http.delete(Uri.parse('$baseUrl/$id'))
          .timeout(Duration(milliseconds: 1500));
      if(response.statusCode==404){
        LOG.i('Item not found on server, should delete locally as well');
      }
      else if(response.statusCode==200){
        LOG.d('Deleted item with id ${id} from server');
      }
      else {
        throw Exception('Failed to delete item from server');
      }
    } on TimeoutException catch (e) {
      LOG.w('Request to server timed out');
      throw Exception('Request to server timed out');
    } catch (e) {
      throw Exception('Failed to delete item from server: $e');
    }
  }

  Future<String?> uploadImage(File imageFile) async {
    try {
      LOG.d('Sending POST $baseUrl/upload with ${imageFile.path}');
      var uri = Uri.parse(baseUrl + "/upload");
      var request = http.MultipartRequest("POST", uri);
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      var response = await request.send().timeout(Duration(milliseconds: 1500));

      if (response.statusCode == 200) {
        LOG.d('Uploaded image ${imageFile} on server');
        var responseBody = await response.stream.bytesToString();
        return responseBody;
      } else {
        throw Exception('Failed to upload image');
      }
    } on TimeoutException catch (e) {
      LOG.w('Request to server timed out');
      throw Exception('Request to server timed out');
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  //health check
  Future<void> healthCheck() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'))
          .timeout(Duration(seconds: 1));
      if (response.statusCode != 200) {
        throw Exception('Health down');
      }
    } on TimeoutException catch (e) {
      LOG.i('Health check request to server timed out');
      throw Exception('Health down');
    }
  }
}
