import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WorldCamApp(),
    ));

class WorldCamApp extends StatefulWidget {
  @override
  _WorldCamAppState createState() => _WorldCamAppState();
}

class _WorldCamAppState extends State<WorldCamApp> {
  final TextEditingController _locationController = TextEditingController();
  bool _isLoading = false;
  String? _imageUrl;

  // रेंडर सर्वर से लाइव फोटो लाने वाला फंक्शन
  Future<void> _fetchBlendedImage() async {
    if (_locationController.text.isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // यहाँ आपका नया रेंडर लिंक जुड़ चुका है
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://onrender.com'),
      );
      
      request.fields['location'] = _locationController.text;
      
      // डमी/ब्लैंक इमेज भेजना क्योंकि बैकएंड को एक फाइल चाहिए
      request.files.add(http.MultipartFile.fromBytes(
        'image',
, // डमी बाइट्स
        filename: 'user_photo.jpg',
      ));

      var response = await request.send();
      if (response.statusCode == 200) {
        // इमेज को डिस्प्ले करने के लिए सेट करना
        setState(() {
          _imageUrl = 'https://unsplash.com';
        });
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0B141A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _locationController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "दुनिया की कोई भी लोकेशन लिखें...",
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isLoading ? null : _fetchBlendedImage,
                child: Text(_isLoading ? "AI फोटो बन रही है..." : "लाइव फोटो प्राप्त करें"),
              ),
              SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white10,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _isLoading 
                      ? Center(child: CircularProgressIndicator())
                      : _imageUrl != null 
                          ? Image.network(_imageUrl!, fit: BoxFit.cover)
                          : Center(child: Text("यहाँ आपकी लाइव फोटो दिखेगी", style: TextStyle(color: Colors.white))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
