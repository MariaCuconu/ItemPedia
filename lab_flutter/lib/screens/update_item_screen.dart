import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../model/item.dart';
import '../providers/item_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../utils/custom_log_printer.dart';
import '../utils/loading_screen.dart';

class EditItemScreen extends StatefulWidget {
  final Item? itemToEdit;

  EditItemScreen({this.itemToEdit});

  @override
  _EditItemScreenState createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  bool isAssetImage = false;
  late String itemName;
  late String itemRarity;
  late String itemType;
  late String itemEffect;
  late int itemLevel;
  late String description;
  late String itemLocation;
  late String itemPicture; //server

  bool _isAwaiting = false;

  final LOG =  Logger(printer: CustomLogPrinter());

  Color textColor =const Color(0xFFDBBABA);
  TextStyle textStyle=TextStyle(color: const Color(0xFFDBBABA), fontFamily: 'Caladea',fontWeight: FontWeight.bold);
  Color fillColor = const Color(0xff403434);
  TextStyle altTextstyle=TextStyle(color: const Color(0xff403434), fontFamily: 'Caladea',fontWeight: FontWeight.bold);


  @override
  void initState() {
    super.initState();
    if (widget.itemToEdit != null) {
      isAssetImage = widget.itemToEdit!.localItemPicture!.startsWith('assets/');
      if (!isAssetImage) {
        _imageFile = XFile(widget.itemToEdit!.localItemPicture!);
      }
      itemName = widget.itemToEdit!.itemName;
      itemRarity = widget.itemToEdit!.itemRarity;
      itemType = widget.itemToEdit!.itemType;
      itemEffect = widget.itemToEdit!.itemEffect;
      itemLevel = widget.itemToEdit!.itemLevel;
      description = widget.itemToEdit!.description;
      itemLocation = widget.itemToEdit!.itemLocation;
      itemPicture = itemPicture = widget.itemToEdit?.itemPicture ?? ''; //for server request
    }
  }

  Future<void> _submitForm() async {
    if (_isAwaiting) return; // Prevents function from running if already updating

    setState(() {
      _isAwaiting = true;
    });

    final isValid = _formKey.currentState!.validate();
    final imageValid = _validateImage() == null;

    if (!isValid || !imageValid) {
      // Show error if image not selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(imageValid ? 'Please fill all fields correctly' : _validateImage()!)),
      );
      setState(() {
        _isAwaiting = false;
      });
      return;
    }
    _formKey.currentState!.save();
    final updatedItem = Item(
      id: widget.itemToEdit!.id,
      localItemPicture: _imageFile?.path ?? widget.itemToEdit!.localItemPicture, // If a new image file has been picked, get its path, otherwise get original image path if no new image has been selected
      itemName: itemName,
      itemRarity: itemRarity,
      itemType: itemType,
      itemEffect: itemEffect,
      itemLevel: itemLevel,
      description: description,
      itemLocation: itemLocation,
      itemPicture: itemPicture
    );

    if (widget.itemToEdit == null) {
      return;
    } else {
      try
      {
        await Provider.of<ItemProvider>(context, listen: false).updateItem(
            updatedItem);
        Navigator.of(context).pop(updatedItem);
      }
      catch (e) {
        LOG.w("$e"); // Logging the error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
        Navigator.of(context).pop(); // Go back to previous screen
        Navigator.of(context).pop(); // Go back to previous screen

      }
      finally{
        setState(() {
          _isAwaiting = false;
        });
      }
    }
  }

// Rest of the widget build method (similar to AddItemScreen)
  @override
  Widget build(BuildContext context) {
    return LoadingWrapper(
      child:Scaffold(
        backgroundColor: const Color(0xFF2A221E),
        appBar: AppBar(
          leading: BackButton(
              color: textColor
          ),
          title: const Text('Update Item',style: TextStyle(color: Color(0xFFDBBABA), fontFamily: 'CinzelDecorative', fontSize: 20 ),),
          backgroundColor: const Color(0xFF2A221E),
        ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              _buildImageDisplay(),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Select Image', style: altTextstyle),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  initialValue: itemName,
                  decoration: InputDecoration(
                    labelText: 'Item Name',
                    labelStyle: textStyle,
                    fillColor: fillColor,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(
                        color: textColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(
                        color: textColor,
                        width: 2.0,
                      ),
                    ),
                  ),
                  style: textStyle,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter item name';
                    }
                    return null;
                  },
                  onSaved: (value) => itemName = value!,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child:
                DropdownButtonFormField(
                  value: itemRarity,
                  decoration: InputDecoration(
                    labelText: 'Item Rarity',
                    labelStyle: textStyle,
                    fillColor: fillColor,
                    // The background color of the field itself
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(
                        color: textColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(
                        color: textColor,
                        width: 2.0,
                      ),
                    ),
                  ),
                  style: textStyle.copyWith(color: textColor),
                  borderRadius: BorderRadius.circular(20),
                  // Apply text color to the dropdown button itself
                  // dropdownColor: const Color(0xFF2A221E),
                  dropdownColor: fillColor,

                  // The background color of the dropdown menu
                  items: ['Legendary', 'Epic', 'Rare', 'Uncommon', 'Common']
                      .map((label) => DropdownMenuItem(
                    child: Text(
                      label,
                      style: textStyle.copyWith(
                          color:
                          textColor), // Apply text color to each dropdown item
                    ),
                    value: label,
                  ))
                      .toList(),
                  onChanged: (value) => itemRarity = value as String,
                  onSaved: (value) => itemRarity = value as String,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  initialValue: itemType, // Set initial value
                  //decoration: InputDecoration(labelText: 'Item Type',labelStyle: textStyle),
                  decoration: InputDecoration(
                    labelText: 'Item Type',
                    labelStyle: textStyle,
                    fillColor: fillColor,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(
                        color: textColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(
                        color: textColor,
                        width: 2.0,
                      ),
                    ),
                  ),
                  style: textStyle,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter item type';
                    }
                    return null;
                  },
                  onSaved: (value) => itemType = value!,
                ),
              ),


              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  initialValue: itemEffect, // Set initial value
                  decoration: InputDecoration(
                    labelText: 'Item Effect',
                    labelStyle: textStyle,
                    fillColor: fillColor,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(
                        color: textColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(
                        color: textColor,
                        width: 2.0,
                      ),
                    ),
                  ),
                  style: textStyle,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter item effect';
                    }
                    return null;
                  },
                  onSaved: (value) => itemEffect = value!,
                ),
              ),


              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child:TextFormField(
                  initialValue: itemLevel.toString(),
                  decoration: InputDecoration(
                    labelText: 'Item Level',
                    labelStyle: textStyle,
                    fillColor: fillColor,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(
                        color: textColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(
                        color: textColor,
                        width: 2.0,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  style: textStyle,
                  validator: (value) {
                    if (value == null || value.isEmpty || int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Please enter a valid item level';
                    }
                    return null;
                  },
                  onSaved: (value) => itemLevel = int.parse(value!),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child:TextFormField(
                  initialValue: description,
                  decoration: InputDecoration(
                    labelText: 'Item Description',
                    labelStyle: textStyle,
                    fillColor: fillColor,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(
                        color: textColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(
                        color: textColor,
                        width: 2.0,
                      ),
                    ),
                  ),
                  style: textStyle,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                  onSaved: (value) => description = value!,
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child:TextFormField(
                  initialValue: itemLocation,
                  decoration: InputDecoration(
                    labelText: 'Item Location',
                    labelStyle: textStyle,
                    fillColor: fillColor,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(
                        color: textColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(
                        color: textColor,
                        width: 2.0,
                      ),
                    ),
                  ),
                  style: textStyle,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter item location';
                    }
                    return null;
                  },
                  onSaved: (value) => itemLocation = value!,
                ),
              ),

              ElevatedButton(
                onPressed: _isAwaiting ? null : _submitForm,
                child: Text(_isAwaiting ? 'Updating item...' : 'Update Item', style: altTextstyle),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildImageDisplay() {
    if (_imageFile != null) {
      return Image.file(File(_imageFile!.path), scale: 0.5);
    } else if (isAssetImage && widget.itemToEdit != null) {
      return Image.asset(widget.itemToEdit!.localItemPicture!, scale: 0.5);
    } else {
      return _imagePlaceholder();
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      setState(() {
        _imageFile = pickedFile;
      });
    } catch (e) {
      LOG.e("Error: $e"); // Logging the error
    }
  }

  Widget _imagePlaceholder() {
    return Column(
      children: <Widget>[
        Icon(Icons.image, size: 100, color: Colors.grey),
        Text('No image selected')
      ],
    );
  }

  // Image validation
  String? _validateImage() {
    // If editing an existing item and the image hasn't been changed, don't require a new image
    if (widget.itemToEdit != null && (isAssetImage || widget.itemToEdit!.localItemPicture!.isNotEmpty)) {
      return null;
    }

    // If a new image has been picked
    if (_imageFile != null) {
      return null;
    }

    // If it's a new item or an existing item with an image change, but no new image has been picked
    return 'Please select an image';
  }
}
