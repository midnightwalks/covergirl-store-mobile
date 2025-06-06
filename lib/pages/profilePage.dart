import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final List<Map<String, String>> members = [
    {
      'instagram': 'jeslyn.vh',
      'name': 'Jeslyn Vicky Hanjaya',
      'nim': '123220150',
      'image': 'assets/media/jeslyn.jpg',
    }
  ];

   ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFE6E6FA)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            children: [
              Center(
                child: Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 28, // agak lebih besar biar lebih impactful
                    fontWeight:
                        FontWeight.w900, // lebih bold, tapi tetap elegan
                    color: const Color.fromARGB(255, 203, 59, 250),
                    letterSpacing:
                        1.5, // spasi huruf biar kelihatan lebih rapi dan mewah
                    shadows: [
                      Shadow(
                        blurRadius: 12.0, // blur lebih halus dan lebar
                        color: Colors.black.withOpacity(0.25),
                        offset: const Offset(3.0, 3.0),
                      ),
                      Shadow(
                        blurRadius: 8.0,
                        color: Color.fromARGB(255, 214, 90, 255).withOpacity(
                          0.4,
                        ), // kasih glow pink lembut
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Looping profile cards
              ...members.map((member) => _memberCard(member)),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

Widget _memberCard(Map<String, String> member) {
  return Container(
    width: double.infinity,
    margin: EdgeInsets.only(bottom: 30),
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.95),
          Colors.purple.shade50.withOpacity(0.6),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 12,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Image.asset(
            member['image']!,
            width: 140,
            height: 140,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.person, size: 140, color: Color.fromARGB(255, 207, 64, 255));
            },
          ),
        ),
        SizedBox(height: 16),
        Text(
          member['name']!,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 207, 64, 255),
          ),
        ),
        SizedBox(height: 8),
        Text(
          member['nim']!,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF833AB4), Color(0xFFF56040), Color(0xFFFF0080)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(0.3),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.camera_alt, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                '@${member['instagram']}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

}
