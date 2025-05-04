import 'package:cloud_firestore/cloud_firestore.dart';

class DogListing {
  final String id;
  final String name;
  final String breed;
  final int age;
  final String gender;
  final String location;
  final double price;
  final String description;
  final String imageUrl; // Changed from imageBase64 to imageUrl
  final String?
  vaccinationCertificateUrl; // Changed from vaccinationCertificateBase64 to URL
  final String ownerId;
  final String ownerName;
  final DateTime datePosted;

  DogListing({
    required this.id,
    required this.name,
    required this.breed,
    required this.age,
    required this.gender,
    required this.location,
    required this.price,
    required this.description,
    required this.imageUrl,
    this.vaccinationCertificateUrl,
    required this.ownerId,
    required this.ownerName,
    required this.datePosted,
  });

  // Convert Firestore document to DogListing
  factory DogListing.fromFirestore(Map<String, dynamic> data, String docId) {
    return DogListing(
      id: docId,
      name: data['name'] ?? '',
      breed: data['breed'] ?? '',
      age: data['age'] ?? 0,
      gender: data['gender'] ?? '',
      location: data['location'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      vaccinationCertificateUrl: data['vaccinationCertificateUrl'],
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      datePosted:
          (data['datePosted'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert DogListing to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'breed': breed,
      'age': age,
      'gender': gender,
      'location': location,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'vaccinationCertificateUrl': vaccinationCertificateUrl,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'datePosted': Timestamp.fromDate(datePosted),
    };
  }
}
