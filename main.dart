import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: WorldCamApp()));

class WorldCamApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0B1426),
      body: SafeArea(
        child: Column(
          children: [
            // टॉप हेडर और सर्च बार
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("WorldCam AI", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text("Professional Travel Blending Engine", style: TextStyle(color: Colors.blueGrey, fontSize: 12)),
                  SizedBox(height: 15),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Search or type any global landmark...",
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Colors.blue),
                      filled: true,
                      fillColor: Color(0xFF162238),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
            
            // मुख्य लाइव व्यूपोर्ट (फिक्स पोजीशन के साथ)
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                decoration: BorderRadius.circular(20),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // ताजमहल बैकग्राउंड
                    Positioned.fill(
                      child: Image.network(
                        'https://unsplash.com',
                        fit: BoxFit.cover,
                      ),
                    ),
                    
                    // यूजर की फोटो (नीचे कटने से बचाकर सीधे जमीन पर सेट)
                    Positioned(
                      bottom: MediaQuery.of(context).size.height * 0.12, // ऊपर उठाया ताकि नीचे न कटे
                      child: Container(
                        width: 180, // परफेक्ट स्केल साइज
                        height: 250,
                        child: Image.network(
                          'https://studio.preview', // आपकी लाइव स्ट्रीम इमेज
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.account_circle, size: 100, color: Colors.white24);
                          },
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // बॉटम पैरामीटर्स पैनल
            Container(
              padding: EdgeInsets.all(16),
              color: Color(0xFF0B1426),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Blending Engine Parameters", style: TextStyle(color: Colors.white, fontSize: 14)),
                  TextButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.refresh, size: 16, color: Colors.grey),
                    label: Text("Reset", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
