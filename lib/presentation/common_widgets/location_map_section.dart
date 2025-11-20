import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project_absensi_ppkd_b4/core/constant/app_color.dart';
import 'package:project_absensi_ppkd_b4/presentation/common_widgets/custom_card.dart';
import 'package:project_absensi_ppkd_b4/provider/attendance_provider.dart';
import 'package:provider/provider.dart';

class LocationMapSection extends StatefulWidget {
  const LocationMapSection({super.key});

  @override
  State<LocationMapSection> createState() => _LocationMapSectionState();
}

class _LocationMapSectionState extends State<LocationMapSection> {
  bool _isLoadingLocation = true;
  String _currentAddress = "Fetching location...";
  final Completer<GoogleMapController> _mapController = Completer();
  Marker? _marker;
  static const LatLng _kDefaultPosition = LatLng(-6.1753924, 106.8271528);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _currentAddress = "Fetching location...";
    });

    try {
      var status = await Permission.locationWhenInUse.request();
      if (status.isGranted) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        final LatLng latLng = LatLng(position.latitude, position.longitude);
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        String address = "Alamat tidak ditemukan";
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          address = "${place.street}, ${place.subLocality}, ${place.locality}";
        }

        _marker = Marker(
          markerId: const MarkerId("lokasi_saya"),
          position: latLng,
          infoWindow: InfoWindow(title: 'Lokasi Anda', snippet: address),
        );

        // Update state lokal
        if (mounted) {
          setState(() {
            _currentAddress = address;
            _isLoadingLocation = false;
          });

          // PENTING: Kirim data ke Provider agar tombol CheckIn bisa baca
          context.read<AttendanceProvider>().setLocationData(position, address);
        }

        final GoogleMapController controller = await _mapController.future;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: latLng, zoom: 16),
          ),
        );
      } else {
        throw Exception('Location permission denied');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentAddress = 'Failed to get location: ${e.toString()}';
          _isLoadingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: AppColor.retroDarkRed),
              const SizedBox(width: 8),
              Text(
                'Current Location',
                style: TextStyle(
                  color: AppColor.retroDarkRed,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: AppColor.retroCream.withOpacity(0.5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: _isLoadingLocation
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColor.retroDarkRed,
                      ),
                    )
                  : GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(
                        target: _kDefaultPosition,
                        zoom: 14,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        if (!_mapController.isCompleted) {
                          _mapController.complete(controller);
                        }
                      },
                      markers: _marker == null ? {} : {_marker!},
                      myLocationEnabled: false,
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: true,
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isLoadingLocation ? "Fetching location..." : _currentAddress,
            style: TextStyle(
              color: AppColor.retroMediumRed,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
