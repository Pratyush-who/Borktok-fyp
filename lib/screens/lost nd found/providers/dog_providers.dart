// providers/dog_providers.dart
import 'package:flutter/material.dart';
import 'dart:io';

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

class FoundDog {
  final String description;
  final String finderName;
  final String finderPhone;
  final String location;
  final double latitude;
  final double longitude;
  final File? image;
  final DateTime foundTime;
  bool isReunited;

  FoundDog({
    required this.description,
    required this.finderName,
    required this.finderPhone,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.image,
    required this.foundTime,
    this.isReunited = false,
  });
}

class LostDogsProvider with ChangeNotifier {
  final List<LostDog> _lostDogs = [];
  List<LostDog> get lostDogs => _lostDogs;

  void addLostDog(LostDog dog) {
    _lostDogs.add(dog);
    notifyListeners();
  }

  void removeLostDog(LostDog dog) {
    _lostDogs.remove(dog);
    notifyListeners();
  }
}

class FoundDogsProvider with ChangeNotifier {
  final List<FoundDog> _foundDogs = [];
  List<FoundDog> get foundDogs => _foundDogs;

  void addFoundDog(FoundDog dog) {
    _foundDogs.add(dog);
    notifyListeners();
  }

  void markAsReunited(FoundDog dog) {
    final index = _foundDogs.indexOf(dog);
    if (index != -1) {
      _foundDogs[index].isReunited = true;
      notifyListeners();
    }
  }
}