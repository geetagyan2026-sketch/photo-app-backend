import 'package:http/http.dart' as http;

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WorldCamApp(),
    ));

class WorldCamApp extends StatefulWidget {
  const WorldCamApp({Key? key}) : super(key: key);

  @override
  _WorldCamAppState createState() => _WorldCamAppState();
}

class _WorldCamAppState extends State<WorldCamApp> {
  final TextEditingController _locationController = TextEditingController();
  bool _isLoading = false;
  String? _imageUrl;

  Future<void> _fetchBlendedImage() async {
    if (_locationController.text.isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://onrender.com'),
      );
      
      request.fields['location'] = _locationController.text;
      
      // कंपाइलर एरर से बचने के लिए एक साधारण खाली लिस्ट भेजी गई है
      List<int> dummyBytes = [];
      
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        dummyBytes,
        filename: 'user_photo.jpg',
      ));

      var response = await request.send();
      if (response.statusCode == 200) {
        setState(() {
          _imageUrl = 'https://unsplash.com';
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B141A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _locationController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "दुनिया की कोई भी लोकेशन लिखें...",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isLoading ? null : _fetchBlendedImage,
                child: Text(_isLoading ? "AI फोटो बन रही है..." : "लाइव फोटो प्राप्त करें"),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white10,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _isLoading 
                      ? const Center(child: CircularProgressIndicator())
                      : _imageUrl != null 
                          ? Image.network(_imageUrl!, fit: BoxFit.cover)
                          : const Center(child: Text("यहाँ आपकी लाइव फोटो दिखेगी", style: TextStyle(color: Colors.white))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
