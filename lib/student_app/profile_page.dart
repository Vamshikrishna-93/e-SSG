import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:student_app/student_app/model/student_profile.dart';
import 'package:student_app/student_app/services/student_profile_service.dart';
import 'package:student_app/student_app/student_app_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:student_app/student_app/change_password_page.dart';
import 'package:student_app/theme_controllers.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditMode = false;
  bool _isLoading = true;
  String _activeSection = '';
  String _activeEditSection = '';
  bool _showChangePassword = false; // Toggle for change password view

  // Mutable Data Lists
  List<Map<String, dynamic>> _personalData = [
    {
      "label": "First Name",
      "value": "N/A",
      "key": "first_name",
      "required": true,
    },
    {
      "label": "Father's Name",
      "value": "N/A",
      "key": "father_name",
      "required": true,
    },
    {
      "label": "Last Name",
      "value": "N/A",
      "key": "last_name",
      "required": true,
    },
    {
      "label": "Mother's Name",
      "value": "N/A",
      "key": "mother_name",
      "required": true,
    },
    {"label": "Date of Birth", "value": "N/A", "key": "dob"},
    {"label": "Aadhar Number", "value": "N/A", "key": "aadhar"},
    {"label": "Gender", "value": "N/A", "key": "gender"},
    {"label": "Nationality", "value": "N/A", "key": "nationality"},
    {"label": "Caste", "value": "N/A", "key": "caste"},
    {"label": "Religion", "value": "N/A", "key": "religion"},
    {"label": "Subcaste", "value": "N/A", "key": "subcaste"},
    {"label": "Mother Tongue", "value": "N/A", "key": "mother_tongue"},
  ];

  List<Map<String, dynamic>> _contactData = [
    {"label": "Mandal", "value": "N/A", "key": "mandal"},
    {"label": "Mother's Mobile", "value": "N/A", "key": "mothers_mobile"},
    {"label": "Village/Town", "value": "N/A", "key": "village"},
    {"label": "Proctor ID", "value": "N/A", "key": "proctor_id"},
    {"label": "Address", "value": "N/A", "key": "address", "isLarge": true},
    {"label": "Proctor Phone", "value": "N/A", "key": "proctor_phone"},
    {
      "label": "Father's Mobile",
      "value": "N/A",
      "key": "fathers_mobile",
      "required": true,
    },
    {"label": "LSM", "value": "N/A", "key": "lsm"},
  ];

  List<Map<String, dynamic>> _academicData = [
    {"label": "10th GPA/Percentage", "value": "N/A", "key": "gpa"},
    {"label": "Religion", "value": "N/A", "key": "religion_academic"},
    {"label": "Last School", "value": "N/A", "key": "last_school"},
    {"label": "Comments", "value": "", "key": "comments", "isLarge": true},
    {
      "label": "Last School Address",
      "value": "N/A",
      "key": "last_school_address",
      "isLarge": true,
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
      "color": Colors.orange,
    },
    {"label": "Admission Date", "value": "N/A"},
    {
      "label": "Admission Status",
      "value": "N/A",
      "isBadge": true,
      "color": Colors.green,
    },
    {"label": "Join Date", "value": "N/A"},
    {
      "label": "Application Status",
      "value": "N/A",
      "isBadge": true,
      "color": Colors.green,
    },
    {"label": "Actual Fee", "value": "₹0"},
    {
      "label": "Student Status",
      "value": "N/A",
      "isBadge": true,
      "color": Colors.green,
    },
    {"label": "Admission Type", "value": "N/A"},
  ];

  String _displayName = "Loading...";
  String _displayAdmissionNo = "-";
  String _displayCampus = "-";

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
    _personalData[1]['value'] = p.fname ?? 'N/A';
    _personalData[2]['value'] = p.slname ?? 'N/A';
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

  void _cancelEdit() {
    setState(() {
      _isEditMode = false;
      _activeEditSection = '';
    });
  }

  void _saveChanges(String section, Map<String, String> updatedValues) {
    setState(() {
      List<Map<String, dynamic>> targetList;
      if (section == 'Personal')
        targetList = _personalData;
      else if (section == 'Contact')
        targetList = _contactData;
      else
        targetList = _academicData;

      for (var item in targetList) {
        final key = item['key'];
        if (updatedValues.containsKey(key)) {
          item['value'] = updatedValues[key];
        }
      }

      _isEditMode = false;
      _activeEditSection = '';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile updated locally"),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _isLoading = true);
      try {
        final success = await StudentProfileService.uploadProfileImage(
          File(image.path),
        );
        if (success) {
          // Re-fetch profile to get the new image URL
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
    return ThemeControllerWrapper(
      themeController: StudentThemeController.themeMode,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;

          if (_isLoading) {
            return Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              appBar: const StudentAppBar(title: "", showLeading: true),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: const StudentAppBar(title: "Profile", showLeading: true),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    // MAIN CARD (Avatar + Menu Buttons)
                    Container(
                      constraints: const BoxConstraints(maxWidth: 500),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              isDark ? 0.3 : 0.05,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.grey.shade700
                                        : Colors.white,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: ValueListenableBuilder<String?>(
                                  valueListenable:
                                      StudentProfileService.profileImageUrl,
                                  builder: (context, imageUrl, _) {
                                    final isBase64 =
                                        imageUrl != null &&
                                        imageUrl.startsWith('data:image');
                                    return CircleAvatar(
                                      radius: 50,
                                      backgroundColor: isDark
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade200,
                                      backgroundImage:
                                          imageUrl != null &&
                                              imageUrl.isNotEmpty
                                          ? (isBase64
                                                    ? MemoryImage(
                                                        base64Decode(
                                                          imageUrl
                                                              .split(',')
                                                              .last,
                                                        ),
                                                      )
                                                    : NetworkImage(imageUrl))
                                                as ImageProvider
                                          : const NetworkImage(
                                              "https://i.pravatar.cc/150",
                                            ),
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Material(
                                  color: const Color(0xFF2563EB),
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    onTap: _pickAndUploadImage,
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _displayName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Admission No: $_displayAdmissionNo",
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _displayCampus,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // MENU BUTTONS
                          _MenuButton(
                            label: _isEditMode
                                ? "Edit Personal Info"
                                : "Personal Information",
                            icon: Icons.person,
                            isActive:
                                !_showChangePassword &&
                                (_isEditMode
                                    ? _activeEditSection == 'Personal'
                                    : _activeSection == 'Personal'),
                            onTap: () => setState(() {
                              _showChangePassword = false;
                              if (_isEditMode)
                                _activeEditSection = 'Personal';
                              else
                                _activeSection = 'Personal';
                            }),
                          ),
                          const SizedBox(height: 8),
                          _MenuButton(
                            label: _isEditMode
                                ? "Edit Academic Info"
                                : "Academic Details",
                            icon: Icons.school,
                            isActive:
                                !_showChangePassword &&
                                (_isEditMode
                                    ? _activeEditSection == 'Academic'
                                    : _activeSection == 'Academic'),
                            onTap: () => setState(() {
                              _showChangePassword = false;
                              if (_isEditMode)
                                _activeEditSection = 'Academic';
                              else
                                _activeSection = 'Academic';
                            }),
                          ),
                          const SizedBox(height: 8),
                          _MenuButton(
                            label: _isEditMode
                                ? "Edit Contact Info"
                                : "Contact Information",
                            icon: Icons.contact_mail,
                            isActive:
                                !_showChangePassword &&
                                (_isEditMode
                                    ? _activeEditSection == 'Contact'
                                    : _activeSection == 'Contact'),
                            onTap: () => setState(() {
                              _showChangePassword = false;
                              if (_isEditMode)
                                _activeEditSection = 'Contact';
                              else
                                _activeSection = 'Contact';
                            }),
                          ),
                          const SizedBox(height: 8),
                          if (!_isEditMode)
                            _MenuButton(
                              label: "Admission Details",
                              icon: Icons.description,
                              isActive:
                                  !_showChangePassword &&
                                  _activeSection == 'Admission',
                              onTap: () => setState(() {
                                _showChangePassword = false;
                                _activeSection = 'Admission';
                              }),
                            ),

                          // CHANGE PASSWORD BUTTON (New)
                          const SizedBox(height: 8),
                          if (!_isEditMode)
                            _MenuButton(
                              label: "Change Password",
                              icon: Icons.lock_outline_rounded,
                              isActive: false,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ThemeControllerWrapper(
                                      themeController:
                                          StudentThemeController.themeMode,
                                      child: const ChangePasswordPage(),
                                    ),
                                  ),
                                );
                              },
                            ),

                          const SizedBox(height: 24),
                          // EDIT TOGGLE / CANCEL
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _showChangePassword
                                  ? () => setState(
                                      () => _showChangePassword = false,
                                    )
                                  : (_isEditMode
                                        ? _cancelEdit
                                        : () => setState(() {
                                            _isEditMode = true;
                                            _activeEditSection = 'Personal';
                                            _activeSection = '';
                                          })),
                              icon: Icon(
                                _isEditMode ? Icons.close : Icons.edit_note,
                                size: 18,
                              ),
                              label: Text(
                                _isEditMode ? "Cancel" : "Edit Profile",
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isEditMode
                                    ? Colors.grey.shade600
                                    : const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // DETAILS / FORM DISPLAY
                    const SizedBox(height: 24),

                    if (_showChangePassword)
                      Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: const ChangePasswordForm(),
                      )
                    else if (_isEditMode && _activeEditSection.isNotEmpty)
                      Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: _buildEditFormForSection(_activeEditSection),
                      )
                    else if (_activeSection.isNotEmpty)
                      Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: _buildDetailsCardForSection(_activeSection),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditFormForSection(String section) {
    if (section == 'Personal') {
      return EditProfileForm(
        title: "Edit Personal Information",
        data: _personalData,
        onSave: (v) => _saveChanges('Personal', v),
        onCancel: _cancelEdit,
      );
    } else if (section == 'Contact') {
      return EditProfileForm(
        title: "Edit Contact Information",
        data: _contactData,
        onSave: (v) => _saveChanges('Contact', v),
        onCancel: _cancelEdit,
      );
    } else {
      return EditProfileForm(
        title: "Edit Academic Information",
        data: _academicData,
        onSave: (v) => _saveChanges('Academic', v),
        onCancel: _cancelEdit,
      );
    }
  }

  Widget _buildDetailsCardForSection(String section) {
    String title = "";
    IconData icon = Icons.info;
    List<Map<String, dynamic>> data = [];

    if (section == 'Personal') {
      title = "Personal Information";
      icon = Icons.person;
      data = _personalData;
    } else if (section == 'Academic') {
      title = "Academic Details";
      icon = Icons.school;
      data = _academicData;
    } else if (section == 'Contact') {
      title = "Contact Information";
      icon = Icons.contact_mail;
      data = _contactData;
    } else if (section == 'Admission') {
      title = "Admission Details";
      icon = Icons.description;
      data = _admissionData;
    }

    return DetailsCard(title: title, icon: icon, data: data);
  }
}

// ================= CHANGE PASSWORD FORM =================

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
          // Clear fields
          _currentController.clear();
          _newController.clear();
          _confirmController.clear();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header (White bg, Blue text)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            width: double.infinity,
            color: isDark ? theme.scaffoldBackgroundColor : Colors.white,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, color: Color(0xFF2563EB)),
                const SizedBox(width: 8),
                Text(
                  "Change Password",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
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
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Update Password",
                              style: TextStyle(
                                fontSize: 16,
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
            prefixIcon: const Icon(Icons.key, size: 18), // or lock
            suffixIcon: const Icon(Icons.visibility_outlined, size: 18),
            filled: true,
            fillColor: Colors.grey.withValues(alpha: 0.1), // Darkish input bg
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (val) => val != null && val.isNotEmpty ? null : "Required",
        ),
      ],
    );
  }
}

// ... [Rest of the existing widgets: DetailsCard, _MenuButton, EditProfileForm remain unchanged]
// I will include them here to ensure the file is complete and correct.

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
    // ... [Same implementation]
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF2563EB),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 500;
                return Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: data.map((item) {
                    return SizedBox(
                      width: isWide
                          ? (constraints.maxWidth - 24) / 2 - 1
                          : constraints.maxWidth,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        if (isBadge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(4),
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
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade100 : Colors.black87,
            ),
          ),
      ],
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: isActive ? const Color(0xFF2563EB) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive
                  ? Colors.white
                  : (isDark ? Colors.blue.shade400 : const Color(0xFF2563EB)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isActive
                      ? Colors.white
                      : (isDark
                            ? Colors.blue.shade100
                            : const Color(0xFF2563EB)),
                ),
              ),
            ),
            if (!isActive)
              Icon(
                Icons.chevron_right,
                size: 18,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }
}

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF2563EB),
            child: Row(
              children: [
                const Icon(Icons.edit, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        children: widget.data.map((item) {
                          final isLarge = item['isLarge'] == true;
                          return SizedBox(
                            width: isLarge
                                ? constraints.maxWidth
                                : (constraints.maxWidth > 500
                                      ? (constraints.maxWidth - 24) / 2 - 1
                                      : constraints.maxWidth),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${item['label']}*",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _controllers[item['key']],
                                  maxLines: isLarge ? 3 : 1,
                                  decoration: InputDecoration(
                                    filled: true,
                                    border: OutlineInputBorder(),
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
                      ElevatedButton(
                        onPressed: _submit,
                        child: const Text("Save Changes"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: widget.onCancel,
                        child: const Text("Cancel"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
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
