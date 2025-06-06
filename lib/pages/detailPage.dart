import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:covergirlstore/models/cart_item.dart';
import 'package:covergirlstore/models/contentModel.dart';
import 'package:uuid/uuid.dart';

class DetailPage extends StatefulWidget {
  final String id;
  final String name;
  final String pictureId;
  final String description;
  final String price;
  final String priceSign;
  final String userId;

  final String category;
  final String productType;
  final List<String> tagList;
  final List<ColorOption> productColors;
  final double? rating;

  const DetailPage({
    super.key,
    required this.id,
    required this.name,
    required this.pictureId,
    required this.description,
    required this.price,
    required this.priceSign,
    required this.userId,
    required this.category,
    required this.productType,
    required this.tagList,
    required this.productColors,
    this.rating,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Box<CartItem> cartBox;

  ColorOption? _selectedColor;

  @override
  void initState() {
    super.initState();
    cartBox = Hive.box<CartItem>('cart_box');
  }

void addToCart() {
  if (widget.productColors.isNotEmpty && _selectedColor == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Please select a color before adding to cart'),
        backgroundColor: Colors.redAccent,
      ),
    );
    return;
  }

  final uuid = Uuid();
  final String key = '${widget.userId}_${widget.id}_${uuid.v4()}';

  final List<String>? selectedColorsHex = _selectedColor != null
      ? [_selectedColor!.hexValue]
      : null;

  final newItem = CartItem(
    id: widget.id,
    name: widget.name,
    imageUrl: widget.pictureId,
    price: widget.price,
    priceSign: widget.priceSign,
    quantity: 1,
    productColors: selectedColorsHex,
  );

  cartBox.put(key, newItem);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Product "${widget.name}" added to cart!'),
      backgroundColor: const Color.fromARGB(255, 207, 64, 255),
    ),
  );
}


  Color _parseHexColor(String hex) {
    try {
      hex = hex.replaceFirst('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color.fromARGB(255, 207, 64, 255);

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text("Details", style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 4,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFE6E6FA)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  clipBehavior: Clip.antiAlias,
                  shadowColor: primaryColor.withOpacity(0.3),
                  child: Image.network(
                    widget.pictureId,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 320,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        height: 320,
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 80,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        height: 320,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: primaryColor,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                widget.name,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    size: 14,
                    color: Color.fromARGB(255, 252, 237, 71),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.rating != null
                        ? widget.rating!.toStringAsFixed(1)
                        : '-',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.category.isNotEmpty ? widget.category : '-',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 233, 187, 248),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.productType.isNotEmpty ? widget.productType : '-',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 136, 41, 167),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "£${widget.price}",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: primaryColor.withOpacity(0.5),
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),

              // --- Product Colors Section ---
              if (widget.productColors.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Available Colors',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.grey.shade900,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: widget.productColors.map((colorOption) {
                    final bool isSelected = _selectedColor == colorOption;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = colorOption;
                        });
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: _parseHexColor(colorOption.hexValue),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? primaryColor : Colors.grey.shade400,
                                width: isSelected ? 3 : 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            colorOption.colorName.isNotEmpty
                                ? colorOption.colorName
                                : 'Unknown',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? primaryColor : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 26),
              Text(
                'Description',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 21,
                  color: Colors.grey.shade900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.description,
                style: TextStyle(
                  fontSize: 17,
                  height: 1.6,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: widget.productColors.isNotEmpty && _selectedColor == null
                      ? null
                      : addToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    disabledBackgroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 8,
                    shadowColor: primaryColor.withOpacity(0.7),
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  child: const Text(
                    'Add to Cart',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
