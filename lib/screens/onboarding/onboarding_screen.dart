import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _currentStep = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Step 1: Personal Details
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  // Step 2: Skills
  final _skillController = TextEditingController();
  List<String> _skills = [];

  // Step 3: Experience
  final _roleController = TextEditingController();
  final _companyController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<Experience> _experiences = [];

  // Step 4: Education
  final _schoolController = TextEditingController();
  final _degreeController = TextEditingController();
  final _fieldOfStudyController = TextEditingController();
  final _startYearController = TextEditingController();
  final _endYearController = TextEditingController();
  List<Education> _educations = [];

  // Step 5: Interests
  final _interestController = TextEditingController();
  List<String> _interests = [];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _skillController.dispose();
    _roleController.dispose();
    _companyController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _descriptionController.dispose();
    _schoolController.dispose();
    _degreeController.dispose();
    _fieldOfStudyController.dispose();
    _startYearController.dispose();
    _endYearController.dispose();
    _interestController.dispose();
    super.dispose();
  }

  Future<void> _submitOnboarding() async {
    if (_firstNameController.text.isEmpty || _lastNameController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in required fields';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final uid = _auth.currentUser!.uid;
      await _firestoreService.updatePersonalDetails(
        uid,
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _phoneController.text.trim(),
        _bioController.text.trim(),
      );

      if (_skills.isNotEmpty) {
        await _firestoreService.updateSkills(uid, _skills);
      }

      for (var experience in _experiences) {
        await _firestoreService.addExperience(uid, experience);
      }

      for (var education in _educations) {
        await _firestoreService.addEducation(uid, education);
      }

      if (_interests.isNotEmpty) {
        await _firestoreService.updateInterests(uid, _interests);
      }

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/profile');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _addSkill() {
    if (_skillController.text.isNotEmpty && !_skills.contains(_skillController.text.trim())) {
      setState(() {
        _skills.add(_skillController.text.trim());
        _skillController.clear();
      });
    }
  }

  void _removeSkill(int index) {
    setState(() {
      _skills.removeAt(index);
    });
  }

  void _addExperience() {
    if (_roleController.text.isEmpty || _companyController.text.isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    final experience = Experience(
      role: _roleController.text.trim(),
      company: _companyController.text.trim(),
      startDate: _startDateController.text.trim(),
      endDate: _endDateController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    setState(() {
      _experiences.add(experience);
      _roleController.clear();
      _companyController.clear();
      _startDateController.clear();
      _endDateController.clear();
      _descriptionController.clear();
    });
  }

  void _removeExperience(int index) {
    setState(() {
      _experiences.removeAt(index);
    });
  }

  void _addEducation() {
    if (_schoolController.text.isEmpty ||
        _degreeController.text.isEmpty ||
        _fieldOfStudyController.text.isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    final education = Education(
      school: _schoolController.text.trim(),
      degree: _degreeController.text.trim(),
      fieldOfStudy: _fieldOfStudyController.text.trim(),
      startYear: _startYearController.text.trim(),
      endYear: _endYearController.text.trim(),
    );

    setState(() {
      _educations.add(education);
      _schoolController.clear();
      _degreeController.clear();
      _fieldOfStudyController.clear();
      _startYearController.clear();
      _endYearController.clear();
    });
  }

  void _removeEducation(int index) {
    setState(() {
      _educations.removeAt(index);
    });
  }

  void _addInterest() {
    if (_interestController.text.isNotEmpty &&
        !_interests.contains(_interestController.text.trim())) {
      setState(() {
        _interests.add(_interestController.text.trim());
        _interestController.clear();
      });
    }
  }

  void _removeInterest(int index) {
    setState(() {
      _interests.removeAt(index);
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
        _errorMessage = null;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _errorMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    5,
                    (index) => Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index <= _currentStep
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300],
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: index <= _currentStep ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Personal', style: TextStyle(fontSize: 12)),
                    Text('Skills', style: TextStyle(fontSize: 12)),
                    Text('Experience', style: TextStyle(fontSize: 12)),
                    Text('Education', style: TextStyle(fontSize: 12)),
                    Text('Interests', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  const SizedBox(height: 20),
                  _buildCurrentStep(),
                ],
              ),
            ),
          ),
          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: _currentStep > 0 ? _previousStep : null,
                  child: const Text('Back'),
                ),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (_currentStep == 4 ? _submitOnboarding : _nextStep),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_currentStep == 4 ? 'Complete' : 'Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalDetailsStep();
      case 1:
        return _buildSkillsStep();
      case 2:
        return _buildExperienceStep();
      case 3:
        return _buildEducationStep();
      case 4:
        return _buildInterestsStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPersonalDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Details',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _firstNameController,
          decoration: InputDecoration(
            labelText: 'First Name *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _lastNameController,
          decoration: InputDecoration(
            labelText: 'Last Name *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _bioController,
          decoration: InputDecoration(
            labelText: 'Bio',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            hintText: 'Tell us about yourself',
          ),
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildSkillsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _skillController,
                decoration: InputDecoration(
                  labelText: 'Add a skill',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addSkill,
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_skills.isEmpty)
          Text(
            'No skills added yet',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ..._skills.asMap().entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.value),
                  GestureDetector(
                    onTap: () => _removeSkill(e.key),
                    child: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildExperienceStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Work Experience',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _roleController,
          decoration: InputDecoration(
            labelText: 'Job Title',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _companyController,
          decoration: InputDecoration(
            labelText: 'Company',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _startDateController,
                decoration: InputDecoration(
                  labelText: 'Start Date',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1990),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _startDateController.text =
                          '${date.day}/${date.month}/${date.year}';
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _endDateController,
                decoration: InputDecoration(
                  labelText: 'End Date',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1990),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 50)),
                  );
                  if (date != null) {
                    setState(() {
                      _endDateController.text = '${date.day}/${date.month}/${date.year}';
                    });
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _addExperience,
          child: const Text('Add Experience'),
        ),
        const SizedBox(height: 16),
        if (_experiences.isEmpty)
          Text(
            'No experience added yet',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ..._experiences.asMap().entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          e.value.role,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _removeExperience(e.key),
                        child: const Icon(Icons.delete, size: 20, color: Colors.red),
                      ),
                    ],
                  ),
                  Text(e.value.company, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEducationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Education',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _schoolController,
          decoration: InputDecoration(
            labelText: 'School/University',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _degreeController,
          decoration: InputDecoration(
            labelText: 'Degree',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _fieldOfStudyController,
          decoration: InputDecoration(
            labelText: 'Field of Study',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _startYearController,
                decoration: InputDecoration(
                  labelText: 'Start Year',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _endYearController,
                decoration: InputDecoration(
                  labelText: 'End Year',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _addEducation,
          child: const Text('Add Education'),
        ),
        const SizedBox(height: 16),
        if (_educations.isEmpty)
          Text(
            'No education added yet',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ..._educations.asMap().entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          e.value.degree,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _removeEducation(e.key),
                        child: const Icon(Icons.delete, size: 20, color: Colors.red),
                      ),
                    ],
                  ),
                  Text(e.value.school, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildInterestsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interests & Goals',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _interestController,
                decoration: InputDecoration(
                  labelText: 'Add an interest',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addInterest,
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_interests.isEmpty)
          Text(
            'No interests added yet',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ..._interests.asMap().entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.value),
                  GestureDetector(
                    onTap: () => _removeInterest(e.key),
                    child: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
