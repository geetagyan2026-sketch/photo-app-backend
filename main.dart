import 'package:flutter/material.dart';

void main() {
  runApp(const TeleportCamApp());
}

class TeleportCamApp extends StatelessWidget {
  const TeleportCamApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const MainDashboard(),
    );
  }
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({Key? key}) : super(key: key);

  @override
  _MainDashboardState createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  String? _currentStatusText = "अपनी फोटो जोड़ने के लिए नीचे कैमरा बटन दबाएं";
  bool _isPhotoSelected = false;

  final List<Map<String, String>> locations = [
    {"name": "Eiffel Tower, Paris", "image": "https://unsplash.com"},
    {"name": "Burj Khalifa, Dubai", "image": "https://unsplash.com"},
    {"name": "Taj Mahal, India", "image": "https://unsplash.com"},
    {"name": "Statue of Liberty, USA", "image": "https://unsplash.com"}
  ];

  int selectedIndex = 0;

  void _openImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('गैलरी से फोटो चुनें (Gallery)', style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() {
                    _isPhotoSelected = true;
                    _currentStatusText = "गैलरी से आपकी फोटो लोड हो चुकी है!";
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.green),
                title: const Text('लाइव कैमरा से खींचें (Camera)', style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() {
                    _isPhotoSelected = true;
                    _currentStatusText = "लाइव कैमरे से आपकी फोटो क्लिक हो चुकी है!";
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TeleportCam AI v1.0", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Image.network(
            locations[selectedIndex]["image"]!,
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.amber, width: 1.5),
              ),
              child: Text(
                _currentStatusText!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Positioned(
            bottom: 130,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 85,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 85,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedIndex == index ? Colors.amber : Colors.transparent,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(locations[index]["image"]!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _openImageSourcePicker,
                  icon: const Icon(Icons.add_a_photo, color: Colors.white),
                  label: const Text("कैमरा / गैलरी खोलें", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (!_isPhotoSelected) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("त्रुटि: पहले कैमरा या गैलरी से फोटो लोड करें!")),
                      );
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("AI ब्लेंडिंग इंजन सक्रिय... फोटो को असली बनाया जा रहा है!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  icon: const Icon(Icons.auto_fix_high, color: Colors.black),
                  label: const Text(
                    "Make Original Photo",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
