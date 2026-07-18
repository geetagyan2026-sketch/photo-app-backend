import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // मोबाइल के कैमरों की लिस्ट निकालना
  final cameras = await availableCameras();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TravelCameraApp(camera: cameras.first),
  ));
}

class TravelCameraApp extends StatefulWidget {
  final CameraDescription camera;
  const TravelCameraApp({Key? key, required this.camera}) : super(key: key);

  @override
  _TravelCameraAppState createState() => _TravelCameraAppState();
}

class _TravelCameraAppState extends State<TravelCameraApp> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  
  // डिफ़ॉल्ट लाइव लोकेशन इमेज (पेरिस - एफिल टॉवर)
  String bgImageUrl = "https://unsplash.com"; 
  bool _isProcessing = false;
  File? _finalResult;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // कैमरा सेटअप
    _controller = CameraController(widget.camera, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // लोकेशन सर्च करने पर बैकग्राउंड बदलने का फंक्शन
  void updateBackground(String location) {
    if (location.isNotEmpty) {
      setState(() {
        // Unsplash से उस लोकेशन की एकदम ताज़ा इमेज उठाना
        bgImageUrl = "https://unsplash.com{Uri.encodeComponent(location)}";
        _finalResult = null; // पुराना रिजल्ट साफ़ करना
      });
    }
  }

  // फोटो क्लिक करके फ्री एआई गेटवे पर भेजने और ब्लेंड करने का मुख्य फंक्शन
  Future<void> captureAndBlend() async {
    setState(() => _isProcessing = true);
    try {
      await _initializeControllerFuture;
      // 1. यूजर की लाइव फोटो क्लिक करना
      final image = await _controller.takePicture();

      // 2. बैकग्राउंड लोकेशन की इमेज डाउनलोड करना
      final bgResponse = await http.get(Uri.parse(bgImageUrl));
      final tempDir = await getTemporaryDirectory();
      File bgFile = await File('${tempDir.path}/bg.jpg').writeAsBytes(bgResponse.bodyBytes);

      // 🛑 यह बिल्कुल फ्री और बिना लॉगिन वाला रेडीमेड एआई लिंक है जो फोटो असली बनाएगा
      var liveApiUrl = "https://glitch.me";

      // 3. दोनों इमेजेस को एआई गेटवे पर पोस्ट करना
      var request = http.MultipartRequest('POST', Uri.parse(liveApiUrl));
      request.files.add(await http.MultipartFile.fromPath('user_img', image.path));
      request.files.add(await http.MultipartFile.fromPath('bg_img', bgFile.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        final respBytes = await response.stream.toBytes();
        setState(() {
          // एआई से आई एकदम असली फोटो को मोबाइल स्क्रीन पर दिखाना
          _finalResult = File('${tempDir.path}/result.jpg')..writeAsBytesSync(respBytes);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("एआई सर्वर से कनेक्ट होने में दिक्कत आई।")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("एरर: $e")),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. बैकग्राउंड में दिखने वाली दुनिया की लाइव लोकेशन इमेज
          Positioned.fill(
            child: Image.network(
              bgImageUrl, 
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.black, child: const Center(child: Text("इमेज लोड हो रही है...", style: TextStyle(color: Colors.white))));
              },
            ),
          ),
          
          // 2. सामने यूजर का लाइव कैमरा प्रिव्यू (हल्का ट्रांसपेरेंट ओवरले)
          if (_finalResult == null)
            FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Positioned.fill(
                    child: Opacity(
                      opacity: 0.5, // यूजर को पोजीशन सेट करने में मदद के लिए
                      child: CameraPreview(_controller),
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }
              },
            ),

          // 3. एआई द्वारा बनाई गई फाइनल असली (Original) फोटो यहाँ दिखेगी
          if (_finalResult != null)
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: Image.file(_finalResult!, fit: BoxFit.contain),
              ),
            ),

          // 4. ऊपर बना लोकेशन सर्च बॉक्स
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: "कहाँ की फोटो चाहिए? (उदा: Taj Mahal)",
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search, color: Colors.black),
                ),
                onSubmitted: updateBackground,
              ),
            ),
          ),

          // 5. नीचे बना फोटो क्लिक और रीसेट बटन
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_finalResult != null)
                  FloatingActionButton(
                    onPressed: () => setState(() => _finalResult = null),
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.refresh, color: Colors.white),
                  ),
                if (_finalResult != null) const SizedBox(width: 40),
                _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : FloatingActionButton(
                        onPressed: captureAndBlend,
                        backgroundColor: Colors.white,
                        child: Icon(
                          _finalResult != null ? Icons.check : Icons.camera_alt, 
                          color: Colors.black, 
                          size: 30
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
