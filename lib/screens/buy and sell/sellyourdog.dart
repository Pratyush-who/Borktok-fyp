import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:borktok/screens/buy and sell/doglistingmodel.dart';
import 'package:borktok/screens/buy and sell/doglistingservice.dart';

class SellDogScreen extends StatefulWidget {
  const SellDogScreen({Key? key}) : super(key: key);

  @override
  _SellDogScreenState createState() => _SellDogScreenState();
}

class _SellDogScreenState extends State<SellDogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dogListingService = DogListingService();
  final _picker = ImagePicker();

  // Form controllers
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _genderController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _dogImage;
  File? _vaccinationCertificate;
  bool _isUploading = false;

  Future<void> _pickImage(bool isVaccinationCert) async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // Compress image for faster uploads
    );
    
    if (pickedFile != null) {
      setState(() {
        if (isVaccinationCert) {
          _vaccinationCertificate = File(pickedFile.path);
        } else {
          _dogImage = File(pickedFile.path);
        }
      });
    }
  }

  void _submitListing() async {
    if (_formKey.currentState!.validate()) {
      if (_dogImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload a dog image')),
        );
        return;
      }

      try {
        setState(() {
          _isUploading = true;
        });
        
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please log in to list a dog')),
          );
          return;
        }

        final newListing = DogListing(
          id: '', // Firestore will generate the ID
          name: _nameController.text,
          breed: _breedController.text,
          age: int.parse(_ageController.text),
          gender: _genderController.text,
          location: _locationController.text,
          price: double.parse(_priceController.text),
          description: _descriptionController.text,
          imageUrl: '', // Will be set by the service after Cloudinary upload
          vaccinationCertificateUrl: null,
          ownerId: user.uid,
          ownerName: user.displayName ?? 'Anonymous',
          datePosted: DateTime.now(),
        );

        // Add more detailed error handling
        try {
          await _dogListingService.addDogListing(
            newListing, 
            _dogImage!, 
            vaccinationCertificate: _vaccinationCertificate
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${_nameController.text} listed successfully!')),
          );

          _formKey.currentState!.reset();
          setState(() {
            _dogImage = null;
            _vaccinationCertificate = null;
          });
          
          // Go back to the listings page after successful submission
          Navigator.pop(context);
        } catch (uploadError) {
          print('Listing upload error: $uploadError');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload listing: $uploadError')),
          );
        }
      } catch (e) {
        print('Submission error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Sell Your Dog'),
        backgroundColor: const Color(0xFFF5D4A0),
      ),
      body: _isUploading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  ),
                  const SizedBox(height: 16),
                  const Text('Uploading your listing...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Dog Image Picker
                    GestureDetector(
                      onTap: () => _pickImage(false),
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _dogImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.camera_alt, size: 50),
                                  Text('Upload Dog Image'),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(_dogImage!, fit: BoxFit.cover),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Vaccination Certificate Picker
                    GestureDetector(
                      onTap: () => _pickImage(true),
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _vaccinationCertificate == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.document_scanner, size: 40),
                                  Text('Upload Vaccination Certificate (Optional)'),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(_vaccinationCertificate!, fit: BoxFit.cover),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Text Input Fields
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Dog Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Please enter dog name' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _breedController,
                      decoration: const InputDecoration(
                        labelText: 'Breed',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Please enter breed' : null,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Age',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value!.isEmpty ? 'Please enter age' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _genderController,
                            decoration: const InputDecoration(
                              labelText: 'Gender',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value!.isEmpty ? 'Please enter gender' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Please enter location' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        prefixText: '\$',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Please enter price' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Please enter description' : null,
                    ),
                    const SizedBox(height: 16),

                    ElevatedButton(
                      onPressed: _submitListing,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'List My Dog',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}