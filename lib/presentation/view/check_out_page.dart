import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project_absensi_ppkd_b4/core/app_color.dart';
import 'package:project_absensi_ppkd_b4/presentation/common_widgets/custom_card.dart';
import 'package:project_absensi_ppkd_b4/provider/attendance_provider.dart';
import 'package:provider/provider.dart';

class CheckOutPage extends StatefulWidget {
  const CheckOutPage({super.key});

  @override
  State<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  bool _isLoadingLocation = true;
  Position? _currentPosition;
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

        setState(() {
          _currentPosition = position;
          _currentAddress = address;
          _isLoadingLocation = false;
        });

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
      setState(() {
        _currentAddress = 'Failed to get location: ${e.toString()}';
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _checkOut(BuildContext dialogContext) async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Location not available. Cannot clock out."),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final String attendanceDate = DateFormat(
      'yyyy-MM-dd',
    ).format(now); // Format YYYY-MM-DD
    final String checkOutTime = DateFormat('HH:mm').format(now);

    // 1. Ambil provider
    final provider = context.read<AttendanceProvider>();

    // 2. Panggil fungsi provider
    final bool isSuccess = await provider.handleCheckOut(
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      address: _currentAddress,
      attendanceDate: attendanceDate,
      checkOutTime: checkOutTime,
    );

    if (!mounted) return;

    // 3. Tutup dialog konfirmasi
    Navigator.pop(dialogContext);

    if (isSuccess) {
      // 4. Jika sukses, tutup halaman CheckOutPage
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Check-out successful!"),
          backgroundColor: Colors.green[700],
        ),
      );
    } else {
      // 5. Jika gagal, tampilkan error dari provider
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Check-out Failed: ${provider.checkOutErrorMessage?.replaceAll("Exception: ", "")}',
          ),
          backgroundColor: AppColor.retroDarkRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final String formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(now);
    final String formattedTime = DateFormat('hh:mm:ss a').format(now);

    final attendanceProvider = context.watch<AttendanceProvider>();
    final String clockInTime =
        attendanceProvider.todayStatus?.checkInTime ?? "--:--";

    return Scaffold(
      backgroundColor: AppColor.retroCream,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildTimeCard(formattedDate, formattedTime),
                  const SizedBox(height: 24),
                  _buildLocationCard(),
                  const SizedBox(height: 24),
                  _buildPhotoCard(),
                ],
              ),
            ),
          ),
          _buildStatusBox(clockInTime),
          _buildClockOutButton(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.retroDarkRed,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 16.0,
            bottom: 24.0,
            left: 16.0,
            right: 16.0,
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(
                  children: [
                    Icon(Icons.arrow_back, color: AppColor.retroCream),
                    const SizedBox(width: 8),
                    Text(
                      'Back',
                      style: TextStyle(
                        color: AppColor.retroCream,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Clock Out',
                style: TextStyle(
                  color: AppColor.retroCream,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeCard(String date, String time) {
    return CustomCard(
      child: Column(
        children: [
          Text(
            date,
            style: TextStyle(
              color: AppColor.retroDarkRed,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Divider(color: AppColor.retroMediumRed.withOpacity(0.4), height: 32),
          Text(
            time,
            style: TextStyle(
              color: AppColor.retroMediumRed,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
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
                      markers: _marker == null
                          ? {}
                          : {_marker!}, // Tampilkan marker
                      myLocationEnabled:
                          false, // Matikan titik biru (sudah ada marker)
                      myLocationButtonEnabled: true, // Matikan tombol lokasi
                      zoomControlsEnabled: true, // Izinkan zoom
                    ),
            ),
          ),

          // -----------------------------------
          const SizedBox(height: 16),
          // Tampilkan alamat di bawah peta
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

  Widget _buildPhotoCard() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.camera_alt_outlined, color: AppColor.retroDarkRed),
              const SizedBox(width: 8),
              Text(
                'Photo Verification',
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
            height: 150,
            decoration: BoxDecoration(
              color: AppColor.retroCream.withOpacity(0.5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_enhance_outlined,
                    size: 40,
                    color: AppColor.retroMediumRed,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to capture photo',
                    style: TextStyle(
                      color: AppColor.retroMediumRed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBox(String clockInTime) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[700]!, width: 2),
      ),
      child: Column(
        children: [
          Text(
            'You are currently clocked in',
            style: TextStyle(
              color: Colors.green[800],
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Started at $clockInTime',
            style: TextStyle(
              color: Colors.green[700],
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClockOutButton() {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, child) {
        final bool isApiLoading = provider.isCheckingOut;
        final bool isButtonDisabled =
            _isLoadingLocation || _currentPosition == null || isApiLoading;

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          color: AppColor.retroCream,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.check_circle_outline),
            label: Text(
              'Clock Out Now',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isButtonDisabled
                  ? Colors.grey[400]
                  : AppColor.retroDarkRed,
              foregroundColor: AppColor.retroCream,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: isButtonDisabled
                ? null
                : () {
                    _showClockOutConfirmationDialog(context);
                  },
          ),
        );
      },
    );
  }

  void _showClockOutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: !context.read<AttendanceProvider>().isCheckingOut,
      builder: (BuildContext dialogContext) {
        return Consumer<AttendanceProvider>(
          builder: (context, provider, child) {
            final bool isApiLoading = provider.isCheckingOut;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.transparent,
              child: CustomCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Confirm Clock Out',
                      style: TextStyle(
                        color: AppColor.retroDarkRed,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Are you sure you want to clock out? Your work time will be recorded.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColor.retroMediumRed,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.retroDarkRed,
                        foregroundColor: AppColor.retroCream,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isApiLoading
                          ? null
                          : () async {
                              await _checkOut(dialogContext);
                            },
                      child: isApiLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColor.retroCream,
                                ),
                              ),
                            )
                          : const Text(
                              'Confirm',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.kBackgroundColor,
                        foregroundColor: AppColor.retroDarkRed,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: AppColor.retroDarkRed,
                            width: 2,
                          ),
                        ),
                        elevation: 0,
                      ),
                      onPressed: isApiLoading
                          ? null
                          : () {
                              Navigator.pop(dialogContext);
                            },
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
