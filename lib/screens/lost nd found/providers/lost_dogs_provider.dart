// Add this provider class (should be in the same file as FoundDogsProvider)
import 'dart:io';

import 'package:flutter/material.dart';

class LostDogsProvider extends ChangeNotifier {
  final List<LostDog> _lostDogs = [];
  List<LostDog> get lostDogs => _lostDogs;

  void addLostDog(LostDog dog) {
    _lostDogs.add(dog);
    notifyListeners();
  }
}

// Add the LostDog model class
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