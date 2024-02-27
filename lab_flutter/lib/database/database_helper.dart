import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';
import '../model/item.dart';
import 'package:uuid/uuid.dart';

import '../utils/custom_log_printer.dart';

class DatabaseHelper {
  static final _databaseName = "Database11.db";
  static final _databaseVersion = 1;
  static final table = 'items';

  // Singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  final LOG =  Logger(printer: CustomLogPrinter());

  Future<Database> _initDatabase() async {
    String path = await getDatabasesPath() + _databaseName;
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $table (
      id TEXT PRIMARY KEY,
      itemPicture TEXT,
      localItemPicture TEXT NOT NULL,
      itemName TEXT NOT NULL,
      itemRarity TEXT NOT NULL,
      itemType TEXT NOT NULL,
      itemEffect TEXT NOT NULL,
      itemLevel INTEGER NOT NULL,
      description TEXT NOT NULL,
      itemLocation TEXT NOT NULL,
      markedForDeletion INTEGER NOT NULL,
      synced INTEGER NOT NULL
    )
  ''');
  }

  // Create
  Future<int> insertItem(Item item) async {
    Database db = await database;
    LOG.d('Saving item ${item.toString()} to local db');
    return await db.insert(table, item.toLocalMap());
  }

  // Read all items
  Future<List<Item>> getItems() async {
    LOG.i('Fetching items from the local database');
    Database db = await database;
    //var items = await db.query(table);
    var items = await db.query(table, where: 'markedForDeletion = 0');
    return List.generate(items.length, (i) {
      return Item.fromLocalMap(items[i]);
    });
  }

  Future<Item?> getItemById(String id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(table, where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Item.fromLocalMap(maps.first);
    } else {
      return null; //not found
    }
  }


  // Update
  Future<String?> updateItem(Item item) async {
    Database db = await database;
    LOG.d('Updating item ${item.toString()} in local db');
    await db.update(table, item.toLocalMap(),
        where: 'id = ?', whereArgs: [item.id]);
    return item.id;
  }

  // Delete
  Future<String> deleteItem(String id) async {
    Database db = await database;
    LOG.d('Deleting item with id $id from local db');
    await db.delete(table, where: 'id = ?', whereArgs: [id]);
    return id;
  }

  // Replace all items in the database
  Future<void> replaceAllItems(List<Item> items) async {
    Database db = await database;
    await db.delete(table); // Clear the table
    for (var item in items) {
      await db.insert(table, item.toLocalMap());
    }
  }

  // Mark an item for deletion
  Future<void> markItemForDeletion(String id) async {
    Database db = await database;
    await db.update(
      table,
      {'markedForDeletion': 1, 'synced': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get all unsynced items
  Future<List<Item>> getUnsyncedItems() async {
    Database db = await database;
    var unsynced = await db.query(table, where: 'synced != 1');
    return unsynced.map((item) => Item.fromLocalMap(item)).toList();
  }

}
