import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api/api_service.dart';
import '../controllers/outing_pending_controller.dart';
import '../controllers/outing_controller.dart';
import 'outing_pending_listPage.dart';
import '../widgets/staff_header.dart';

class IssueOutingPage extends StatefulWidget {
  final String studentName;
  final String outingType;

  const IssueOutingPage({
    super.key,
    this.studentName = "",
    this.outingType = "",
  });

  @override
  State<IssueOutingPage> createState() => _IssueOutingPageState();
}

class _IssueOutingPageState extends State<IssueOutingPage> {
  String passType = "Home Pass";
  String selectedStudent = "Select Student";
  String selectedPurpose = "Select Purpose";
  File? _letterPhoto;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  Map<String, dynamic>? _selectedStudentData;
  bool _isLoading = false;
  bool _isUploadingPhoto = false;
  String? _uploadedLetterUrl;
  late final OutingController outingCtrl;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<OutingController>()) {
      Get.put(OutingController(), permanent: true);
    }
    outingCtrl = Get.find<OutingController>();

    if (widget.studentName.isNotEmpty) {
      selectedStudent = widget.studentName;
    }
    if (widget.outingType.isNotEmpty) {
      passType = widget.outingType;
    }
  }

  Future<void> _submitOuting() async {
    if (_selectedStudentData == null) {
      Get.snackbar(
        "Required",
        "Please select a student first",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    if (selectedPurpose == "Select Purpose") {
      Get.snackbar(
        "Required",
        "Please select a purpose",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    if (_letterPhoto == null) {
      Get.snackbar(
        "Required",
        "Please take a photo of the letter",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // 1. Upload letter photo if not already uploaded
      String? letterUrl = _uploadedLetterUrl;
      if (letterUrl == null) {
        letterUrl = await ApiService.uploadOutingLetter(
          _letterPhoto!,
          admNo: _selectedStudentData?['admno'],
        );
      }

      // 2. Format date (backend usually expects YYYY-MM-DD)
      String formattedDateForApi =
          "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

      // 3. Extract SID
      int sid =
          int.tryParse(_selectedStudentData?['id']?.toString() ?? '0') ?? 0;
      if (sid == 0) {
        sid =
            int.tryParse(_selectedStudentData?['sid']?.toString() ?? '0') ?? 0;
      }

      // 4. Store Outing
      await ApiService.storeOuting(
        sid: sid,
        admNo: _selectedStudentData?['admno'] ?? '',
        studentName:
            _selectedStudentData?['name'] ??
            _selectedStudentData?['sfname'] ??
            '',
        outDate: formattedDateForApi,
        outTime: formattedTime, // Format: 01:30 PM
        outingType: passType,
        purpose: selectedPurpose,
        letterPhoto: letterUrl ?? "", // Pass URL or placeholder
      );

      // 5. Refresh Pending List (if controller exists)
      if (Get.isRegistered<OutingPendingController>()) {
        Get.find<OutingPendingController>().fetchOutings();
      }

      Get.snackbar(
        "Success",
        "Outing Issued Successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate to pending list after success
      Get.off(() => const OutingPendingListPage());
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    try {
      final results = await ApiService.searchStudents(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  void _onStudentSelected(Map<String, dynamic> student) {
    setState(() {
      _selectedStudentData = student;
      selectedStudent = student['sfname'] ?? student['name'] ?? '';
      _searchController.text = student['admno'] ?? '';
      _searchResults = [];
    });

    final String sid = (student['sid'] ?? student['id'] ?? '0').toString();
    final String admno = (student['admno'] ?? '').toString();

    // Trigger history fetch via controller
    outingCtrl.fetchStudentOutings(admno, sid: sid);

    // Check for red flag
    final flagVal = student['isflagged'];
    final bool isFlagged =
        flagVal != null && flagVal != 'null' && flagVal != false;

    if (isFlagged) {
      _showFlaggedWarning(student['isflagged'].toString(), () {
        _showOutingListPopup(student);
      });
    } else {
      _showOutingListPopup(student);
    }
  }

  void _showFlaggedWarning(String remarks, VoidCallback onConfirm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFACEA8), width: 3),
                ),
                child: const Center(
                  child: Text(
                    "!",
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFFF8BB86),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Warning",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF595959),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Caution: This student has a red flag. Kindly verify before issuing an outing.",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF545454),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  onConfirm();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF27474),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF000000).withOpacity(0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _letterPhoto = File(pickedFile.path);
        _uploadedLetterUrl = null; // Reset before new upload
      });
      await _uploadSelectedPhoto();
    }
  }

  Future<void> _uploadSelectedPhoto() async {
    if (_letterPhoto == null) return;

    setState(() => _isUploadingPhoto = true);
    try {
      String? letterUrl = await ApiService.uploadOutingLetter(
        _letterPhoto!,
        admNo: _selectedStudentData?['admno'],
      );

      setState(() {
        _uploadedLetterUrl = letterUrl;
      });

      Get.snackbar(
        "Upload Successful",
        "Letter photo uploaded successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Upload Failed",
        "Failed to upload photo: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isUploadingPhoto = false);
    }
  }

  void _showPhotoPickerPopup() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select Photo Source",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerOption(
                  icon: Icons.camera_alt,
                  label: "Take a Photo",
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildPickerOption(
                  icon: Icons.photo_library,
                  label: "Pick from Gallery",
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F0FF),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF8147E7), width: 1),
            ),
            child: Icon(icon, color: const Color(0xFF8147E7), size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showOutingListPopup(Map<String, dynamic> student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildOutingListPopup(student),
    );
  }

  Widget _buildOutingListPopup(Map<String, dynamic> student) {
    return Obx(() {
      final isLoading = outingCtrl.isLoading.value;
      final outings = outingCtrl.selectedStudentOutings;

      return Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            // Popup Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF8B5CF6),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
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
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Text(
                    "Student Outing List",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Popup Content
            Expanded(
              child: Container(
                color: const Color(0xFFF3F0FF),
                padding: const EdgeInsets.all(16),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : outings.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              color: Colors.grey.shade400,
                              size: 50,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "No past outings found",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: outings.length,
                        itemBuilder: (context, index) {
                          final outing = outings[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey.shade100),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      outing.outDate,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF8B5CF6),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF8B5CF6,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        outing.outingTime,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF8B5CF6),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        "Purpose: ${outing.purpose}",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person_outline,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      "By: ${outing.permission.isEmpty ? 'Pending' : outing.permission}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8147E7),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF8147E7),
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          ),
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String get formattedDate {
    return "${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}";
  }

  String get formattedTime {
    final int hour = _selectedTime.hourOfPeriod;
    final int displayHour = hour == 0 ? 12 : hour;
    final String minute = _selectedTime.minute.toString().padLeft(2, '0');
    final String period = _selectedTime.period == DayPeriod.am ? 'AM' : 'PM';
    return "${displayHour.toString().padLeft(2, '0')}:$minute $period";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const StaffHeader(title: "Issue Outing"),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date
                    _buildLabel("Date"),
                    _buildDatePicker(),
                    const SizedBox(height: 12),

                    // Pass Type
                    _buildLabel("Pass Type"),
                    _buildPassTypeGrid(),
                    const SizedBox(height: 12),

                    // Admission Search
                    _buildLabel("Select Student"),
                    _buildAdmissionSearch(),
                    const SizedBox(height: 12),

                    // Letter Photo
                    _buildLabel("Letter Photo"),
                    _buildPhotoUpload(),
                    const SizedBox(height: 12),

                    // Out Time
                    _buildLabel("Out Time"),
                    _buildTimePicker(),
                    const SizedBox(height: 12),

                    // Purpose
                    _buildLabel("Purpose"),
                    _buildDropdown(
                      selectedPurpose,
                      (v) {
                        setState(() => selectedPurpose = v!);
                      },
                      [
                        "Select Purpose",
                        "Personal",
                        "Health Problem",
                        "Functions",
                        "Temple Visit",
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Action Button
                    _buildGradientButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdmissionSearch() {
    return Column(
      children: [
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 4,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _handleSearch,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "Search by Adm No",
              hintStyle: TextStyle(color: Colors.black, fontSize: 13),
            ),
          ),
        ),
        if (_searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _searchResults.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final student = _searchResults[index];
                String name = student['sfname'] ?? student['name'] ?? '';
                String admNo = student['admno'] ?? '';
                String father = student['fname'] ?? '';
                String course = student['coursename'] ?? '';
                String group = student['groupname'] ?? '';

                return ListTile(
                  onTap: () => _onStudentSelected(student),
                  title: Text(
                    "$admNo/$name",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  subtitle: Text(
                    "$father | $course | $group",
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                );
              },
            ),
          ),
        if (_isSearching)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        "$text *",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 4,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formattedDate,
              style: const TextStyle(color: Colors.black87, fontSize: 14),
            ),
            const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return GestureDetector(
      onTap: () => _selectTime(context),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 4,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formattedTime,
              style: const TextStyle(color: Colors.black87, fontSize: 14),
            ),
            const Icon(Icons.access_time, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String value,
    void Function(String?) onChanged,
    List<String> items,
  ) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildPassTypeGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildPassTypeOption("Home Pass")),
              Expanded(child: _buildPassTypeOption("Outing Pass")),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildPassTypeOption("Self Outing")),
              Expanded(child: _buildPassTypeOption("Self Home")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassTypeOption(String title) {
    bool isSelected = passType == title;
    return GestureDetector(
      onTap: () => setState(() => passType = title),
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF8147E7), width: 1.5),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: const BoxDecoration(
                        color: Color(0xFF8147E7),
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoUpload() {
    return GestureDetector(
      onTap: _isUploadingPhoto ? null : _showPhotoPickerPopup,
      child: CustomPaint(
        painter: DashedBorderPainter(color: const Color(0xFF8147E7)),
        child: Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: _isUploadingPhoto
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF8147E7)),
                )
              : _letterPhoto != null
              ? Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_letterPhoto!, fit: BoxFit.cover),
                      ),
                    ),
                    if (_uploadedLetterUrl != null)
                      Positioned(
                        top: 5,
                        right: 5,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                )
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined, color: Color(0xFF8147E7)),
                    SizedBox(height: 8),
                    Text(
                      "Take a Photo",
                      style: TextStyle(
                        color: Color(0xFF8147E7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildGradientButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _submitOuting,
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isLoading
                ? [Colors.grey.shade400, Colors.grey.shade500]
                : const [Color(0xFF7D74FC), Color(0xFFD08EF7)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 4,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Grant Outing",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    Path path = Path();
    double radius = 12;
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ),
    );

    // Actually drawing border
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
