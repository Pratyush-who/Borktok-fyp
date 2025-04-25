import 'package:borktok/screens/lost%20nd%20found/LostDogPage.dart' as lost_dog_page;
import 'package:borktok/screens/lost%20nd%20found/providers/dog_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

// Add this new widget class above your FoundDogPage
class LostDogsList extends StatelessWidget {
  const LostDogsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lostDogs = lost_dog_page.LostDogService().lostDogs;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C8D89),
        title: const Text(
          'Lost Dogs in Your Area',
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
                  const Text(
                    'No lost dogs reported in your area',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: lostDogs.length,
              itemBuilder: (context, index) {
                final dog = lostDogs[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: FileImage(dog.image!),
                    ),
                    title: Text(dog.name),
                    subtitle: Text(dog.breed),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      _showDogDetails(context, dog);
                    },
                  ),
                );
              },
            ),
    );
  }

  void _showDogDetails(BuildContext context, lost_dog_page.LostDog dog) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(dog.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.file(dog.image!, height: 200),
              const SizedBox(height: 16),
              Text('Breed: ${dog.breed}'),
              Text('Owner: ${dog.ownerName}'),
              Text('Phone: ${dog.ownerPhone}'),
              const SizedBox(height: 8),
              Text('Last seen: ${dog.location}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class FoundDogPage extends StatefulWidget {
  const FoundDogPage({Key? key}) : super(key: key);

  @override
  _FoundDogPageState createState() => _FoundDogPageState();
}

class _FoundDogPageState extends State<FoundDogPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _finderNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  File? _imageFile;
  bool _isLoading = false;
  String _currentAddress = "Fetching location...";
  double _latitude = 0.0;
  double _longitude = 0.0;

  // Notification plugin
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _requestLocationPermission();
  }

  // Update your _initNotifications method
  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // For Android 8.0+ we need to create a notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'found_dog_channel', // Same as channelId below
      'Found Dog Alerts', // Same as channelName below
      description: 'Notifications about found dogs',
      importance: Importance.max,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    // Create the channel
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap if needed
      },
    );
  }

  // Update your _showNotification method
  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'found_dog_channel', // Same as channelId above
          'Found Dog Alerts', // Same as channelName above
          channelDescription: 'Notifications about found dogs',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          showWhen: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _notificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      notificationDetails,
      payload: 'found_dog_payload', // Optional payload
    );
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showErrorSnackbar('Please enable location services');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showErrorSnackbar('Location permissions denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showErrorSnackbar('Location permissions permanently denied');
      return;
    }
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String address =
          placemarks.isNotEmpty
              ? '${placemarks[0].street}, ${placemarks[0].locality}'
              : "Location found";

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _currentAddress = address;
        _isLoading = false;
      });
    } catch (e) {
      _showErrorSnackbar('Error getting location: $e');
      setState(() {
        _currentAddress = "Ghaziabad, UP (Default)";
        _latitude = 28.6692;
        _longitude = 77.4538;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final status = await Permission.photos.request();
      if (status.isGranted) {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1000,
          imageQuality: 80,
        );

        if (image != null) {
          setState(() => _imageFile = File(image.path));
        }
      } else {
        _showErrorSnackbar('Gallery permission required');
      }
    } catch (e) {
      _showErrorSnackbar('Error accessing gallery: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_imageFile == null) {
        _showErrorSnackbar('Please select a dog photo');
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
      final provider = Provider.of<FoundDogsProvider>(context, listen: false);
      provider.addFoundDog(newFoundDog);

      // Show notification
      _showNotification(
        'Found Dog Reported',
        'A dog has been found in your area',
      );

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Found dog report submitted!')),
      );

      // Clear form
      _formKey.currentState?.reset();
      setState(() => _imageFile = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C8D89),
        title: const Text(
          'Report Found Dog',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LostDogsList()),
              );
            },
          ),
        ],
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
                                  Icon(
                                    Icons.location_on,
                                    color: Color(0xFF5C8D89),
                                  ),
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
                                        'Add a photo of the found dog',
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
                                  labelText:
                                      'Description (breed, color, markings)',
                                  prefixIcon: const Icon(
                                    Icons.description,
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
                                maxLines: 3,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please provide a description';
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
    );
  }
}
