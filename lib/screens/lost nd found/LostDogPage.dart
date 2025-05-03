import 'package:borktok/screens/lost%20nd%20found/mapp.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

// Data model for lost dogs
class LostDog {
  final String name;
  final String breed;
  final String ownerName;
  final String ownerPhone;
  final String location;
  final double latitude;
  final double longitude;
  final File? image;
  final DateTime lostTime;

  LostDog({
    required this.name,
    required this.breed,
    required this.ownerName,
    required this.ownerPhone,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.image,
    required this.lostTime,
  });
}

// Singleton service to maintain state without Provider
class LostDogService {
  static final LostDogService _instance = LostDogService._internal();
  
  factory LostDogService() {
    return _instance;
  }
  
  LostDogService._internal();
  
  final List<LostDog> _lostDogs = [];
  List<LostDog> get lostDogs => _lostDogs;
  
  void addLostDog(LostDog dog) {
    _lostDogs.add(dog);
  }
  
  void cancelAlert(LostDog dog) {
    _lostDogs.remove(dog);
  }
}

class LostDogPage extends StatefulWidget {
  const LostDogPage({Key? key}) : super(key: key);

  @override
  _LostDogPageState createState() => _LostDogPageState();
}

class _LostDogPageState extends State<LostDogPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final LostDogService _lostDogService = LostDogService();
  File? _imageFile;
  bool _isLoading = false;
  String _currentAddress = "Fetching location...";
  double _latitude = 0.0;
  double _longitude = 0.0;
  bool _locationFetched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationPermission();
    });

  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    
    if (status.isGranted) {
      _getCurrentLocation();
    } else if (status.isDenied) {
      setState(() {
        _currentAddress = "Location permission denied. Using default location.";
        _latitude = 28.6692; // Default coordinates
        _longitude = 77.4538;
      });
      
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
            'Location permission is needed to accurately report where you lost your dog. This helps match lost and found pets in the same area.'
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
    } else if (status.isPermanentlyDenied) {
      setState(() {
        _currentAddress = "Location access permanently denied. Using default location.";
        _latitude = 28.6692; 
        _longitude = 77.4538;
      });
      
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Location Permission Denied'),
          content: const Text(
            'Location permission is permanently denied. Please enable it in app settings.'
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    Placemark place = placemarks[0];
    String address =
        '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}';

    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
      _currentAddress = address;
      _isLoading = false;
      _locationFetched = true;
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      imageQuality: 80,
    );

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
          const SnackBar(content: Text('Please select a dog photo')),
        );
        return;
      }

      // Create a new lost dog report
      final newLostDog = LostDog(
        name: _nameController.text,
        breed: _breedController.text,
        ownerName: _ownerNameController.text,
        ownerPhone: _phoneController.text,
        location: _currentAddress,
        latitude: _latitude,
        longitude: _longitude,
        image: _imageFile,
        lostTime: DateTime.now(),
      );

      // Add it to service
      _lostDogService.addLostDog(newLostDog);

      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Alert Sent Successfully'),
          content: const Text('Your lost dog alert has been sent! Notifications have been sent to app users in your area.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                // Navigate to the list of active alerts
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ActiveAlertsPage()),
                );
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // Beige background
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C8D89),
        title: const Text(
          'Report Lost Dog',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF5C8D89)),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Location card with map
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
                                  Icon(
                                    Icons.location_on,
                                    color: Color(0xFF5C8D89),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Dog Last Seen Location',
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
                              
                              // Map view
                              if (_locationFetched)
                                Column(
                                  children: [
                                    const SizedBox(height: 8),
                                    DogLocationMap(
                                      latitude: _latitude,
                                      longitude: _longitude,
                                      title: 'Dog Last Seen Here',
                                      height: 200,
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                ),
                              
                              ElevatedButton.icon(
                                onPressed: _getCurrentLocation,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Update Location'),
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
                          child:
                              _imageFile != null
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
                                        'Add a photo of your dog',
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

                      // Dog details
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
                                'Dog Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Dog Name',
                                  prefixIcon: const Icon(
                                    Icons.pets,
                                    color: Color(0xFF5C8D89),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF5C8D89),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your dog\'s name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _breedController,
                                decoration: InputDecoration(
                                  labelText: 'Breed',
                                  prefixIcon: const Icon(
                                    Icons.category,
                                    color: Color(0xFF5C8D89),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF5C8D89),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your dog\'s breed';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Owner details
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
                                'Contact Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _ownerNameController,
                                decoration: InputDecoration(
                                  labelText: 'Your Name',
                                  prefixIcon: const Icon(
                                    Icons.person,
                                    color: Color(0xFF5C8D89),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF5C8D89),
                                      width: 2,
                                    ),
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
                                  prefixIcon: const Icon(
                                    Icons.phone,
                                    color: Color(0xFF5C8D89),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF5C8D89),
                                      width: 2,
                                    ),
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
                          'SEND LOST DOG ALERT',
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
    );
  }
}

class ActiveAlertsPage extends StatefulWidget {
  @override
  _ActiveAlertsPageState createState() => _ActiveAlertsPageState();
}

class _ActiveAlertsPageState extends State<ActiveAlertsPage> {
  final LostDogService _lostDogService = LostDogService();
  
  @override
  Widget build(BuildContext context) {
    final lostDogs = _lostDogService.lostDogs;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C8D89),
        title: const Text(
          'Active Lost Dog Alerts',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: lostDogs.isEmpty 
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No active alerts',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: lostDogs.length,
              itemBuilder: (context, index) {
                final dog = lostDogs[index];
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
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.file(
                          dog.image!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                      // Map view showing where the dog was lost
                      DogLocationMap(
                        latitude: dog.latitude,
                        longitude: dog.longitude,
                        title: '${dog.name} was last seen here',
                        snippet: 'Lost on ${dog.lostTime.day}/${dog.lostTime.month}/${dog.lostTime.year}',
                        height: 180,
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Alert status
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.red[700],
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'LOST',
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Dog name and breed
                            Text(
                              dog.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              dog.breed,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),

                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 8),

                            // Location
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.grey[700],
                                  size: 18,
                                ),
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

                            // Lost time
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: Colors.grey[700],
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Lost on ${dog.lostTime.day}/${dog.lostTime.month}/${dog.lostTime.year} at ${dog.lostTime.hour}:${dog.lostTime.minute.toString().padLeft(2, '0')}',
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
                                Icon(
                                  Icons.person,
                                  color: Colors.grey[700],
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Contact: ${dog.ownerName} (${dog.ownerPhone})',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Cancel alert button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Cancel Alert'),
                                      content: const Text(
                                        'Has your dog been found? This will remove the alert from the system.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(ctx).pop(),
                                          child: const Text('No'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              _lostDogService.cancelAlert(dog);
                                            });
                                            Navigator.of(ctx).pop();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Alert cancelled. We\'re glad your dog is safe!',
                                                ),
                                              ),
                                            );
                                          },
                                          child: const Text('Yes'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.cancel_outlined),
                                label: const Text('CANCEL ALERT'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF5C8D89),
                                  side: const BorderSide(
                                    color: Color(0xFF5C8D89),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
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
            ),
    );
  }
}