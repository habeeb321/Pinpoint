import 'package:Pinpoint/model/location_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class FirebaseStorageService {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  // Save location to Realtime Database
  Future<void> uploadLocationToFirebase({
    required String name,
    required double lat,
    required double long,
  }) async {
    await _databaseRef.child('locations').push().set({
      'name': name,
      'lat': lat,
      'long': long,
    });
  }

  // Fetch locations from Realtime Database
  Future<List<LocationModel>> fetchLocationsFromFirebase() async {
    try {
      final snapshot = await _databaseRef.child('locations').get();
      if (snapshot.exists) {
        final Map<dynamic, dynamic> data =
            snapshot.value as Map<dynamic, dynamic>;
        return data.entries.map((entry) {
          return LocationModel(
            id: entry.key,
            name: entry.value['name'],
            lat: entry.value['lat'],
            long: entry.value['long'],
          );
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching locations: $e');
      return [];
    }
  }

  // Delete location from Realtime Database
  Future<void> deleteLocationFromFirebase(LocationModel location) async {
    await _databaseRef.child('locations/${location.id}').remove();
  }
}
