import 'package:borktok/screens/lost%20nd%20found/LostDogPage.dart'
    as lost_dog_page;
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
  
  void removeFoundDog(FoundDog dog) {
    _foundDogs.remove(dog);
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
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C8D89),
        title: const Text(
          'Lost Dogs in Your Area',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body:
          lostDogs.isEmpty
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
                        
                        // Location information (replacing map)
                        Container(
                          height: 80,
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.red),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Last seen at: ${dog.location}',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                              const SizedBox(height: 12),
                              Text(
                                'Owner: ${dog.ownerName}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Contact: ${dog.ownerPhone}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.call),
                                label: const Text('CONTACT OWNER'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5C8D89),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
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

// New page to display all found dog reports
class ActiveFoundDogsPage extends StatelessWidget {
  const ActiveFoundDogsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final foundDogsProvider = Provider.of<FoundDogsProvider>(context);
    final foundDogs = foundDogsProvider.foundDogs;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C8D89),
        title: const Text(
          'Found Dog Reports',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: foundDogs.isEmpty 
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No found dog reports yet',
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
              itemCount: foundDogs.length,
              itemBuilder: (context, index) {
                final dog = foundDogs[index];
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

                      // Location information (replacing map)
                      Container(
                        height: 80,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.green),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Found at: ${dog.location}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
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
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green[700],
                                    size: 16,
                                  ),
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

                            // Dog description
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

                            // Found time
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: Colors.grey[700],
                                  size: 18,
                                ),
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
                                Icon(
                                  Icons.person,
                                  color: Colors.grey[700],
                                  size: 18,
                                ),
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

                            // Remove report button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Remove Report'),
                                      content: const Text(
                                        'Has the dog been reunited with its owner? This will remove the report from the system.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(ctx).pop(),
                                          child: const Text('No'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            foundDogsProvider.removeFoundDog(dog);
                                            Navigator.of(ctx).pop();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Report removed. Thank you for helping reunite a pet!',
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
                                icon: const Icon(Icons.check_circle_outline),
                                label: const Text('REMOVE REPORT'),
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
  bool _locationFetched = false;

  // Notification plugin
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _requestLocationPermission();
  }

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
            'Location permission is needed to accurately report where you found the dog. This helps match lost and found pets in the same area.'
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

    try {
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
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() => _imageFile = File(image.path));
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
        'Your found dog report has been submitted',
      );

      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Report Submitted Successfully'),
          content: const Text('Your found dog report has been submitted! Notifications have been sent to app users in your area who may have lost their dogs.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                // Clear form
                _formKey.currentState?.reset();
                setState(() => _imageFile = null);
                // Navigate to the list of found dogs
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ActiveFoundDogsPage()),
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
            tooltip: 'View lost dogs',
          ),
          IconButton(
            icon: const Icon(Icons.pets),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ActiveFoundDogsPage()),
              );
            },
            tooltip: 'View found dog reports',
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
                              
                              // Simple location display instead of map
                              Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[200],
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.location_on, size: 30, color: Colors.grey[600]),
                                      SizedBox(height: 8),
                                      Text(
                                        'Location: ${_currentAddress.split(',').take(2).join(',')}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 12),
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
                                        size: 50,
                                        color: Color(0xFF5C8D89),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Add Photo of Found Dog',
                                        style: TextStyle(
                                          color: Color(0xFF5C8D89),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Dog description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Dog Description',
                          labelStyle: TextStyle(color: Color(0xFF5C8D89)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF5C8D89)),
                          ),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please describe the dog';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Your name
                      TextFormField(
                        controller: _finderNameController,
                        decoration: InputDecoration(
                          labelText: 'Your Name',
                          labelStyle: TextStyle(color: Color(0xFF5C8D89)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF5C8D89)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Your phone number
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Your Phone Number',
                          labelStyle: TextStyle(color: Color(0xFF5C8D89)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF5C8D89)),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                            return 'Please enter a valid 10-digit phone number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      // Submit button
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF5C8D89),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'SUBMIT FOUND DOG REPORT',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
    );
  }
}