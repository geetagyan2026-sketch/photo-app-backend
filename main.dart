import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(debugShowCheckedModeBanner: false, home: WorldCamApp()));

class WorldCamApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0B1426),
      body: SafeArea(
        child: Column(
          children: [
            // सर्च और हेडर सेक्शन
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("WorldCam AI", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text("Professional Travel Blending Engine", style: TextStyle(color: Colors.blueGrey, fontSize: 12)),
                  SizedBox(height: 12),
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
            
            // लाइव व्यूपोर्ट (Constraint Fix के साथ)
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                decoration: BorderRadius.circular(20),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // ताजमहल बैकग्राउंड इमेज
                    Positioned.fill(
                      child: Image.network(
                        'https://unsplash.com',
                        fit: BoxFit.cover,
                      ),
                    ),
                    
                    // यूजर इमेज: बॉटम से ऊपर उठाया ताकि रास्ते पर बिल्कुल सही फिट हो
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.bottom(MediaQuery.of(context).size.height * 0.18), 
                        child: Container(
                          width: 200, 
                          height: 260,
                          child: Image.network(
                            'https://studio.preview',
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, progress) => progress == null ? child : CircularProgressIndicator(),
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.account_circle, size: 120, color: Colors.white30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // बॉटम बार
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Blending Engine Parameters", style: TextStyle(color: Colors.white, fontSize: 14)),
                  Text("Reset", style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
