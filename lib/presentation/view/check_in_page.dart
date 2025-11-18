import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project_absensi_ppkd_b4/core/app_color.dart';
import 'package:project_absensi_ppkd_b4/provider/attendance_provider.dart';

import 'package:provider/provider.dart';
import 'package:project_absensi_ppkd_b4/presentation/common_widgets/custom_card.dart';

class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key});

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  bool _isLoadingLocation = true;
  Position? _currentPosition;
  String _currentAddress = "Fetching location...";

  // --- HAPUS ApiService _apiService ---
  // --- HAPUS _isLoadingApiCall (Pindah ke Provider) ---

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Fungsi ini tetap sama, karena ini adalah logic UI (mengambil GPS)
  // Ini tidak perlu dipindah ke provider.
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

        // TODO: Ganti ini dengan package geocoding untuk alamat asli
        // List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        // String address = placemarks.first.street ?? "Unknown location";

        setState(() {
          _currentPosition = position;
          _currentAddress = "Office Building, Main Street (Simulated)";
          _isLoadingLocation = false;
        });
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

  // --- FUNGSI CHECK IN DIPERBARUI ---
  // Sekarang memanggil provider dan menangani hasil
  Future<void> _checkIn(BuildContext dialogContext) async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Location not available. Cannot clock in."),
        ),
      );
      return;
    }

    // 1. Ambil provider (gunakan 'read' di dalam fungsi)
    final provider = context.read<AttendanceProvider>();

    // 2. Panggil fungsi provider
    final bool isSuccess = await provider.handleCheckIn(
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      address: _currentAddress,
    );

    if (!mounted) return;

    // 3. Tutup dialog konfirmasi
    Navigator.pop(dialogContext);

    if (isSuccess) {
      // 4. Jika sukses, tutup halaman CheckInPage
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Check-in successful!"),
          backgroundColor: Colors.green[700],
        ),
      );
    } else {
      // 5. Jika gagal, tampilkan error dari provider
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Check-in Failed: ${provider.checkInErrorMessage?.replaceAll("Exception: ", "")}',
          ),
          backgroundColor: AppColor.retroDarkRed,
        ),
      );
    }
  }
  // ---------------------------------

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final String formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(now);
    final String formattedTime = DateFormat('hh:mm:ss a').format(now);

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
          _buildClockInButton(), // Tombol ini sekarang 'menonton' provider
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // ... (Tidak ada perubahan di _buildHeader)
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
                onTap: () {
                  Navigator.pop(context);
                },
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
                'Clock In',
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

  // --- MENGGUNAKAN CustomCard BARU ---
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

  // --- MENGGUNAKAN CustomCard BARU ---
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
            height: 150,
            decoration: BoxDecoration(
              color: AppColor.retroCream.withOpacity(0.5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: _isLoadingLocation
                  ? const CircularProgressIndicator(
                      color: AppColor.retroDarkRed,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 40,
                          color: AppColor.retroMediumRed,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Map View Placeholder',
                          style: TextStyle(color: AppColor.retroMediumRed),
                        ),
                        Text(
                          _currentAddress,
                          style: TextStyle(
                            color: AppColor.retroMediumRed,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // --- MENGGUNAKAN CustomCard BARU ---
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

  // --- MENGGUNAKAN Consumer UNTUK LOADING STATE ---
  Widget _buildClockInButton() {
    // "Tonton" provider untuk mendapatkan status loading
    return Consumer<AttendanceProvider>(
      builder: (context, provider, child) {
        final bool isApiLoading = provider.isCheckingIn;
        final bool isButtonDisabled =
            _isLoadingLocation || _currentPosition == null || isApiLoading;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          color: AppColor.retroCream,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.check_circle_outline),
            label: Text(
              'Clock In Now',
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
                    _showConfirmationDialog(context);
                  },
          ),
        );
      },
    );
  }

  // --- MENGGUNAKAN Consumer UNTUK LOADING STATE DI DIALOG ---
  void _showConfirmationDialog(BuildContext context) {
    final String confirmTime = DateFormat('hh:mm:ss a').format(DateTime.now());

    showDialog(
      context: context,
      // Gunakan 'watch' di sini agar loading state tidak mengizinkan dismiss
      barrierDismissible: !context.read<AttendanceProvider>().isCheckingIn,
      builder: (BuildContext dialogContext) {
        // Gunakan Consumer agar tombol di dalam dialog bisa update
        return Consumer<AttendanceProvider>(
          builder: (context, provider, child) {
            final bool isApiLoading = provider.isCheckingIn;

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
                      'Confirm Clock In',
                      style: TextStyle(
                        color: AppColor.retroDarkRed,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Are you sure you want to clock in at $confirmTime?',
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
                              // Panggil _checkIn dan kirim context dialog
                              await _checkIn(dialogContext);
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
