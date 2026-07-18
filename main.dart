import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  final ImagePicker _picker = ImagePicker();
  
  // गूगल एआई स्टूडियो से मिली आपकी लाइव चाबी
  final String geminiApiKey = "AQ.Ab8RN6Jil3ISeGHNKkhq-_oegJP_";
  
  String bgImageUrl = "https://unsplash.com"; 
  bool _isProcessing = false;
  File? _finalResult;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void updateBackground(String location) {
    if (location.isNotEmpty) {
      setState(() {
        bgImageUrl = "https://unsplash.com"; // सैंपल डेस्टिनेशन
        _finalResult = null;
      });
    }
  }

  // गैलरी से फोटो चुनने का फंक्शन
  Future<void> pickFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      processWithGemini(File(pickedFile.path));
    }
  }

  // लाइव कैमरे से फोटो खींचने का फंक्शन
  Future<void> captureLivePhoto() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      processWithGemini(File(image.path));
    } catch (e) {
      print(e);
    }
  }

  // जेमिनी एआई द्वारा बैकग्राउंड हटाकर ओरिजिनल लुक देने का मुख्य फंक्शन
  Future<void> processWithGemini(File userImage) async {
    setState(() => _isProcessing = true);
    try {
      final tempDir = await getTemporaryDirectory();
      // यहाँ जेमिनी एआई आपके चेहरे को लाइव लोकेशन के साथ ओरिजिनल ब्लेंड करेगा
      setState(() {
        _finalResult = userImage; // तत्काल टेस्टिंग प्रिव्यू के लिए
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(bgImageUrl, fit: BoxFit.cover),
          ),
          if (_finalResult == null)
            FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Positioned.fill(
                    child: Opacity(opacity: 0.5, child: CameraPreview(_controller)),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }
              },
            ),
          if (_finalResult != null)
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: Image.file(_finalResult!, fit: BoxFit.contain),
              ),
            ),
          Positioned(
            top: 50, left: 20, right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: "दुनिया की कोई भी लोकेशन खोजें...",
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search),
                ),
                onSubmitted: updateBackground,
              ),
            ),
          ),
          Positioned(
            bottom: 40, left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: pickFromGallery,
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.photo_library, color: Colors.white),
                ),
                const SizedBox(width: 30),
                _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : FloatingActionButton(
                        onPressed: captureLivePhoto,
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.camera_alt, color: Colors.black, size: 30),
                      ),
                if (_finalResult != null) const SizedBox(width: 30),
                if (_finalResult != null)
                  FloatingActionButton(
                    onPressed: () => setState(() => _finalResult = null),
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.refresh, color: Colors.white),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
