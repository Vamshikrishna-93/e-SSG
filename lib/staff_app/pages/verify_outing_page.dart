import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:student_app/staff_app/api/api_service.dart';
// import 'package:student_app/staff_app/pages/outing_pending_listPage.dart';
import '../widgets/staff_header.dart';

class VerifyOutingPage extends StatefulWidget {
  final int? outingId;
  final String? name;
  final String? adm;
  final String? time;
  final String? status;
  final String? type;
  final String? imageUrl;

  const VerifyOutingPage({
    super.key,
    this.outingId,
    this.name,
    this.adm,
    this.time,
    this.status,
    this.type,
    this.imageUrl,
  });

  @override
  State<VerifyOutingPage> createState() => _VerifyOutingPageState();
}

class _VerifyOutingPageState extends State<VerifyOutingPage> {
  final ImagePicker _picker = ImagePicker();

  File? _capturedImage;

  bool _isLoadingDetails = false;
  bool _isUploadingPhoto = false;
  bool _isApproving = false;
  bool _isReportingIn = false;
  bool _photoUploaded = false;

  Map<String, dynamic>? _details;
  Map<String, dynamic>? _studentDetails;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    if (widget.outingId == null) return;

    try {
      setState(() => _isLoadingDetails = true);

      final data = await ApiService.getOutingDetails(widget.outingId!);
      final indexData = data['indexdata'];

      Map<String, dynamic>? details;
      if (indexData is List && indexData.isNotEmpty) {
        details = Map<String, dynamic>.from(indexData.first);
      } else if (indexData is Map) {
        details = Map<String, dynamic>.from(indexData);
      } else {
        details = Map<String, dynamic>.from(data);
      }

      setState(() {
        _details = details;
      });

      // Fetch additional student details if admno is available
      final admNo = details['admno'] ?? widget.adm;
      if (admNo != null && admNo.toString().isNotEmpty) {
        try {
          final studentData = await ApiService.getStudentDetailsByAdmNo(
            admNo.toString(),
          );
          setState(() {
            _studentDetails = studentData;
          });
        } catch (e) {
          debugPrint("Failed to fetch student details: $e");
        }
      }

      setState(() {
        _isLoadingDetails = false;
      });
    } catch (e) {
      setState(() => _isLoadingDetails = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final admNo =
        _details?['admno'] ??
        _details?['adm_no'] ??
        _studentDetails?['admno'] ??
        widget.adm ??
        "-";

    final studentName =
        _details?['student_name'] ??
        _details?['sname'] ??
        _details?['studentname'] ??
        _details?['name'] ??
        _studentDetails?['student_name'] ??
        _studentDetails?['sname'] ??
        _studentDetails?['studentname'] ??
        _studentDetails?['name'] ??
        widget.name ??
        "-";

    final fatherName =
        _studentDetails?['father_name'] ??
        _studentDetails?['fname'] ??
        _studentDetails?['fathername'] ??
        _details?['father_name'] ??
        _details?['fname'] ??
        _details?['fathername'] ??
        "-";

    final mobile =
        _studentDetails?['mobile'] ??
        _studentDetails?['mobileno'] ??
        _studentDetails?['mobile_no'] ??
        _studentDetails?['mobile_number'] ??
        _studentDetails?['phone'] ??
        _studentDetails?['pmobile'] ??
        _details?['mobile'] ??
        _details?['mobileno'] ??
        "-";

    final branch =
        _details?['branch'] ??
        _details?['branch_name'] ??
        _studentDetails?['branch_name'] ??
        _studentDetails?['branch'] ??
        "-";

    final group =
        _studentDetails?['group_name'] ??
        _studentDetails?['group'] ??
        _studentDetails?['groupname'] ??
        _details?['group_name'] ??
        _details?['group'] ??
        "-";

    final course =
        _studentDetails?['course_name'] ??
        _studentDetails?['course'] ??
        _studentDetails?['coursename'] ??
        _details?['course_name'] ??
        _details?['course'] ??
        "-";

    final batch =
        _studentDetails?['batch_name'] ??
        _studentDetails?['batch'] ??
        _studentDetails?['batchname'] ??
        _details?['batch_name'] ??
        _details?['batch'] ??
        "-";

    final outDate =
        _details?['out_date'] ??
        _details?['outing_date'] ??
        _details?['outdate'] ??
        _details?['date'] ??
        "-";

    final permission =
        _details?['permission'] ??
        _details?['approved_by'] ??
        _details?['permissionby'] ??
        "-";

    final purpose = _details?['purpose'] ?? _details?['outpurpuse'] ?? "-";

    final type =
        _details?['passtype'] ??
        _details?['pass_type'] ??
        _details?['outingtype'] ??
        _details?['outing_type'] ??
        _details?['type'] ??
        widget.type ??
        "-";

    final time =
        _details?['outing_time'] ??
        _details?['outtime'] ??
        _details?['out_time'] ??
        _details?['time'] ??
        widget.time ??
        "-";

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const StaffHeader(title: "Verify Outing"),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  /// INFO CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: _isLoadingDetails
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            children: [
                              Text(
                                admNo,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 20),

                              _row("Student Name :", studentName),
                              _row("Father Name :", fatherName),
                              _row("Admission No :", admNo),
                              _row("Mobile :", mobile),
                              _row("Branch :", branch),
                              _row("Group :", group),
                              _row("Course :", course),
                              _row("Batch :", batch),
                              _row("Out Date :", outDate),

                              const Divider(),

                              _row("Permission By :", permission),
                              _row("Purpose :", purpose),
                              _row("Type :", type),
                              _row("Time :", time),
                            ],
                          ),
                  ),

                  const SizedBox(height: 20),

                  /// PHOTO CARD
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: _capturedImage != null
                                ? Image.file(_capturedImage!, fit: BoxFit.cover)
                                : (_details?['pic'] != null ||
                                      widget.imageUrl != null)
                                ? Image.network(
                                    _details?['pic'] ?? widget.imageUrl!,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(
                                    Icons.camera_alt,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                          ),
                        ),
                        if (_isUploadingPhoto)
                          Container(
                            color: Colors.black.withOpacity(0.3),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    final status = widget.status?.toLowerCase() ?? "";
    final defaultGradient = const LinearGradient(
      colors: [Color(0xFF7D74FC), Color(0xFFD08EF7)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    if (status == "approved") {
      return _button(
        text: "Report In",
        gradient: defaultGradient,
        onTap: () async {
          if (_isReportingIn) return;

          setState(() => _isReportingIn = true);

          await ApiService.inreportOuting(widget.outingId!);

          Get.back();
        },
      );
    }

    return Row(
      children: [
        Expanded(
          child: _button(
            text: _isUploadingPhoto ? "Uploading..." : "Take Photo",
            gradient: defaultGradient,
            onTap: _isUploadingPhoto ? () {} : () => _showCaptureDialog(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _button(
            text: _isApproving ? "Approving..." : "Approve",
            gradient: (_photoUploaded && !_isUploadingPhoto && !_isApproving)
                ? const LinearGradient(
                    colors: [Color(0xFF3FAFB9), Color(0xFFAED581)],
                  )
                : null,
            color: (_photoUploaded && !_isUploadingPhoto && !_isApproving)
                ? null
                : Colors.grey,
            onTap: (_photoUploaded && !_isUploadingPhoto && !_isApproving)
                ? () async {
                    setState(() => _isApproving = true);
                    try {
                      final phone = _studentDetails?['pmobile'] ??
                          _studentDetails?['mobile'] ??
                          _studentDetails?['mobileno'];
                      await ApiService.approveOuting(
                        widget.outingId!,
                        phone: phone?.toString(),
                      );
                      Get.back();
                    } catch (e) {
                      setState(() => _isApproving = false);
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        SnackBar(content: Text("Approval failed: $e")),
                      );
                    }
                  }
                : null,
          ),
        ),
      ],
    );
  }

  Widget _button({
    required String text,
    Color? color,
    Gradient? gradient,
    required VoidCallback? onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        color: color,
        gradient: gradient,
        borderRadius: BorderRadius.circular(15),
        boxShadow: gradient != null
            ? [
              BoxShadow(
                color: const Color(0xFF7D74FC).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showCaptureDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.camera_alt, size: 40),
              onPressed: () async {
                Navigator.pop(context);
                await _captureFromCamera();
              },
            ),

            IconButton(
              icon: const Icon(Icons.photo, size: 40),
              onPressed: () async {
                Navigator.pop(context);
                await _pickFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _captureFromCamera() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (photo != null) {
      final file = File(photo.path);

      setState(() => _capturedImage = file);

      await _uploadPhoto(file);
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      final file = File(image.path);

      setState(() => _capturedImage = file);

      await _uploadPhoto(file);
    }
  }

  Future<void> _uploadPhoto(File file) async {
    setState(() {
      _isUploadingPhoto = true;
    });

    try {
      final url = await ApiService.uploadOutingPhoto(
        file,
        outingId: widget.outingId!,
      );

      setState(() {
        _photoUploaded = true;

        if (url != null && _details != null) {
          _details!['pic'] = url;
        }
      });
    } catch (e) {
      debugPrint("Upload failed $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Upload failed: $e")));
    }

    setState(() {
      _isUploadingPhoto = false;
    });
  }

}
