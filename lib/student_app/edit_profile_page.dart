import 'package:flutter/material.dart';
import 'package:student_app/student_app/services/student_profile_service.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> initialPersonalData;
  final Map<String, dynamic> initialAcademicData;
  final Map<String, dynamic> initialContactData;

  const EditProfilePage({
    super.key,
    required this.initialPersonalData,
    required this.initialAcademicData,
    required this.initialContactData,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  int _selectedTabIndex = 0;
  bool _isSaving = false;

  final Map<String, TextEditingController> _controllers = {};

  static const Color primaryPurple = Color(0xFF7E3FF2);
  static const Color inputBg = Color(0xFFF3F3F3);

  final List<String> _tabs = [
    "Edit Personal Info",
    "Edit Academic Info",
    "Edit Contact Info",
  ];

  final List<IconData> _tabIcons = [
    Icons.person,
    Icons.school,
    Icons.dashboard_customize,
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Personal
    widget.initialPersonalData.forEach((key, value) {
      _controllers[key] = TextEditingController(text: value?.toString() ?? "");
    });
    // Academic
    widget.initialAcademicData.forEach((key, value) {
      _controllers[key] = TextEditingController(text: value?.toString() ?? "");
    });
    // Contact
    widget.initialContactData.forEach((key, value) {
      _controllers[key] = TextEditingController(text: value?.toString() ?? "");
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);

    Map<String, String> updatedData = {};
    _controllers.forEach((key, controller) {
      updatedData[key] = controller.text;
    });

    try {
      final success = await StudentProfileService.updateProfile(updatedData);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully")),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to update profile")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          _buildTabs(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                   if (_selectedTabIndex == 0) _buildPersonalInfoForm(),
                   if (_selectedTabIndex == 1) _buildAcademicInfoForm(),
                   if (_selectedTabIndex == 2) _buildContactInfoForm(),
                   const SizedBox(height: 30),
                   _buildActionButtons(),
                   const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 25,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: primaryPurple,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            "Edit Profile",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedTabIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedTabIndex = index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? primaryPurple : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? primaryPurple : const Color(0xFFE0E0E0),
                  width: 1,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: primaryPurple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ] : null,
              ),
              child: Row(
                children: [
                  Icon(
                    _tabIcons[index],
                    size: 18,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _tabs[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPersonalInfoForm() {
    return Column(
      children: [
        _buildInputField("First Name", "sfname"),
        _buildInputField("Last Name", "slname"),
        _buildInputField("Father's Name", "fname"),
        _buildInputField("Mother;s Name", "mname"), // Replicating typo from design image
        _buildInputField("Date of Birth", "dob"),
        _buildInputField("Aadhar Number", "aadharno"),
        _buildInputField("Gender", "gender"),
        _buildInputField("Nationality", "nationality"),
        _buildInputField("Caste", "caste"),
        _buildInputField("Religion", "religion"),
        _buildInputField("Subcaste", "subcaste"),
        _buildInputField("Mother Tongue", "mother_tongue"),
      ],
    );
  }

  Widget _buildAcademicInfoForm() {
    return Column(
      children: [
        _buildInputField("10th GPA/Percentage", "tenthgpa"),
        _buildInputField("Religion", "religion"),
        _buildInputField("Last School", "lastschool"),
        _buildInputField("Comments", "comments", isLarge: true),
        _buildInputField("Last School Address", "lastschooladdress"),
        _buildInputField("Branch ID", "branch_id"),
        _buildInputField("Group ID", "group_id"),
        _buildInputField("Batch ID", "batch_id"),
        _buildInputField("Course ID", "course_id"),
      ],
    );
  }

  Widget _buildContactInfoForm() {
    return Column(
      children: [
        _buildInputField("Mandal", "mandal"),
        _buildInputField("Mother's Mobile", "amobile"),
        _buildInputField("Village/Town", "village"),
        _buildInputField("Proctor ID", "proctor_id"),
        _buildInputField("Address", "address"),
        _buildInputField("Proctor Phone", "proctor_phone"),
        _buildInputField("Father's Mobile", "pmobile"),
        _buildInputField("Lsm", "lsm"),
      ],
    );
  }

  Widget _buildInputField(String label, String key, {bool isLarge = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: isLarge ? 100 : 50,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: inputBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
            ),
            child: TextField(
              controller: _controllers[key],
              maxLines: isLarge ? 4 : 1,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: _isSaving ? null : _saveChanges,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFD8B4FE)],
                ),
              ),
              child: Center(
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        "Save Changes",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFC0C0C0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
