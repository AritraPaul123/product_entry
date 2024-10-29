import 'package:flutter/material.dart';

class ProductDetails extends StatelessWidget {
  const ProductDetails({super.key, required this.product});
  final Map<String, dynamic> product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product['Product Name']),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: product.entries.map((entry) {
                  final value = entry.value is bool
                      ? (entry.value ? 'Yes' : 'No')
                      : entry.value.toString();
                  return ListTile(
                    title: Text('${entry.key}-', style: const TextStyle(fontSize: 18),),
                    subtitle: Text(value, style: const TextStyle(fontSize: 17),),
                  );
                }).toList(),
        ),
      ),
    );
  }
}
