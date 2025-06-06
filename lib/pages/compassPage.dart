import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:covergirlstore/models/store.dart';
import 'package:covergirlstore/pages/storeList.dart';
import 'dart:math' as math;

class CompassPage extends StatefulWidget {
  const CompassPage({super.key});

  @override
  State<CompassPage> createState() => _CompassPageState();
}

class _CompassPageState extends State<CompassPage> {
  double? _heading;
  double _lastHeading = 0;
  final double _alpha = 0.15; // smoothing factor

  Position? _currentPosition;
  Store? _nearestStore;

  final List<Store> stores = [
    Store("Mutiara Cosmetics Godean", -7.780166896778175, 110.3462867840733, "Jl. Godean No.8..."),
    Store("Jelita Cosmetics Babarsari", -7.773843636465522, 110.41206687976016, "Ruko Rafflesia B2B..."),
    Store("CFBEAUTY Gejayan", -7.764234236210497, 110.39274930679116, "Jl. Affandi No.9 CT X/09..."),
    Store("Mutiara Cosmetics Babarsari", -7.781865778704549, 110.41386256863095, "Jl. Babarsari No.7B..."),
    Store("Beaute House of Cosmetic", -7.742463106797895, 110.37027824355003, "Gg. Intan No.5..."),
    Store("Jelita Cosmetics Jakal", -7.753689322538392, 110.379204634471, "Jalan Kaliurang KM.5..."),
    Store("Mutiara Kosmetik Jakal Bawah", -7.749607096898486, 110.3826378617483, "Jl. Kaliurang Jl. Turonggosari..."),
    Store("GALAXY BEAUTY STORE", -7.758204930087898, 110.40690742380583, "Jl. Perumnas Gorongan No.215..."),
    Store("Mutiara Cosmetics Pusat", -7.786722698846946, 110.37897368960925, "Jl. Doktor Sutomo No.64 A..."),
    Store("Tone Cosmetic Godean", -7.768833025087074, 110.31582952631958, "68G8+GRR, Jl. Ngapak - Kentheng..."),
    Store("Elsbeauty", -7.755770182106212, 110.38095577177504, "Jl. Kaliurang No.11...")
  ];

  @override
  void initState() {
    super.initState();
    _determinePosition();
    FlutterCompass.events?.listen((event) {
      final newHeading = event.heading;
      if (newHeading != null) {
        setState(() {
          _heading = _lastHeading + _alpha * (newHeading - _lastHeading);
          _lastHeading = _heading!;
        });
      }
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      _nearestStore = _findNearestStore(position);
    });
  }

  Store _findNearestStore(Position position) {
    Store nearest = stores.first;
    double minDistance = _calculateDistance(position.latitude, position.longitude, nearest.lat, nearest.lon);

    for (var store in stores) {
      double distance = _calculateDistance(position.latitude, position.longitude, store.lat, store.lon);
      if (distance < minDistance) {
        nearest = store;
        minDistance = distance;
      }
    }
    return nearest;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) * math.cos(lat2 * p) *
            (1 - math.cos((lon2 - lon1) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a));
  }

  double calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    var lat1Rad = _toRadians(lat1);
    var lat2Rad = _toRadians(lat2);
    var deltaLonRad = _toRadians(lon2 - lon1);

    var y = math.sin(deltaLonRad) * math.cos(lat2Rad);
    var x = math.cos(lat1Rad) * math.sin(lat2Rad) -
        math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(deltaLonRad);
    var bearingRad = math.atan2(y, x);

    return (_toDegrees(bearingRad) + 360) % 360;
  }

  double _toRadians(double degree) => degree * math.pi / 180;
  double _toDegrees(double rad) => rad * 180 / math.pi;

  double normalizeAngle(double angle) {
    while (angle > 180) angle -= 360;
    while (angle < -180) angle += 360;
    return angle;
  }

@override
Widget build(BuildContext context) {
  double? direction;
  double? bearing;

  if (_currentPosition != null && _nearestStore != null) {
    bearing = calculateBearing(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      _nearestStore!.lat,
      _nearestStore!.lon,
    );
  }

  if (_heading != null && bearing != null) {
    direction = normalizeAngle(bearing - _heading!);
  }

  return Scaffold(
    body: Container(  // <-- Tambahkan Container dengan decoration gradient di sini
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFE6E6FA)],
        ),
      ),
      child: Center(
        child: (_currentPosition == null || _heading == null || _nearestStore == null)
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Your Position: ${_currentPosition!.latitude.toStringAsFixed(5)}, ${_currentPosition!.longitude.toStringAsFixed(5)}',
                  ),
                  const SizedBox(height: 16),
                  Text('Direction to ${_nearestStore!.name}: ${bearing!.toStringAsFixed(1)}°'),
                  const SizedBox(height: 16),
                  Transform.rotate(
                    angle: -(direction ?? 0) * (math.pi / 180),
                    child: const Icon(
                      Icons.navigation,
                      size: 100,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Nearest store: ${_nearestStore!.name}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      _nearestStore!.address,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StoreListPage(stores: stores),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(221, 189, 74, 246),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("See All Stores"),
                  ),
                ],
              ),
      ),
    ),
  );
}
}