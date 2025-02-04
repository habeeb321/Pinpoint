import 'package:Pinpoint/firebase_storage_service/firebase_stoarage_service.dart';
import 'package:Pinpoint/model/location_model.dart';
import 'package:Pinpoint/view/widgets/location_name_dialogue.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LocationController extends GetxController {
  final RxList<LocationModel> locations = <LocationModel>[].obs;
  final _firebaseService = FirebaseStorageService();
  final RxString searchQuery = RxString('');

  @override
  void onInit() {
    super.onInit();
    _loadLocations();
  }

  void deleteLocation(int index) async {
    final location = locations[index];
    try {
      await _firebaseService.deleteLocationFromFirebase(location);
      locations.removeAt(index);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error deleting location: ${e.toString()}');
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  List<LocationModel> get filteredLocations {
    if (searchQuery.value.isEmpty) {
      return locations;
    }

    return locations.where((location) {
      final lowercaseQuery = searchQuery.value.toLowerCase();
      return location.name.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  Future<void> _loadLocations() async {
    try {
      final fetchedLocations =
          await _firebaseService.fetchLocationsFromFirebase();
      locations.assignAll(fetchedLocations);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error fetching locations: ${e.toString()}');
    }
  }

  Future<void> saveLocation(String name, double lat, double long) async {
    try {
      await _firebaseService.uploadLocationToFirebase(
        name: name,
        lat: lat,
        long: long,
      );
      await _loadLocations();
    } catch (e) {
      debugPrint('Error saving location: $e');
    }
  }

  Future<void> getCurrentLocation() async {
    if (!await _checkLocationPermissions()) return;

    Get.dialog(
      LocationNameDialog(
        onSave: (name) async {
          try {
            final position = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.high,
              ),
            );
            saveLocation(name, position.latitude, position.longitude);
          } catch (e) {
            Fluttertoast.showToast(
                msg: 'Error fetching location: ${e.toString()}');
          }
        },
      ),
    );
  }

  Future<bool> _checkLocationPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: 'Enable location services');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(msg: 'Permissions permanently denied');
      return false;
    }
    return true;
  }
}
