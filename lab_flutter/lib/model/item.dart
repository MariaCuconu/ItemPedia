class Item {
  String? id;
  String? itemPicture;
  final String itemName;
  final String itemRarity;
  final String itemType;
  final String itemEffect;
  final int itemLevel;
  final String description;
  final String itemLocation;

  int? markedForDeletion;
  int? synced; //0=must be created, 1=is synced, 2=must be updated
  String? localItemPicture;

  Item({
    this.id, // id is not required anymore and can be nullable
    this.itemPicture,
    required this.itemName,
    required this.itemRarity,
    required this.itemType,
    required this.itemEffect,
    required this.itemLevel,
    required this.description,
    required this.itemLocation,
    this.markedForDeletion=0,
    this.synced=0,
    this.localItemPicture
  });

  // Convert an Item object into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id, // Include id only if it's not null
      'itemPicture': itemPicture,
      'itemName': itemName,
      'itemRarity':itemRarity,
      'itemType':itemType,
      'itemEffect':itemEffect,
      'itemLevel':itemLevel,
      'description':description,
      'itemLocation':itemLocation
    };
  }

  Map<String, dynamic> toLocalMap() {
    return {
      if (id != null) 'id': id, // Include id only if it's not null
      'itemPicture': itemPicture,
      'itemName': itemName,
      'itemRarity':itemRarity,
      'itemType':itemType,
      'itemEffect':itemEffect,
      'itemLevel':itemLevel,
      'description':description,
      'itemLocation':itemLocation,
      'markedForDeletion':markedForDeletion,
      'synced':synced,
      'localItemPicture':localItemPicture
    };
  }

  // Construct an Item from a Map
  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      itemPicture: map['itemPicture'],
      itemName: map['itemName'],
      itemRarity: map['itemRarity'],
      itemType: map['itemType'],
      itemEffect: map['itemEffect'],
      itemLevel: map['itemLevel'],
      description: map['description'],
      itemLocation: map['itemLocation']
    );
  }

  factory Item.fromLocalMap(Map<String, dynamic> map) {
    return Item(
        id: map['id'],
        itemPicture: map['itemPicture'],
        itemName: map['itemName'],
        itemRarity: map['itemRarity'],
        itemType: map['itemType'],
        itemEffect: map['itemEffect'],
        itemLevel: map['itemLevel'],
        description: map['description'],
        itemLocation: map['itemLocation'],
        markedForDeletion:map['markedForDeletion'],
        synced:map['synced'],
        localItemPicture: map['localItemPicture']
    );
  }

  void setId(String newId) {
    id = newId;
  }

  @override
  String toString() {
    return 'Item {'
        'id: $id, '
        'itemName: $itemName, '
        '...'
        '}';
  }
  // @override
  // String toString() {
  //   return 'Item {'
  //       'id: $id, '
  //       'itemPicture: $itemPicture, '
  //       'itemName: $itemName, '
  //       'itemRarity: $itemRarity, '
  //       'itemType: $itemType, '
  //       'itemEffect: $itemEffect, '
  //       'itemLevel: $itemLevel, '
  //       'description: $description, '
  //       'itemLocation: $itemLocation, '
  //       'markedForDeletion: $markedForDeletion, '
  //       'synced: $synced, '
  //       'localItemPicture: $localItemPicture'
  //       '}';
  // }

}
