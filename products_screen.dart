import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'database_helper.dart';
import 'cart_screen.dart';
import 'login_screen.dart'; // إضافة الاستيراد هنا

/// شاشة عرض المنتجات للمستخدم العادي، يتم تمرير اسم المستخدم ليظهر في AppBar
class ProductListScreen extends StatefulWidget {
  final String userName;
  ProductListScreen({required this.userName});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List products = [];
  Map<int, int> productQuantities = {}; // لتخزين الكميات لكل منتج
  bool isLoading = true;
  final String apiUrl = 'https://fakestoreapi.com/products';

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  /// تحميل المنتجات من API
  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          setState(() {
            products = data;
            isLoading = false;
          });
        } else {
          setState(() {
            products = [];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          products = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching products: $e");
      setState(() {
        products = [];
        isLoading = false;
      });
    }
  }

  /// إضافة المنتج إلى السلة
  void addToCart(int productId) async {
    var product = products.firstWhere((p) => p['id'] == productId);
    int quantity = productQuantities[productId] ?? 1;

    await DatabaseHelper.addToCart({
      'id': product['id'],
      'name': product['title'],
      'price': product['price'],
      'image': product['image'],
      'quantity': quantity,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${product['title']} added to cart!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  