import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resume Builder',
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          // User is signed in
          return const _PostAuthWrapper();
        } else {
          // User is not signed in
          return const AuthScreen();
        }
      },
    );
  }
}

class _PostAuthWrapper extends StatelessWidget {
  const _PostAuthWrapper();

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    final AuthService authService = AuthService();
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<void>(
      future: authService.ensureUserProfileExists(),
      builder: (context, ensureSnapshot) {
        if (ensureSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (ensureSnapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${ensureSnapshot.error}')),
          );
        }

        return StreamBuilder(
          stream: firestoreService.getUserProfileStream(uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return Scaffold(
                body: Center(child: Text('Error: ${snapshot.error}')),
              );
            }

            if (snapshot.hasData) {
              final userProfile = snapshot.data!;

              // Check if onboarding is complete (has personal details)
              final isOnboardingComplete =
                  userProfile.firstName.isNotEmpty &&
                  userProfile.lastName.isNotEmpty;

              if (!isOnboardingComplete) {
                return const OnboardingScreen();
              } else {
                return const ProfileScreen();
              }
            }

            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        );
      },
    );
  }
}
