import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:covergirlstore/models/cart_item.dart';
import 'package:covergirlstore/models/notification_item.dart';
import 'package:covergirlstore/pages/listPage.dart';
import 'package:covergirlstore/models/notification_helper.dart';


import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';


class CheckoutPage extends StatefulWidget {
  final String selectedCurrency;

  const CheckoutPage({super.key, required this.selectedCurrency});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late Box<CartItem> cartBox;
  String currentUser = '';
  String selectedPaymentMethod = '';

  bool isLocationConfirmed = false;

  final Map<String, double> conversionRates = {
    'GBP': 1.0,
    'USD': 1.3,
    'IDR': 20000.0,
  };

Widget buildTimeConversionWidget() {
  if (!isLocationConfirmed || selectedPaymentMethod.isEmpty) {
    return const SizedBox.shrink(); // Tidak ditampilkan jika belum siap
  }

  final estimatedArrival = DateTime.now().toUtc().add(const Duration(days: 2));
  final times = {
    'WIB (UTC+7)': estimatedArrival.add(const Duration(hours: 7)),
    'WITA (UTC+8)': estimatedArrival.add(const Duration(hours: 8)),
    'WIT (UTC+9)': estimatedArrival.add(const Duration(hours: 9)),
    'London (UTC+1 DST)': estimatedArrival.add(const Duration(hours: 1)),
  };

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 32),
      const Text(
        'Estimated Delivery Time in Various Timezones:',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 207, 64, 255),
        ),
      ),
      const SizedBox(height: 10),
      ...times.entries.map((entry) {
        return Text(
          '${entry.key}: ${DateFormat('EEEE, dd MMM yyyy – HH:mm').format(entry.value)}',
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        );
      }),
    ],
  );
}



  final List<String> paymentMethods = ['Mandiri', 'BCA', 'Gopay', 'OVO'];

  final LatLng defaultLocation = LatLng(-7.7819, 110.4150);
  late LatLng pinnedLocation;
  bool isLocationReady = false;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    cartBox = Hive.box<CartItem>('cart_box');
    pinnedLocation = defaultLocation;
    _loadCurrentUser();
    _determinePosition();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUser = prefs.getString('username') ?? '';
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enable location services')),
        );
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
        }
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      if (mounted) {
        setState(() {
          pinnedLocation = LatLng(position.latitude, position.longitude);
          isLocationReady = true;
          _mapController.move(pinnedLocation, 16);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
      }
    }
  }

  String getConvertedPrice(String priceStr) {
    double basePrice = double.tryParse(priceStr) ?? 0.0;
    double converted = basePrice * conversionRates[widget.selectedCurrency]!;
    String symbol =
        widget.selectedCurrency == 'IDR'
            ? 'Rp'
            : widget.selectedCurrency == 'USD'
            ? '\$'
            : '£';
    return '$symbol${converted.toStringAsFixed(widget.selectedCurrency == 'IDR' ? 0 : 2)}';
  }

  String getConvertedSubtotal(double subtotalEUR) {
    double converted = subtotalEUR * conversionRates[widget.selectedCurrency]!;
    String symbol =
        widget.selectedCurrency == 'IDR'
            ? 'Rp'
            : widget.selectedCurrency == 'USD'
            ? '\$'
            : '£';
    return '$symbol${converted.toStringAsFixed(widget.selectedCurrency == 'IDR' ? 0 : 2)}';
  }

  double calculateTotal(List<CartItem> items) {
    double totalEUR = 0.0;
    for (var item in items) {
      double basePrice = double.tryParse(item.price) ?? 0.0;
      totalEUR += basePrice * item.quantity;
    }
    return totalEUR * conversionRates[widget.selectedCurrency]!;
  }

  Future<String> performCheckout(List<String> keys, double total) async {
  final notifBox = Hive.box<NotificationItem>('notifications');
  final symbol =
      widget.selectedCurrency == 'IDR'
          ? 'Rp'
          : widget.selectedCurrency == 'USD'
              ? '\$'
              : '£';
  final message =
      "You have successfully checked out with a total of $symbol${total.toStringAsFixed(widget.selectedCurrency == 'IDR' ? 0 : 2)}"
      "\nShipping Location: ${pinnedLocation.latitude.toStringAsFixed(5)}, ${pinnedLocation.longitude.toStringAsFixed(5)}";

  notifBox.add(
    NotificationItem(
      message: message,
      timestamp: DateTime.now(),
      paymentMethod: selectedPaymentMethod,
    ),
  );

  for (var key in keys) {
    cartBox.delete(key);
  }

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment Successful! Check notification for payment recap.'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const ListPage()),
      (route) => false,
    );
  }

  return message;
}


  @override
  Widget build(BuildContext context) {
    if (currentUser.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final cartKeys =
        cartBox.keys
            .where((key) => key.toString().startsWith(currentUser))
            .toList();
    final userCartItems =
        cartKeys
            .map((key) => MapEntry(key.toString(), cartBox.get(key)!))
            .toList();

    if (userCartItems.isEmpty) {
      return const Scaffold(body: Center(child: Text('No item in cart.')));
    }

    final items = userCartItems.map((e) => e.value).toList();
    final totalConverted = calculateTotal(items);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: const Color.fromARGB(255, 207, 64, 255),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Color(0xFFE6E6FA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Receipt',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 207, 64, 255),
                  ),
                ),
                const SizedBox(height: 16),

                // Ganti ListView.builder dengan Column + map
                ...userCartItems.map((entry) {
                  final item = entry.value;
                  final subtotalEUR = double.parse(item.price) * item.quantity;

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shadowColor: Color.fromARGB(255, 207, 64, 255).withOpacity(0.3),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      title: Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          color: Color.fromARGB(255, 207, 64, 255),
                        ),
                      ),
                      subtitle: Text(
                        '${getConvertedPrice(item.price)} x ${item.quantity} = ${getConvertedSubtotal(subtotalEUR)}',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 207, 64, 255),
                      ),
                    ),
                    Text(
                      widget.selectedCurrency == 'IDR'
                          ? 'Rp${totalConverted.toStringAsFixed(0)}'
                          : widget.selectedCurrency == 'USD'
                          ? '\$${totalConverted.toStringAsFixed(2)}'
                          : '£${totalConverted.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 207, 64, 255),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),
                // Payment Method (tetap sama)
                Row(
                  children: [
                    const Text(
                      'Payment Method:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.pink.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color.fromARGB(255, 220, 143, 244)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value:
                                  selectedPaymentMethod.isEmpty
                                      ? null
                                      : selectedPaymentMethod,
                              hint: const Text('Choose'),
                              items:
                                  paymentMethods.map((method) {
                                    return DropdownMenuItem<String>(
                                      value: method,
                                      child: Text(method),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedPaymentMethod = value ?? '';
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Peta (FlutterMap) tetap seperti semula
                SizedBox(
                  height: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        center: pinnedLocation,
                        zoom: 16,
                        onTap: (tapPos, latLng) {
                          setState(() {
                            pinnedLocation = latLng;
                            isLocationConfirmed = false;
                          });
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c'],
                          userAgentPackageName: 'com.example.covergirlstore',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 40,
                              height: 40,
                              point: pinnedLocation,
                              builder:
                                  (ctx) => const Icon(
                                    Icons.location_pin,
                                    color: Colors.redAccent,
                                    size: 40,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                Text(
                  'Shipping Location: ${pinnedLocation.latitude.toStringAsFixed(5)}, ${pinnedLocation.longitude.toStringAsFixed(5)}',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 24),
                Row(
                  children: [
                    Checkbox(
                      value: isLocationConfirmed,
                      onChanged: (value) {
                        setState(() {
                          isLocationConfirmed = value ?? false;
                        });
                      },
                      activeColor: Color.fromARGB(255, 207, 64, 255),
                    ),
                    const Expanded(
                      child: Text(
                        'I have made sure the delivery location is correct',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),

                buildTimeConversionWidget(),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>(
                        (states) {
                          if (states.contains(WidgetState.disabled)) {
                            return const Color.fromARGB(255, 212, 143, 244);
                          }
                          return const Color.fromARGB(255, 223, 64, 255);
                        },
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      elevation: WidgetStateProperty.resolveWith<double>(
                        (states) =>
                            states.contains(WidgetState.disabled) ? 0 : 6,
                      ),
                      shadowColor: WidgetStateProperty.all(
                        const Color.fromARGB(255, 214, 64, 255),
                      ),
                    ),
                    onPressed: (selectedPaymentMethod.isEmpty || !isLocationConfirmed)
    ? null
    : () async {
        final checkoutMessage = await performCheckout(
          cartKeys.map((e) => e.toString()).toList(),
          totalConverted,
        );
        await showNotification(
          title: 'Checkout Succesful',
          body: checkoutMessage,
        );
      },
                    child: const Text(
                      'Checkout',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
