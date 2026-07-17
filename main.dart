import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const TeleportCamApp());

class TeleportCamApp extends StatelessWidget {
  const TeleportCamApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const CameraStudioScreen(),
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF121212)),
    );
  }
}

class CameraStudioScreen extends StatefulWidget {
  const CameraStudioScreen({Key? key}) : super(key: key);
  @override
  State<CameraStudioScreen> createState() => _CameraStudioScreenState();
}

class _CameraStudioScreenState extends State<CameraStudioScreen> {
  File? _userImage;
  dynamic _finalResultBytes; // एआई सर्वर से आने वाली असली इमेज का डेटा
  bool _isLoading = false;
  
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // आपका Python (main.py) सर्वर जहाँ होस्टेड है उसका एड्रेस (Local या Cloud URL)
  final String _serverUrl = "http://10.0.0"; // अपने सर्वर IP से बदलें

  // कैमरा या गैलरी से यूजर की ओरिजिनल फोटो सेलेक्ट करना
  Future<void> _pickUserPhoto(ImageSource source) async {
    final XFile? file = await _picker.pickImage(source: source, imageQuality: 80);
    if (file != null) {
      setState(() {
        _userImage = File(file.path);
        _finalResultBytes = null; // पुराना प्रिव्यू साफ़ करें
      });
    }
  }

  // एआई सर्वर (main.py) को डेटा भेजना जो असली फोटो सर्च करेगा और बैकग्राउंड मिक्स करेगा
  Future<void> _processAiTeleport() async {
    String location = _searchController.text.trim();
    if (location.isEmpty) {
      _showSnackbar("कृपया सर्च बॉक्स में लोकेशन का नाम लिखें!");
      return;
    }
    if (_userImage == null) {
      _showSnackbar("कृपया कैमरा या गैलरी से अपनी फोटो जोड़ें!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      var request = http.MultipartRequest('POST', Uri.parse(_serverUrl));
      request.fields['location'] = location;
      request.files.add(await http.MultipartFile.fromPath('user_photo', _userImage!.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        setState(() {
          _finalResultBytes = response.bodyBytes; // सर्वर से आई असली ब्लेंडेड फोटो
        });
      } else {
        _showSnackbar("सर्वर एरर! कोड: ${response.statusCode}");
      }
    } catch (e) {
      _showSnackbar("कनेक्शन फेल! अपना Python सर्वर चालू रखें।");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌍 TeleportCam AI Pro', style: TextStyle(color: Color(0xFFFFB300), fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1C1C1E),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const Text('लोकेशन सर्च करें और एआई मैजिक से अपनी फोटो ओरिजिनल मिक्स करें!', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 12),

            // मुख्य प्रिव्यू बॉक्स जहाँ फाइनल असली इमेज दिखेगी
            Container(
              width: double.infinity,
              height: 320,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                border: Border.all(color: const Color(0xFFFFB300), width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  if (_finalResultBytes == null && _userImage == null && !_isLoading)
                    const Center(child: Text("लोकेशन सर्च करें और फोटो लोड करें", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                  
                  // सर्वर प्रोसेसिंग लोडर स्क्रीन
                  if (_isLoading)
                    const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB300))),
                          SizedBox(height: 10),
                          Text("AI असली फोटो मिक्स कर रहा है...", style: TextStyle(color: Color(0xFFFFB300), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),

                  // फाइनल 100% ओरिजिनल मिक्स फोटो जो सर्वर से आएगी
                  if (_finalResultBytes != null && !_isLoading)
                    Positioned.fill(child: Image.memory(_finalResultBytes, fit: BoxFit.cover)),

                  // शुरुआती यूजर फोटो का छोटा प्रिव्यू थंबनेल (अगर फाइनल नहीं आया है)
                  if (_userImage != null && _finalResultBytes == null && !_isLoading)
                    Center(child: Image.file(_userImage!, fit: BoxFit.contain)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // कंट्रोल पैनल विजेट्स
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('1. असली लोकेशन सर्च करें (उदा. India gate, Paris):', style: TextStyle(color: Color(0xFFFFB300), fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'लोकेशन का नाम लिखें...',
                            filled: true,
                            fillColor: const Color(0xFF2A2A2E),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('2. अपनी फोटो जोड़ें (कैमरा या गैलरी):', style: TextStyle(color: Color(0xFFFFB300), fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _pickUserPhoto(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt, size: 16),
                          label: const Text('कैमरा'),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2ECC71), foregroundColor: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _pickUserPhoto(ImageSource.gallery),
                          icon: const Icon(Icons.image, size: 16),
                          label: const Text('गैलरी'),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3498DB), foregroundColor: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  
                  // फाइनल एआई मिक्सिंग ऐक्शन बटन
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _processAiTeleport,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFB300), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 12)),
                      child: const Text('📸 असली फोटो मिक्स करें', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
                  
