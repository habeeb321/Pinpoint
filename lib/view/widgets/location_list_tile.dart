import 'package:Pinpoint/model/location_model.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geocoding/geocoding.dart';

class LocationListTile extends StatelessWidget {
  final LocationModel location;
  final VoidCallback onDelete;

  const LocationListTile({
    super.key,
    required this.location,
    required this.onDelete,
  });

  Future<String> _getLocationAddress() async {
    try {
      final placemarks = await placemarkFromCoordinates(
        location.lat,
        location.long,
      );

      if (placemarks.isEmpty) return 'Address not found';

      final place = placemarks.first;
      List<String> addressComponents = [];

      // Add subLocality (neighborhood/area)
      if (place.subLocality != null && place.subLocality!.isNotEmpty) {
        addressComponents.add(place.subLocality!);
      }

      // Add locality (city)
      if (place.locality != null && place.locality!.isNotEmpty) {
        addressComponents.add(place.locality!);
      }

      // Add subAdministrativeArea (district)
      if (place.subAdministrativeArea != null &&
          place.subAdministrativeArea!.isNotEmpty) {
        addressComponents.add(place.subAdministrativeArea!);
      }

      // Add administrativeArea (state)
      if (place.administrativeArea != null &&
          place.administrativeArea!.isNotEmpty) {
        addressComponents.add(place.administrativeArea!);
      }

      // Add postalCode
      if (place.postalCode != null && place.postalCode!.isNotEmpty) {
        addressComponents.add(place.postalCode!);
      }

      // Join all components with commas
      String address = addressComponents.join(', ');

      return address.isEmpty ? 'Address not found' : address;
    } catch (e) {
      return 'Unable to fetch address';
    }
  }

  void _openInMaps() {
    launchUrl(Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${location.lat},${location.long}'));
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(location.name),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: const Color(0xFFDC3545),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      onDismissed: (_) => onDelete(),
      child: InkWell(
        onTap: _openInMaps,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D6EFD).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF0D6EFD),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF212529),
                        ),
                      ),
                      const SizedBox(height: 4),
                      FutureBuilder<String>(
                        future: _getLocationAddress(),
                        builder: (context, snapshot) {
                          return Row(
                            children: [
                              Icon(
                                Icons.place_outlined,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  snapshot.data ?? 'Loading address...',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.my_location,
                              size: 12,
                              color: Colors.grey.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${location.lat.toStringAsFixed(4)}, ${location.long.toStringAsFixed(4)}',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
