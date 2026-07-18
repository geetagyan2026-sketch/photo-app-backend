import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const VirtualTravelCameraApp());
}

class VirtualTravelCameraApp extends StatelessWidget {
  const VirtualTravelCameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtual Travel Camera',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF090D16), // Cosmic Slate 950
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF10B981), // Emerald 500
          secondary: Color(0xFF6366F1), // Indigo 500
          surface: Color(0xFF1E293B), // Slate 800
        ),
      ),
      home: const TravelCameraWorkspace(),
    );
  }
}

class TravelCameraWorkspace extends StatefulWidget {
  const TravelCameraWorkspace({super.key});

  @override
  State<TravelCameraWorkspace> createState() => _TravelCameraWorkspaceState();
}

class _TravelCameraWorkspaceState extends State<TravelCameraWorkspace> {
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  File? _userImage;
  bool _isSearching = false;

  // Curated Destination Presets
  final List<Map<String, dynamic>> _presets = [
    {
      'name': 'Santorini, Greece',
      'url': 'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?auto=format&fit=crop&w=800&q=80',
      'color': Colors.orange,
      'tip': 'Grab a spot near the Oia Castle by 4 PM for the sunset!',
    },
    {
      'name': 'Shinjuku, Tokyo',
      'url': 'https://images.unsplash.com/photo-1540959733332-eab4deceeaf7?auto=format&fit=crop&w=800&q=80',
      'color': Colors.pinkAccent,
      'tip': 'Explore narrow alleys of Omoide Yokocho for great street food.',
    },
    {
      'name': 'Swiss Alps',
      'url': 'https://images.unsplash.com/photo-1531310197839-ccf54664f262?auto=format&fit=crop&w=800&q=80',
      'color': Colors.cyan,
      'tip': 'Board the Bernina Express railway for spectacular glacier views.',
    },
    {
      'name': 'Giza Pyramids, Egypt',
      'url': 'https://images.unsplash.com/photo-1539650116574-8efeb43e2750?auto=format&fit=crop&w=800&q=80',
      'color': Colors.amber,
      'tip': 'Enjoy a camel ride at sunset for panoramic desert views.',
    }
  ];

  late Map<String, dynamic> _selectedDestination;
  
  // Custom Organic Blending Adjustments
  double _userScale = 1.0;
  double _userX = 0.0;
  double _userY = 0.0;
  double _ambientOpacity = 0.15;
  double _brightness = 1.0;

  @override
  void initState() {
    super.initState();
    _selectedDestination = _presets[0];
  }

  // Pick Image from Gallery or Camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _userImage = File(pickedFile.path);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Portrait loaded successfully! Blend Active.'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  // Simulate Custom AI Search
  void _searchCustomLocation() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    // Simulate backend analysis delay
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isSearching = false;
        _selectedDestination = {
          'name': query,
          'url': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
          'color': Colors.tealAccent,
          'tip': 'Insider Guide: Enjoy this beautiful customized AI-generated scenery!',
        };
        _searchController.clear();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            key: const ValueKey('main-container-padding'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Header & Description
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.camera_enhance, color: Color(0xFF10B981)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Virtual Travel Camera',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                            ),
                          ),
                          Text(
                            'AI Background Blending Engine',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. TOP LOCATION SEARCH BOX
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _searchCustomLocation(),
                    decoration: InputDecoration(
                      hintText: 'दुनिया की कोई भी लोकेशन खोजें...',
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: Colors.white50),
                      suffixIcon: _isSearching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.send, color: Color(0xFF10B981)),
                              onPressed: _searchCustomLocation,
                            ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 3. MAIN COMPOSITION CAMERA VIEWPORT
                Container(
                  height: 260,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Selected Background Destination
                      Positioned.fill(
                        child: Image.network(
                          _selectedDestination['url'],
                          fit: BoxFit.cover,
                        ),
                      ),
                      
                      // Darkening Overlay matching environment brightness
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity((1.0 - _brightness).clamp(0.0, 0.8)),
                        ),
                      ),

                      // User Cutout Overlay (Simulation of Segmented Subject)
                      if (_userImage != null)
                        Positioned(
                          bottom: 20 + _userY,
                          left: 60 + _userX,
                          child: Transform.scale(
                            scale: _userScale,
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                _selectedDestination['color'].withOpacity(_ambientOpacity),
                                BlendMode.srcATop,
                              ),
                              child: Image.file(
                                _userImage!,
                                height: 180,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        )
                      else
                        Positioned.fill(
                          child: Container(
                            color: Colors.black87,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.image_not_supported, size: 40, color: Colors.white30),
                                SizedBox(height: 10),
                                Text(
                                  'कोई फोटो नहीं चुनी गई है',
                                  style: TextStyle(color: Colors.white50, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Travel Badge Overlay
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on, size: 12, color: Color(0xFF10B981)),
                              const SizedBox(width: 4),
                              Text(
                                _selectedDestination['name'],
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 4. BOTTOM ACTION CONTROL BUTTONS (CAMERA & GALLERY)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _pickImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('कैमरा (Camera)'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library),
                              label: const Text('गैलरी (Gallery)'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 5. BLENDING SETTING SLIDERS
                const Text(
                  'Ambient Blend Tuning',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Column(
                  children: [
                    _buildSliderRow('Subject Scale', _userScale, 0.5, 2.0, (val) {
                      setState(() => _userScale = val);
                    }),
                    _buildSliderRow('Horizontal Align', _userX, -100.0, 100.0, (val) {
                      setState(() => _userX = val);
                    }),
                    _buildSliderRow('Exposure Matching', _brightness, 0.5, 1.5, (val) {
                      setState(() => _brightness = val);
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliderRow(String label, double val, double min, double max, ValueChanged<double> onChange) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70))),
          Expanded(
            child: Slider(
              value: val,
              min: min,
              max: max,
              activeColor: const Color(0xFF10B981),
              onChanged: onChange,
            ),
          ),
        ],
      ),
    );
  }
}
