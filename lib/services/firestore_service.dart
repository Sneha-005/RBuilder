import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user profile
  Future<UserProfile> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
      }
      throw 'User profile not found';
    } catch (e) {
      throw 'Failed to get user profile: $e';
    }
  }

  // Stream of user profile
  Stream<UserProfile> getUserProfileStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
      }
      throw 'User profile not found';
    });
  }

  // Update personal details
  Future<void> updatePersonalDetails(
    String uid,
    String firstName,
    String lastName,
    String phoneNumber,
    String bio,
  ) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'bio': bio,
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw 'Failed to update personal details: $e';
    }
  }

  // Update skills
  Future<void> updateSkills(String uid, List<String> skills) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'skills': skills,
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw 'Failed to update skills: $e';
    }
  }

  // Add or update experience
  Future<void> addExperience(String uid, Experience experience) async {
    try {
      final experiences = [];
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        experiences.addAll(data['experiences'] ?? []);
      }

      if (experience.id != null) {
        // Update existing
        final index = int.tryParse(experience.id!) ?? -1;
        if (index >= 0 && index < experiences.length) {
          experiences[index] = experience.toMap();
        }
      } else {
        // Add new
        experiences.add(experience.toMap());
      }

      await _firestore.collection('users').doc(uid).set({
        'experiences': experiences,
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw 'Failed to add experience: $e';
    }
  }

  // Delete experience
  Future<void> deleteExperience(String uid, int index) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final experiences = List.from(data['experiences'] ?? []);

        if (index >= 0 && index < experiences.length) {
          experiences.removeAt(index);
        }

        await _firestore.collection('users').doc(uid).set({
          'experiences': experiences,
          'updatedAt': Timestamp.now(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      throw 'Failed to delete experience: $e';
    }
  }

  // Add or update education
  Future<void> addEducation(String uid, Education education) async {
    try {
      final educations = [];
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        educations.addAll(data['educations'] ?? []);
      }

      if (education.id != null) {
        // Update existing
        final index = int.tryParse(education.id!) ?? -1;
        if (index >= 0 && index < educations.length) {
          educations[index] = education.toMap();
        }
      } else {
        // Add new
        educations.add(education.toMap());
      }

      await _firestore.collection('users').doc(uid).set({
        'educations': educations,
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw 'Failed to add education: $e';
    }
  }

  // Delete education
  Future<void> deleteEducation(String uid, int index) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final educations = List.from(data['educations'] ?? []);

        if (index >= 0 && index < educations.length) {
          educations.removeAt(index);
        }

        await _firestore.collection('users').doc(uid).set({
          'educations': educations,
          'updatedAt': Timestamp.now(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      throw 'Failed to delete education: $e';
    }
  }

  // Update interests
  Future<void> updateInterests(String uid, List<String> interests) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'interests': interests,
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw 'Failed to update interests: $e';
    }
  }
}
