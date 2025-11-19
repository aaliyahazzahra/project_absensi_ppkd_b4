import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/presentation/view/auth/login_page.dart';
import 'package:project_absensi_ppkd_b4/presentation/view/main_page.dart';
import 'package:project_absensi_ppkd_b4/presentation/view/splash_screen.dart';
import 'package:project_absensi_ppkd_b4/provider/attendance_provider.dart';
import 'package:project_absensi_ppkd_b4/provider/auth_provider.dart';
import 'package:project_absensi_ppkd_b4/provider/dropdown_provider.dart';
import 'package:project_absensi_ppkd_b4/provider/profile_provider.dart';
import 'package:project_absensi_ppkd_b4/repositories/attendance_repository.dart';
import 'package:project_absensi_ppkd_b4/repositories/auth_repository.dart';
import 'package:project_absensi_ppkd_b4/repositories/dropdown_repository.dart';
import 'package:project_absensi_ppkd_b4/repositories/profile_repository.dart';
import 'package:project_absensi_ppkd_b4/service/api_service.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),

        ProxyProvider<ApiService, AuthRepository>(
          update: (_, apiService, __) => AuthRepository(apiService: apiService),
        ),
        ProxyProvider<ApiService, ProfileRepository>(
          update: (_, apiService, __) =>
              ProfileRepository(apiService: apiService),
        ),
        ProxyProvider<ApiService, DropdownRepository>(
          update: (_, apiService, __) =>
              DropdownRepository(apiService: apiService),
        ),
        ProxyProvider<ApiService, AttendanceRepository>(
          update: (_, apiService, __) =>
              AttendanceRepository(apiService: apiService),
        ),

        ChangeNotifierProxyProvider<AuthRepository, AuthProvider>(
          create: (context) => AuthProvider(),
          update: (context, repository, previousProvider) {
            previousProvider!.updateRepository(repository);
            return previousProvider;
          },
        ),
        ChangeNotifierProxyProvider<ProfileRepository, ProfileProvider>(
          create: (context) => ProfileProvider(),
          update: (context, repository, previousProvider) {
            previousProvider!.updateRepository(repository);
            return previousProvider;
          },
        ),
        ChangeNotifierProxyProvider<DropdownRepository, DropdownProvider>(
          create: (context) => DropdownProvider(),
          update: (context, repository, previous) {
            previous!.updateRepository(repository);
            return previous;
          },
        ),
        ChangeNotifierProxyProvider<AttendanceRepository, AttendanceProvider>(
          create: (context) => AttendanceProvider(),
          update: (context, repository, previous) {
            previous!.updateRepository(repository);
            return previous;
          },
        ),
      ],

      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),

        initialRoute: '/',

        routes: {
          '/': (context) => const SplashScreen(), // Rute awal
          '/login': (context) => const LoginPage(), // Jika belum login
          '/home': (context) => const MainPage(), // Jika sudah login
        },
      ),
    );
  }
}
