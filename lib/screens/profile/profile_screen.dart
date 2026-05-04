import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/models.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/profile_avatar.dart';

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
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (context) {
              return [
                PopupMenuItem<String>(
                  value: 'edit',
                  child: const Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 20),
                      SizedBox(width: 10),
                      Text('Edit Profile'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: const Row(
                    children: [
                      Icon(Icons.logout_outlined, size: 20, color: Colors.red),
                      SizedBox(width: 10),
                      Text('Sign Out', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ];
            },
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.of(context).pushNamed('/edit-profile');
              } else if (value == 'logout') {
                _handleSignOut();
              }
            },
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Profile not found'));
          }

          final profile = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with Avatar
                Container(
                  decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ProfileAvatar(
                        firstName: profile.firstName,
                        lastName: profile.lastName,
                        size: 100,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profile.fullName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      if (profile.phoneNumber.isNotEmpty &&
                          profile.phoneNumber != 'Not provided') ...[
                        const SizedBox(height: 4),
                        Text(
                          profile.phoneNumber,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Bio Section
                if (profile.bio.isNotEmpty &&
                    profile.bio != 'Welcome to my profile') ...[
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      profile.bio,
                      style: const TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ),
                ],
                // Skills Section
                if (profile.skills.isNotEmpty)
                  _buildSkillsSection(context, profile.skills),
                // Experience Section
                if (profile.experiences.isNotEmpty)
                  _buildExperienceSection(context, profile.experiences),
                // Education Section
                if (profile.educations.isNotEmpty)
                  _buildEducationSection(context, profile.educations),
                // Interests Section
                if (profile.interests.isNotEmpty)
                  _buildInterestsSection(context, profile.interests),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkillsSection(BuildContext context, List<String> skills) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_outlined, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text('Skills', style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                skills
                    .where((skill) => skill != 'Communication')
                    .map(
                      (skill) => Chip(
                        label: Text(skill),
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        labelStyle: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceSection(
    BuildContext context,
    List<Experience> experiences,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.work_outline, color: AppTheme.secondaryColor),
              const SizedBox(width: 8),
              Text(
                'Experience',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...experiences
              .map(
                (exp) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exp.role,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          exp.company,
                          style: const TextStyle(
                            color: AppTheme.secondaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (exp.startDate.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            '${exp.startDate} - ${exp.endDate.isEmpty ? 'Present' : exp.endDate}',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                        if (exp.description.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            exp.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildEducationSection(
    BuildContext context,
    List<Education> educations,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school_outlined, color: AppTheme.accentColor),
              const SizedBox(width: 8),
              Text(
                'Education',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...educations
              .map(
                (edu) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          edu.degree,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          edu.school,
                          style: const TextStyle(
                            color: AppTheme.accentColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          edu.fieldOfStudy,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (edu.startYear.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            '${edu.startYear} - ${edu.endYear.isEmpty ? 'Present' : edu.endYear}',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildInterestsSection(BuildContext context, List<String> interests) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite_outline, color: AppTheme.warningColor),
              const SizedBox(width: 8),
              Text(
                'Interests & Goals',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                interests
                    .where((interest) => interest != 'Learning')
                    .map(
                      (interest) => Chip(
                        label: Text(interest),
                        backgroundColor: AppTheme.warningColor.withOpacity(0.1),
                        labelStyle: const TextStyle(
                          color: AppTheme.warningColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Sign out failed: $e')));
        }
      }
    }
  }
}
