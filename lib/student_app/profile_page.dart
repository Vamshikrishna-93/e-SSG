import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:student_app/student_app/model/student_profile.dart';
import 'package:student_app/student_app/services/student_profile_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:student_app/student_app/change_password_page.dart';
import 'package:student_app/student_app/edit_profile_page.dart';
import 'package:student_app/student_app/widgets/loading_animation.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  StudentProfile? _profile;

  // Mutable Data Lists
  List<Map<String, dynamic>> _personalData = [
    {"label": "First Name", "value": "N/A", "key": "sfname", "required": true},
    {"label": "Last Name", "value": "N/A", "key": "slname", "required": true},
    {
      "label": "Father's Name",
      "value": "N/A",
      "key": "fname",
      "required": true,
    },
    {
      "label": "Mother;s Name", // Replicated exact typo from the design image
      "value": "N/A",
      "key": "mname",
      "required": true,
    },
    {"label": "Date of Birth", "value": "N/A", "key": "dob"},
    {"label": "Aadhar Number", "value": "N/A", "key": "aadharno"},
    {"label": "Gender", "value": "N/A", "key": "gender"},
    {"label": "Nationality", "value": "N/A", "key": "nationality"},
    {"label": "Caste", "value": "N/A", "key": "caste"},
    {"label": "Religion", "value": "N/A", "key": "religion"},
    {"label": "Subcaste", "value": "N/A", "key": "subcaste"},
    {"label": "Mother Tongue", "value": "N/A", "key": "mother_tongue"},
  ];

  List<Map<String, dynamic>> _contactData = [
    {"label": "Mandal", "value": "N/A", "key": "mandal"},
    {"label": "Mother's Mobile", "value": "N/A", "key": "amobile"},
    {"label": "Village/Town", "value": "N/A", "key": "village"},
    {"label": "Proctor ID", "value": "N/A", "key": "proctor_id"},
    {"label": "Address", "value": "N/A", "key": "address"},
    {"label": "Proctor Phone", "value": "N/A", "key": "proctor_phone"},
    {
      "label": "Father's Mobile",
      "value": "N/A",
      "key": "pmobile",
      "required": true,
    },
    {"label": "Lsm", "value": "N/A", "key": "lsm"},
  ];

  List<Map<String, dynamic>> _academicData = [
    {"label": "10th GPA/Percentage", "value": "N/A", "key": "gpa"},
    {"label": "Religion", "value": "N/A", "key": "religion_academic"},
    {"label": "Last School", "value": "N/A", "key": "lastschool"},
    {"label": "Comments", "value": "", "key": "comments", "isLarge": true},
    {
      "label": "Last School Address",
      "value": "N/A",
      "key": "lastschooladdress",
    },
    {"label": "Branch ID", "value": "N/A", "key": "branch_id"},
    {"label": "Group ID", "value": "N/A", "key": "group_id"},
    {"label": "Batch ID", "value": "N/A", "key": "batch_id"},
    {"label": "Course ID", "value": "N/A", "key": "course_id"},
  ];

  List<Map<String, dynamic>> _admissionData = [
    {"label": "Admission No", "value": "N/A"},
    {"label": "Committed Fee", "value": "₹0"},
    {"label": "Application No", "value": "N/A"},
    {
      "label": "Fee Status",
      "value": "N/A",
      "isBadge": true,
      "color": Color(0xFFFFA000),
    },
    {"label": "Admission Date", "value": "N/A"},
    {
      "label": "Admission Status",
      "value": "N/A",
      "isBadge": true,
      "color": Color(0xFF4CAF50),
    },
    {"label": "Join Date", "value": "N/A"},
    {
      "label": "Application Status",
      "value": "N/A",
      "isBadge": true,
      "color": Color(0xFF4CAF50),
    },
    {"label": "Actual Fee", "value": "₹0"},
    {
      "label": "Student Status",
      "value": "N/A",
      "isBadge": true,
      "color": Color(0xFF4CAF50),
    },
    {"label": "Admission Type", "value": "N/A"},
  ];

  String _displayName = "Loading...";
  String _displayAdmissionNo = "-";

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final response = await StudentProfileService.getProfile();
      if (response['status'] == true && response['data'] != null) {
        final profile = StudentProfile.fromJson(response['data']);

        if (mounted) {
          setState(() {
            _displayName = "${profile.sfname ?? ''} ${profile.slname ?? ''}"
                .trim();
            if (_displayName.isEmpty) _displayName = "Student";
            _displayAdmissionNo = profile.admno ?? "240018";

            _profile = profile;
            _updateFromModel(profile);
            _isLoading = false;
          });

          if (profile.photo != null && profile.photo!.isNotEmpty) {
            StudentProfileService.profileImageUrl.value = profile.photo;
          }
        }
      } else {
        throw Exception("Invalid response format");
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error loading profile: $e")));
      }
    }
  }

  void _updateFromModel(StudentProfile p) {
    // Personal Data
    _personalData[0]['value'] = p.sfname ?? 'N/A';
    _personalData[1]['value'] = p.slname ?? 'N/A';
    _personalData[2]['value'] = p.fname ?? 'N/A';
    _personalData[3]['value'] = p.mname ?? 'N/A';
    _personalData[4]['value'] = p.dob ?? 'N/A';
    _personalData[5]['value'] = p.aadharno ?? 'N/A';
    _personalData[6]['value'] = p.gender ?? 'N/A';
    _personalData[8]['value'] = p.caste ?? 'N/A';
    _personalData[10]['value'] = p.subcaste ?? 'N/A';

    // Contact Data
    _contactData[0]['value'] = p.mandal ?? 'N/A';
    _contactData[2]['value'] = p.village ?? 'N/A';
    _contactData[4]['value'] = p.address ?? 'N/A';
    _contactData[1]['value'] = p.amobile ?? 'N/A';
    _contactData[6]['value'] = p.pmobile ?? 'N/A';

    // Academic Data
    _academicData[0]['value'] = p.tenthgpa ?? 'N/A';
    _academicData[2]['value'] = p.lastschool ?? 'N/A';
    _academicData[4]['value'] = p.lastschooladdress ?? 'N/A';

    // Admission Data
    _admissionData[0]['value'] = p.admno ?? 'N/A';
    _admissionData[1]['value'] = "₹${p.committedfee ?? 0}";
    _admissionData[2]['value'] = p.appno ?? 'N/A';
    _admissionData[3]['value'] = p.feestatus?.toUpperCase() ?? 'N/A';
    _admissionData[4]['value'] = p.date ?? 'N/A';
    _admissionData[5]['value'] = p.admstatus?.toUpperCase() ?? 'N/A';
    _admissionData[7]['value'] = p.appstatus?.toUpperCase() ?? 'N/A';
    _admissionData[8]['value'] = "₹${p.actualfee ?? 0}";
    _admissionData[9]['value'] = p.status?.toUpperCase() ?? 'N/A';
    _admissionData[10]['value'] = p.admtype ?? 'N/A';

    // Additional Academic/Batch Data
    _academicData[4]['value'] = p.lastschooladdress ?? 'N/A';
    _academicData[5]['value'] = p.branchId?.toString() ?? 'N/A';
    _academicData[6]['value'] = p.groupId?.toString() ?? 'N/A';
    _academicData[7]['value'] = p.batchId?.toString() ?? 'N/A';
    _academicData[8]['value'] = p.courseId?.toString() ?? 'N/A';
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (mounted) setState(() => _isLoading = true);
      try {
        final success = await StudentProfileService.uploadProfileImage(
          File(image.path),
        );
        if (success) {
          await _fetchProfileData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Profile image updated successfully!"),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Failed to upload image"),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: StudentLoadingAnimation()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 65),
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                _buildNameCard(),
                Positioned(top: -60, child: _buildOverlappingAvatar()),
              ],
            ),
            const SizedBox(height: 25),
            _buildMenuCard(),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 25,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF7E49FF),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.person, color: Colors.white, size: 28),
          SizedBox(width: 10),
          Text(
            "Profile",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ── OVERLAPPING AVATAR ──────────────────────
  Widget _buildOverlappingAvatar() {
    return GestureDetector(
      onTap: _pickAndUploadImage,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ValueListenableBuilder<String?>(
          valueListenable: StudentProfileService.profileImageUrl,
          builder: (context, imageUrl, _) {
            final isBase64 =
                imageUrl != null && imageUrl.startsWith('data:image');
            return CircleAvatar(
              radius: 55,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                  ? (isBase64
                            ? MemoryImage(
                                base64Decode(imageUrl.split(',').last),
                              )
                            : NetworkImage(imageUrl))
                        as ImageProvider
                  : const NetworkImage("https://i.pravatar.cc/150"),
            );
          },
        ),
      ),
    );
  }

  // ── NAME AND ADMISSION CARD ────────────────────────────────────────
  Widget _buildNameCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(20, 75, 20, 25),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF4EDFF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Text(
            _displayName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
              children: [
                const TextSpan(text: "Admission No :  "),
                TextSpan(
                  text: _displayAdmissionNo,
                  style: const TextStyle(fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── MENU CARD ──────────────────────────────────────────────────────
  Widget _buildMenuCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItemRow(
            Icons.person,
            "Personal Information",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileDetailPage(
                  title: "Personal Information",
                  data: _personalData,
                ),
              ),
            ),
          ),
          const Divider(height: 24, thickness: 0.5, indent: 40),
          _buildMenuItemRow(
            Icons.school,
            "Academic Details",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileDetailPage(
                  title: "Academic Details",
                  data: _academicData,
                ),
              ),
            ),
          ),
          const Divider(height: 24, thickness: 0.5, indent: 40),
          _buildMenuItemRow(
            Icons.contact_mail,
            "Contact Information",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileDetailPage(
                  title: "Contact Information",
                  data: _contactData,
                ),
              ),
            ),
          ),
          const Divider(height: 24, thickness: 0.5, indent: 40),
          _buildMenuItemRow(
            Icons.description,
            "Admission Details",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileDetailPage(
                  title: "Admission Details",
                  data: _admissionData,
                ),
              ),
            ),
          ),
          const Divider(height: 24, thickness: 0.5, indent: 40),
          _buildMenuItemRow(
            Icons.lock,
            "Change Password",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
            ),
          ),
          const SizedBox(height: 24),
          // Gradient Edit Button
          GestureDetector(
            onTap: () async {
              if (_profile == null) return;

              final Map<String, dynamic> personal = {};
              _personalData.forEach((item) {
                personal[item['key']] = item['value'];
              });

              final Map<String, dynamic> academic = {};
              _academicData.forEach((item) {
                academic[item['key']] = item['value'];
              });

              final Map<String, dynamic> contact = {};
              _contactData.forEach((item) {
                contact[item['key']] = item['value'];
              });

              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfilePage(
                    initialPersonalData: personal,
                    initialAcademicData: academic,
                    initialContactData: contact,
                  ),
                ),
              );

              if (result == true) {
                _fetchProfileData(); // Refresh profile after editing
              }
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFD8B4FE)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_note, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "Edit Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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

  Widget _buildMenuItemRow(
    IconData icon,
    String title, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF8247E5), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black, size: 24),
        ],
      ),
    );
  }

  // ── BOTTOM NAV ─────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF8247E5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              Icons.home_filled,
              "Home",
              onTap: () =>
                  Navigator.pushReplacementNamed(context, '/studentDashboard'),
            ),
            _buildNavItem(
              Icons.bar_chart,
              "Marks",
              onTap: () =>
                  Navigator.pushReplacementNamed(context, '/studentMarks'),
            ),
            _buildNavItem(
              Icons.edit_document,
              "Exams",
              onTap: () =>
                  Navigator.pushReplacementNamed(context, '/studentExams'),
            ),
            _buildNavItem(Icons.person, "Profile", isActive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label, {
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFB590F3) : Colors.transparent,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// PROFILE DETAIL PAGE  (matches the image exactly)
// ═══════════════════════════════════════════════════════════════════

class ProfileDetailPage extends StatelessWidget {
  static const Color primaryPurple = Color(0xFF7E3FF2);
  final String title;
  final List<Map<String, dynamic>> data;

  const ProfileDetailPage({super.key, required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Purple header identical to the image ──────────────────
          Container(
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
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // ── Fields list ───────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                final label = item['label'] as String;
                final value = (item['value'] as String?) ?? 'N/A';
                final isBadge = item['isBadge'] == true;
                final isLarge = item['isLarge'] == true;
                final badgeColor = item['color'] as Color?;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (isBadge)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor ?? Colors.grey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            value,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                            minHeight: isLarge ? 100 : 0,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFE0E0E0),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            value,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SHARED COMPONENTS (Moved to separate files where applicable)
// ═══════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════
// SMALL HELPER WIDGETS
// ═══════════════════════════════════════════════════════════════════

// ignore: unused_element
class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.withOpacity(0.1),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// CHANGE PASSWORD FORM
// ═══════════════════════════════════════════════════════════════════

class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({super.key});

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  Future<void> _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final success = await StudentProfileService.changePassword(
        _currentController.text,
        _newController.text,
        _confirmController.text,
      );

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? "Password updated successfully!"
                  : "Failed to update password.",
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) {
          _currentController.clear();
          _newController.clear();
          _confirmController.clear();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(color: Color(0xFF7C3AED)),
            child: const Row(
              children: [
                Icon(Icons.lock_outline, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text(
                  "Change Password",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPasswordField(
                    "Current Password",
                    "Enter current password",
                    _currentController,
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordField(
                    "New Password",
                    "Enter new password",
                    _newController,
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordField(
                    "Confirm New Password",
                    "Confirm new password",
                    _confirmController,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updatePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const StudentLoadingAnimation()
                          : const Text(
                              "Update Password",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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

  Widget _buildPasswordField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.lock_outline, size: 18),
            suffixIcon: const Icon(Icons.visibility_outlined, size: 18),
            filled: true,
            fillColor: Colors.grey.withOpacity(0.07),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (val) => val != null && val.isNotEmpty ? null : "Required",
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// DETAILS CARD
// ═══════════════════════════════════════════════════════════════════

class DetailsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Map<String, dynamic>> data;

  const DetailsCard({
    super.key,
    required this.title,
    required this.icon,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(color: Color(0xFF7C3AED)),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Data fields
          Padding(
            padding: const EdgeInsets.all(20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 400;
                return Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: data.map((item) {
                    final isLarge = item['isLarge'] == true;
                    return SizedBox(
                      width: (isLarge || !isWide)
                          ? constraints.maxWidth
                          : (constraints.maxWidth - 20) / 2,
                      child: _buildField(
                        context,
                        item['label'] as String,
                        item['value'] as String,
                        item['isBadge'] == true,
                        item['color'] as Color?,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    BuildContext context,
    String label,
    String value,
    bool isBadge,
    Color? badgeColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.black45,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        if (isBadge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor ?? Colors.grey,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// EDIT PROFILE FORM
// ═══════════════════════════════════════════════════════════════════

class EditProfileForm extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> data;
  final Function(Map<String, String>) onSave;
  final VoidCallback onCancel;

  const EditProfileForm({
    super.key,
    required this.title,
    required this.data,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (var item in widget.data) {
      _controllers[item['key']] = TextEditingController(text: item['value']);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final Map<String, String> values = {};
      _controllers.forEach((key, controller) {
        values[key] = controller.text;
      });
      widget.onSave(values);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(color: Color(0xFF7C3AED)),
            child: Row(
              children: [
                const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: widget.data.map((item) {
                          final isLarge = item['isLarge'] == true;
                          return SizedBox(
                            width: isLarge
                                ? constraints.maxWidth
                                : (constraints.maxWidth > 400
                                      ? (constraints.maxWidth - 20) / 2
                                      : constraints.maxWidth),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['label'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _controllers[item['key']],
                                  maxLines: isLarge ? 3 : 1,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey.withOpacity(0.06),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.grey.withOpacity(0.2),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.grey.withOpacity(0.2),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF7C3AED),
                                        width: 1.5,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text("Save Changes"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C3AED),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: widget.onCancel,
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text("Cancel"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade400,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
