import 'dart:io';
import 'package:borktok/screens/buy%20and%20sell/doglistingmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

class DogListingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize Cloudinary with your cloud name and upload preset
  // You'll need to create an unsigned upload preset in your Cloudinary dashboard
  final cloudinary = CloudinaryPublic('dteigt5oc', 'ml_default');

  // Static list of dogs for sale (updated to use URLs)
  static List<DogListing> staticDogListings = [
    DogListing(
      id: '1',
      name: 'Max',
      breed: 'Golden Retriever',
      age: 3,
      gender: 'Male',
      location: 'New York, NY',
      price: 1500.00,
      description:
          'Friendly and energetic Golden Retriever. Great with children and loves to play fetch. Fully vaccinated and trained.',
      imageUrl:
          'https://res.cloudinary.com/demo/image/upload/v1/samples/animals/dog',
      vaccinationCertificateUrl: null,
      ownerId: 'owner1',
      ownerName: 'John Doe',
      datePosted: DateTime.now().subtract(Duration(days: 5)),
    ),
  ];

  Future<List<DogListing>> getAllDogListings() async {
    try {
      final querySnapshot =
          await _firestore
              .collection('dog_listings')
              .orderBy('datePosted', descending: true)
              .get();

      List<DogListing> firestoreListings =
          querySnapshot.docs
              .map((doc) => DogListing.fromFirestore(doc.data(), doc.id))
              .toList();

      List<DogListing> combinedListings = [
        ...staticDogListings,
        ...firestoreListings,
      ];

      final uniqueListings = <DogListing>[];
      final seen = <String>{};

      for (var listing in combinedListings) {
        final key = '${listing.name}_${listing.datePosted}';
        if (!seen.contains(key)) {
          uniqueListings.add(listing);
          seen.add(key);
        }
      }

      uniqueListings.sort((a, b) => b.datePosted.compareTo(a.datePosted));

      return uniqueListings;
    } catch (e) {
      print('Error fetching dog listings: $e');
      return staticDogListings;
    }
  }

  // Upload image to Cloudinary and return the URL
  Future<String> _uploadImageToCloudinary(File imageFile, String folder) async {
    try {
      // Validate image file
      if (!imageFile.existsSync()) {
        throw Exception('Image file does not exist: ${imageFile.path}');
      }

      final fileSize = imageFile.lengthSync();
      if (fileSize == 0) {
        throw Exception('Image file is empty');
      }

      // Upload to Cloudinary
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(imageFile.path, folder: folder),
      );

      // Return secure URL
      return response.secureUrl;
    } catch (e) {
      print('Error uploading image to Cloudinary: $e');
      rethrow;
    }
  }

  Future<void> addDogListing(
    DogListing dogListing,
    File imageFile, {
    File? vaccinationCertificate,
  }) async {
    try {
      // Upload dog image to Cloudinary
      final imageUrl = await _uploadImageToCloudinary(imageFile, 'dog_images');

      // Upload vaccination certificate if provided
      String? vaccinationUrl;
      if (vaccinationCertificate != null) {
        vaccinationUrl = await _uploadImageToCloudinary(
          vaccinationCertificate,
          'vaccination_certificates',
        );
      }

      // Create final listing with image URLs
      final finalListing = DogListing(
        id: '', // Firestore will generate the ID
        name: dogListing.name,
        breed: dogListing.breed,
        age: dogListing.age,
        gender: dogListing.gender,
        location: dogListing.location,
        price: dogListing.price,
        description: dogListing.description,
        imageUrl: imageUrl,
        vaccinationCertificateUrl: vaccinationUrl,
        ownerId: dogListing.ownerId,
        ownerName: dogListing.ownerName,
        datePosted: DateTime.now(),
      );

      // Add to Firestore
      await _firestore
          .collection('dog_listings')
          .add(finalListing.toFirestore());

      print('Dog listing added successfully');
    } catch (e) {
      print('Error adding dog listing: $e');
      rethrow;
    }
  }
}
