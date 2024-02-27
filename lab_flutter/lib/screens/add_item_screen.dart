import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../model/item.dart';
import '../providers/item_provider.dart';
import '../utils/custom_log_printer.dart';
import '../utils/loading_screen.dart';

class AddItemScreen extends StatefulWidget {
  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();

  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  String itemName = '';
  String itemRarity = '';
  String itemType = '';
  String itemEffect = '';
  int itemLevel = 0;
  String description = '';
  String itemLocation = '';

  bool _isAwaiting = false;

  final LOG = Logger(printer: CustomLogPrinter());

  Color textColor = const Color(0xFFDBBABA);
  TextStyle textStyle = TextStyle(
      color: const Color(0xFFDBBABA),
      fontFamily: 'Caladea',
      fontWeight: FontWeight.bold);
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
          leading: BackButton(color: textColor),
          title: const Text(
            'Add New Item',
            style: TextStyle(
                color: Color(0xFFDBBABA),
                fontFamily: 'CinzelDecorative',
                fontSize: 20),
          ),
          backgroundColor: const Color(0xFF2A221E),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                _imageFile != null
                    ? Image.file(File(_imageFile!.path), scale: 0.5)
                    : _imagePlaceholder(),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Select Image', style: altTextstyle),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
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
                  child: DropdownButtonFormField(
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
                              value: label,
                              child: Text(
                                label,
                                style: textStyle.copyWith(
                                    color:
                                        textColor), // Apply text color to each dropdown item
                              ),
                            ))
                        .toList(),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select an item rarity'; // Return a string with the error message if validation fails
                      }
                      return null; // Return null if the value passes the validation
                    },
                    onChanged: (value) => itemRarity = value as String,
                    onSaved: (value) => itemRarity = value as String,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
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
                  child: TextFormField(
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
                      if (value == null ||
                          value.isEmpty ||
                          int.tryParse(value) == null ||
                          int.parse(value) <= 0) {
                        return 'Please enter a valid item level';
                      }
                      return null;
                    },
                    onSaved: (value) => itemLevel = int.parse(value!),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
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
                  child: TextFormField(
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
                  child: Text(_isAwaiting ? 'Adding item...' : 'Add Item',
                      style: altTextstyle),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
    if (_imageFile == null) {
      return 'Please select an image';
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (_isAwaiting)
      return; // Prevents function from running if already updating

    setState(() {
      _isAwaiting = true;
    });

    final isValid = _formKey.currentState!.validate();
    final imageValid = _validateImage() == null;

    if (!isValid || !imageValid) {
      // Show error if image not selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(imageValid
                ? 'Please fill all fields correctly'
                : _validateImage()!)),
      );
      setState(() {
        _isAwaiting = false;
      });
      return;
    }
    _formKey.currentState!.save();
    final newItem = Item(
        localItemPicture: _imageFile!.path,
        // Use the image file path
        itemName: itemName,
        itemRarity: itemRarity,
        itemType: itemType,
        itemEffect: itemEffect,
        itemLevel: itemLevel,
        description: description,
        itemLocation: itemLocation);

    // Provider.of<ItemProvider>(context, listen: false).addItem(newItem);
    // Navigator.of(context).pop(); // Go back to previous screen

    try {
      await Provider.of<ItemProvider>(context, listen: false).addItem(newItem);
      Navigator.of(context).pop(); // Go back to previous screen
    } catch (e) {
      LOG.e("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add item')),
      );
    } finally {
      setState(() {
        _isAwaiting = false;
      });
    }
  }
}
