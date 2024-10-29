import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:product_entry/views/screens/products.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductEntry extends StatefulWidget {
  const ProductEntry({super.key});

  @override
  State<ProductEntry> createState() => _ProductEntryState();
}

class _ProductEntryState extends State<ProductEntry> {
  final _formKey = GlobalKey<FormState>();
  final _pNameController = TextEditingController();
  final _pIdController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _qtyController = TextEditingController();
  final _storeController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String _category='Grocery';
  String _measurementType='kg';
  String _pType='Regular';
  DateTime? _validFrom;
  DateTime? _validTo;
  bool _notifyUsers = false;
  bool _whatsappAlert = false;
  String? _uidError;

  @override
  void initState() {
    _pIdController.addListener(()=>_onChangeId(_pIdController.text));
    super.initState();
  }

  @override
  void dispose() {
    _pNameController.dispose();
    _pIdController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _qtyController.dispose();
    _storeController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _saveProductID(SharedPreferences pref,String id) async {
    List<String> savedIDs=pref.getStringList('pID') ?? [];
    savedIDs.add(id);
    await pref.setStringList('pID', savedIDs);
  }

  Future<void> _selectDate(BuildContext context, bool isValidFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isValidFrom) {
          _validFrom = picked;
        } else {
          _validTo = picked;
        }
      });
    }
  }


  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('products');
    List<Map<String, dynamic>> entries = [];
    _saveProductID(prefs, _pIdController.text);
    Map<String, dynamic> product = {
      'Product Name': _pNameController.text,
      'Product ID' : _pIdController.text,
      'Category': _category,
      'Brand': _brandController.text,
      'Price': _priceController.text,
      'Discount Price': _discountController.text,
      'Quantity': _qtyController.text,
      'Measurement Type': _measurementType,
      'Store': _storeController.text,
      'Valid From': _validFrom?.toIso8601String() ?? '',
      'Valid To': _validTo?.toIso8601String() ?? '',
      'Product Type': _pType,
      'Image URL': _imageUrlController.text,
      'Notify Users': _notifyUsers,
      'WhatsApp Alert': _whatsappAlert,
    };
    if (jsonString != null) {
      List<dynamic> jsonList = jsonDecode(jsonString);
      entries = List<Map<String, dynamic>>.from(jsonList);
    }
    entries.add(product);
    jsonString = jsonEncode(entries);
    await prefs.setString('products', jsonString);
  }

  Future<bool> _validateUniqueId(String pID) async {
   final prefs=await SharedPreferences.getInstance();
   List<String>? savedProductIds = prefs.getStringList('pID') ?? [];
   return !savedProductIds.contains(pID);
  }

  void _onChangeId(String value) async {
    if (value.isNotEmpty && value.length <= 10) {
      final isUnique = await _validateUniqueId(value);
      setState(() {
        _uidError = isUnique ? null : 'Product ID must be unique';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Form')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _pNameController,
                  decoration: InputDecoration(labelText: 'Product Name', helper: helperText('Enter Product Name')),
                  validator: (value) => value!.isEmpty ? 'Please enter a product name' : null,
                ),
                TextFormField(
                  controller: _pIdController,
                  decoration: InputDecoration(labelText: 'Product ID', errorText: _uidError,  helper: helperText("Enter an Alphanumeric ID")),
                  maxLength: 10,
                  validator: (value){
                    final pattern = RegExp(['0','1','2','3','4','5','6','7','8','9'].join('|'));
                    if (value!.isEmpty) return 'Please enter a product ID';
                    if(!pattern.hasMatch(value)) return 'Please enter an Alphanumeric ID';
                    if (value.length > 10) return 'ID must be 10 characters or less';
                    return null;
                  },
                ),
                DropdownButtonFormField(
                  value: _category,
                  items: ['Grocery', 'Electronics'].map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (value) => setState(() => _category = value ?? 'Grocery'),
                  decoration: InputDecoration(labelText: 'Category', helper: helperText("Choose Category")),
                  validator: (value) => value == null ? 'Please select a category' : null,
                ),
                TextFormField(
                  controller: _brandController,
                  decoration: InputDecoration(labelText: 'Brand (Optional)',helper: helperText("Enter brand of the product")),
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: 'Price',helper: helperText("Enter a valid price")),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return 'Please enter a price';
                    if (double.tryParse(value) == null || double.parse(value) <= 0) return 'Price must be a positive number';
                    return null;
                  },
                ),
                TextFormField(
                  controller: _discountController,
                  decoration: InputDecoration(labelText: 'Discount Price (Optional)', helper: helperText("Must be less than or equal to price")),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isNotEmpty && double.tryParse(value) != null) {
                      final price = double.parse(_priceController.text);
                      final discountPrice = double.parse(value);
                      if (discountPrice > price) return 'Discount Price must be less than or equal to Price';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _qtyController,
                  decoration: InputDecoration(labelText: 'Quantity',helper: helperText("Enter a positive quantity")),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return 'Please enter quantity';
                    if (int.tryParse(value) == null || int.parse(value) <= 0) return 'Quantity must be a positive integer';
                    return null;
                  },
                ),
                DropdownButtonFormField(
                  value: _measurementType,
                  items: ['kg', 'liters'].map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) => setState(() => _measurementType = value ?? 'kg'),
                  decoration: InputDecoration(labelText: 'Measurement Type', helper: helperText("Choose unit of product")),
                  validator: (value) => value == null ? 'Please select a measurement type' : null,
                ),
                TextFormField(
                  controller: _storeController,
                  decoration: InputDecoration(labelText: 'Store', helper: helperText("Enter store")),
                  validator: (value) => value!.isEmpty ? 'Please enter store' : null,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Valid From',
                          helper: helperText("Enter any date"),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _selectDate(context, true),
                          ),
                        ),
                        controller: TextEditingController(
                          text: _validFrom != null ? DateFormat('yyyy-MM-dd').format(_validFrom!) : '',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Valid To',
                          helper: helperText("Must be after date of valid from"),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _selectDate(context, false),
                          ),
                        ),
                        controller: TextEditingController(
                          text: _validTo != null ? DateFormat('yyyy-MM-dd').format(_validTo!) : '',
                        ),
                        validator: (value) {
                          if (_validFrom != null && _validTo != null && _validTo!.isBefore(_validFrom!)) {
                            return 'Valid To date must be after Valid From date';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                DropdownButtonFormField(
                  value: _pType,
                  items: ['Regular', 'Combo'].map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) => setState(() => _pType = value ?? 'Regular'),
                  decoration: InputDecoration(labelText: 'Product Type', helper: helperText("Choose a type")),
                  validator: (value) => value == null ? 'Please select a product type' : null,
                ),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(labelText: 'Image URL', helper: helperText("Enter an URL")),
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value!.isEmpty) return 'Please enter an image URL';
                    const urlPattern = r'^(http|https):\/\/([a-z0-9-]+\.)+[a-z0-9]{2,6}(:[0-9]{1,5})?(\/.*)?$';
                    final urlRegex = RegExp(urlPattern);
                    if (!urlRegex.hasMatch(value)) return 'Please enter a valid URL';
                    return null;
                  },
                ),
                CheckboxListTile(
                  title: const Text("Notify Users"),
                  value: _notifyUsers,
                  onChanged: (bool? value) => setState(() => _notifyUsers = value ?? false),
                ),
                CheckboxListTile(
                  title: const Text("WhatsApp Alert"),
                  value: _whatsappAlert,
                  onChanged: (bool? value) => setState(() => _whatsappAlert = value ?? false),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade300, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _saveData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Product details submitted successfully!')),
                      );
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const Products()));
                    }else{
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter all the fields correctly!')));
                    }
                  },
                  child: const Text('SUBMIT', style: TextStyle(fontSize: 15),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget helperText(String text){
  return Text(text, style: TextStyle(color: Colors.blue.withOpacity(0.8), fontWeight: FontWeight.w500));
}

