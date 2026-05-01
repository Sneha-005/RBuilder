import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/models.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Edit Profile'),
                onTap: () => Navigator.of(context).pushNamed('/edit-profile'),
              ),
              PopupMenuItem(
                child: const Text('Sign Out'),
                onTap: () => _handleSignOut(),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<UserProfile>(
        stream: _firestoreService.getUserProfileStream(_auth.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Profile not found'));
          }

          final profile = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with name and bio
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.fullName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        profile.email,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      if (profile.phoneNumber.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          profile.phoneNumber,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                      if (profile.bio.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(profile.bio),
                      ],
                    ],
                  ),
                ),
                // Skills Section
                if (profile.skills.isNotEmpty) _buildSection(
                  context,
                  'Skills',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: profile.skills
                        .map(
                          (skill) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(skill),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                // Experience Section
                if (profile.experiences.isNotEmpty) _buildSection(
                  context,
                  'Experience',
                  Column(
                    children: profile.experiences
                        .asMap()
                        .entries
                        .map((e) => _buildExperienceCard(e.value))
                        .toList(),
                  ),
                ),
                // Education Section
                if (profile.educations.isNotEmpty) _buildSection(
                  context,
                  'Education',
                  Column(
                    children: profile.educations
                        .asMap()
                        .entries
                        .map((e) => _buildEducationCard(e.value))
                        .toList(),
                  ),
                ),
                // Interests Section
                if (profile.interests.isNotEmpty) _buildSection(
                  context,
                  'Interests & Goals',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: profile.interests
                        .map(
                          (interest) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(interest),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ],
    );
  }

  Widget _buildExperienceCard(Experience experience) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            experience.role,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            experience.company,
            style: TextStyle(color: Colors.grey[600]),
          ),
          if (experience.startDate.isNotEmpty || experience.endDate.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '${experience.startDate} - ${experience.endDate}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
          if (experience.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(experience.description),
          ],
        ],
      ),
    );
  }

  Widget _buildEducationCard(Education education) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            education.degree,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            education.school,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            education.fieldOfStudy,
            style: TextStyle(color: Colors.grey[600]),
          ),
          if (education.startYear.isNotEmpty || education.endYear.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '${education.startYear} - ${education.endYear}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleSignOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldSignOut ?? false) {
      try {
        await _authService.signOut();
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/auth');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign out failed: $e')),
          );
        }
      }
    }
  }
}
