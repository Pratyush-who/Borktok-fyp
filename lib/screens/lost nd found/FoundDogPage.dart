import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

// Provider for found dog data
class FoundDogsProvider extends ChangeNotifier {
  List<FoundDog> _foundDogs = [];
  List<FoundDog> get foundDogs => _foundDogs;

  void addFoundDog(FoundDog dog) {
    _foundDogs.add(dog);
    notifyListeners();
  }
}

class FoundDog {
  final String description;
  final String finderName;
  final String finderPhone;
  final String location;
  final double latitude;
  final double longitude;
  final File? image;
  final DateTime foundTime;

  FoundDog({
    required this.description,
    required this.finderName,
    required this.finderPhone,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.image,
    required this.foundTime,
  });
}

class FoundDogPage extends StatefulWidget {
  const FoundDogPage({Key? key}) : super(key: key);

  @override
  _FoundDogPageState createState() => _FoundDogPageState();
}

class _FoundDogPageState extends State<FoundDogPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _finderNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  File? _imageFile;
  bool _isLoading = false;
  String _currentAddress = "Fetching location...";
  double _latitude = 0.0;
  double _longitude = 0.0;
  
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _requestLocationPermission();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      setState(() {
        _currentAddress = "Ghaziabad, Uttar Pradesh"; // Default location
        _latitude = 28.6692;
        _longitude = 77.4538;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, 
        position.longitude,
      );
      
      Placemark place = placemarks[0];
      String address = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}';
      
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _currentAddress = address;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _currentAddress = "Ghaziabad, Uttar Pradesh"; // Default location
        _latitude = 28.6692;
        _longitude = 77.4538;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add a photo of the dog you found')),
        );
        return;
      }
      
      // Create a new found dog report
      final newFoundDog = FoundDog(
        description: _descriptionController.text,
        finderName: _finderNameController.text,
        finderPhone: _phoneController.text,
        location: _currentAddress,
        latitude: _latitude,
        longitude: _longitude,
        image: _imageFile,
        foundTime: DateTime.now(),
      );
      
      // Add it to provider
      Provider.of<FoundDogsProvider>(context, listen: false).addFoundDog(newFoundDog);
      
      // Show confirmation and mock sending notification
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you! Your found dog report has been submitted. Notifications sent to pet owners in the area.')),
      );
      
      // Switch to found dogs tab to see the listing
      _tabController.animateTo(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // Beige background
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C8D89),
        title: const Text('Found Dogs', style: TextStyle(color: Colors.white)),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Report Found Dog'),
            Tab(text: 'Found Dog Listings'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Report Found Dog Tab
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF5C8D89)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Hero section
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5C8D89).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF5C8D89).withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.pets,
                                size: 48,
                                color: const Color(0xFF5C8D89),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Found a Dog?',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5C8D89),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Help reunite this lost dog with their owner by submitting details below.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Location card
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.location_on, color: Color(0xFF5C8D89)),
                                    SizedBox(width: 8),
                                    Text(
                                      'Found Location',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _currentAddress,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: _getCurrentLocation,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Refresh Location'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF5C8D89),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Dog image selection
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            height: 180,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: _imageFile != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      _imageFile!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.add_photo_alternate,
                                        size: 60,
                                        color: Color(0xFF5C8D89),
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'Add a photo of the dog you found',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Dog description
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Dog Description',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _descriptionController,
                                  decoration: InputDecoration(
                                    labelText: 'Describe the dog (breed, color, size, etc.)',
                                    prefixIcon: const Icon(Icons.description, color: Color(0xFF5C8D89)),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Color(0xFF5C8D89), width: 2),
                                    ),
                                  ),
                                  maxLines: 3,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please provide a description of the dog';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Finder details
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Your Contact Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _finderNameController,
                                  decoration: InputDecoration(
                                    labelText: 'Your Name',
                                    prefixIcon: const Icon(Icons.person, color: Color(0xFF5C8D89)),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Color(0xFF5C8D89), width: 2),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _phoneController,
                                  decoration: InputDecoration(
                                    labelText: 'Phone Number',
                                    prefixIcon: const Icon(Icons.phone, color: Color(0xFF5C8D89)),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Color(0xFF5C8D89), width: 2),
                                    ),
                                  ),
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your phone number';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5C8D89),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'SUBMIT FOUND DOG REPORT',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          
          // Found Dogs Listings Tab
          Consumer<FoundDogsProvider>(
            builder: (context, provider, child) {
              if (provider.foundDogs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pets,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No found dogs reported yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.foundDogs.length,
                itemBuilder: (context, index) {
                  final dog = provider.foundDogs[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.file(
                            dog.image!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Status tag
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.green[700], size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      'FOUND',
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // Description
                              const Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dog.description,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[800],
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 8),
                              
                              // Location
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: Colors.grey[700], size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      dog.location,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 8),
                              
                              // Found time
                              Row(
                                children: [
                                  Icon(Icons.access_time, color: Colors.grey[700], size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Found on ${dog.foundTime.day}/${dog.foundTime.month}/${dog.foundTime.year} at ${dog.foundTime.hour}:${dog.foundTime.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 8),
                              
                              // Contact info
                              Row(
                                children: [
                                  Icon(Icons.person, color: Colors.grey[700], size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Contact: ${dog.finderName} (${dog.finderPhone})',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Contact button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // This would launch the phone dialer in a real app
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Calling ${dog.finderPhone}...')),
                                    );
                                  },
                                  icon: const Icon(Icons.phone),
                                  label: const Text('CONTACT FINDER'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF5C8D89),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 8),
                              
                              // Share button
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Sharing dog information...')),
                                    );
                                  },
                                  icon: const Icon(Icons.share),
                                  label: const Text('SHARE'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF5C8D89),
                                    side: const BorderSide(color: Color(0xFF5C8D89)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}