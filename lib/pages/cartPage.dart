import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:covergirlstore/models/cart_item.dart';
import 'package:covergirlstore/pages/checkoutPage.dart';
import 'package:covergirlstore/pages/ListPage.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Box<CartItem> cartBox;
  String currentUser = '';
  String selectedCurrency = 'GBP';

  final Map<String, double> conversionRates = {
    'GBP': 1.0,
    'USD': 1.3,
    'IDR': 20000.0,
  };

  final double shakeThreshold = 15.0;
  DateTime lastShakeTime = DateTime.now();
  late final StreamSubscription<AccelerometerEvent> _sensorSubscription;

  @override
  void initState() {
    super.initState();
    cartBox = Hive.box<CartItem>('cart_box');
    _loadCurrentUser();
    _startShakeListener();
  }

  void _startShakeListener() {
    _sensorSubscription = accelerometerEvents.listen((event) {
      final double acceleration =
          sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

      if (acceleration > shakeThreshold &&
          DateTime.now().difference(lastShakeTime) > const Duration(seconds: 2)) {
        lastShakeTime = DateTime.now();
        _confirmClearCart();
      }
    });
  }

  @override
  void dispose() {
    _sensorSubscription.cancel();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        currentUser = prefs.getString('username') ?? '';
      });
    }
  }

  void _removeItem(String key) {
    cartBox.delete(key);
    if (mounted) setState(() {});
  }

  void _confirmClearCart() {
    final cartKeys = cartBox.keys
        .where((key) => key.toString().startsWith(currentUser))
        .toList();

    if (cartKeys.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear Cart"),
        content: const Text("Do you want to clear all items from your cart?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              for (var key in cartKeys) {
                cartBox.delete(key);
              }
              if (mounted) setState(() {});
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Cart cleared via shake!")),
              );
            },
            child: const Text("Clear All"),
          ),
        ],
      ),
    );
  }

  String getConvertedPrice(String priceStr) {
    double basePrice = double.tryParse(priceStr) ?? 0.0;
    double converted = basePrice * conversionRates[selectedCurrency]!;
    String symbol = selectedCurrency == 'IDR'
        ? 'Rp'
        : selectedCurrency == 'USD'
            ? '\$'
            : '£';
    return '$symbol${converted.toStringAsFixed(selectedCurrency == 'IDR' ? 0 : 2)}';
  }

  Color? _parseColorFromHex(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return null;
    try {
      final hex = hexColor.startsWith('#') ? hexColor.substring(1) : hexColor;
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final cartKeys = cartBox.keys
        .where((key) => key.toString().startsWith(currentUser))
        .toList();

    final userCartItems = cartKeys
        .map((key) => MapEntry(key.toString(), cartBox.get(key)!))
        .toList();

    if (userCartItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: const Color.fromARGB(221, 189, 74, 246),
            ),
            const SizedBox(height: 20),
            const Text(
              'Oops, your cart is empty',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Ready to fill it with some favorites?',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ListPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(221, 189, 74, 246),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(
                Icons.shopping_bag,
                color: Colors.white.withOpacity(0.7),
              ),

              label: const Text(
                'Start Shopping',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }


    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Choose Currency:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color.fromARGB(255, 207, 64, 255),
                ),
              ),
              DropdownButton<String>(
                value: selectedCurrency,
                items: const [
                  DropdownMenuItem(value: 'GBP', child: Text('GBP')),
                  DropdownMenuItem(value: 'USD', child: Text('USD')),
                  DropdownMenuItem(value: 'IDR', child: Text('IDR')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedCurrency = value;
                    });
                  }
                },
                dropdownColor: Colors.pink.shade50,
                style: const TextStyle(
                  color: Color.fromARGB(255, 93, 29, 114),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: userCartItems.length,
            itemBuilder: (context, index) {
              final key = userCartItems[index].key;
              final item = userCartItems[index].value;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                  title: Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color.fromARGB(255, 207, 64, 255),
                    ),
                  ),
                  subtitle: Text(
                    '${getConvertedPrice(item.price)} x ${item.quantity}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _removeItem(key),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CheckoutPage(
                      selectedCurrency: selectedCurrency,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 207, 64, 255),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Checkout',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
