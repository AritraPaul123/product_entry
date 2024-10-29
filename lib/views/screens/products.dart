import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:product_entry/views/screens/product_details.dart';
import 'package:product_entry/views/screens/product_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Products extends StatefulWidget {
  const Products({super.key});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  List<Map<String, dynamic>> products=[];

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString('products');
      if (jsonString != null) {
        List<dynamic> jsonList = jsonDecode(jsonString);
        setState(() {
          products=List<Map<String, dynamic>>.from(jsonList);
        });
      }
  }
  @override
  void initState() {
    super.initState();
    _loadData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Products'),
      actions: [
        IconButton(onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>const ProductEntry()));
        }, icon: const Icon(Icons.add, size: 40,))
      ],),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: products.isEmpty
            ? const Center(child: Text('No product data available'))
            : ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index){
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.grey.withOpacity(0.5)),
                child: ListTile(
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ProductDetails(product: products[index])));
                  },
                  title: Text('Product Name-${products[index]['Product Name']}', style: const TextStyle(fontSize: 20),),
                  subtitle: Text('Product ID-${products[index]['Product ID']}', style: const TextStyle(fontSize: 16),),
                ),
              );
        })
      ),
    );
  }
}
