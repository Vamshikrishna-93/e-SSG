import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:student_app/staff_app/pages/outing_pending_listPage.dart';
import 'package:get/get.dart';
import '../widgets/staff_header.dart';

class VerifyOutingPage extends StatefulWidget {
  final String? name;
  final String? adm;
  final String? time;
  final String? status;
  final String? type;
  final String? imageUrl;
  final String? fatherName;
  final String? mobile;
  final String? branch;
  final String? group;
  final String? course;
  final String? batch;
  final String? outDate;
  final String? permissionBy;
  final String? purpose;
  final bool? isReportIn;

  const VerifyOutingPage({
    super.key,
    this.name,
    this.adm,
    this.time,
    this.status,
    this.type,
    this.imageUrl,
    this.fatherName,
    this.mobile,
    this.branch,
    this.group,
    this.course,
    this.batch,
    this.outDate,
    this.permissionBy,
    this.purpose,
    this.isReportIn,
  });

  @override
  State<VerifyOutingPage> createState() => _VerifyOutingPageState();
}

class _VerifyOutingPageState extends State<VerifyOutingPage> {
  final ImagePicker _picker = ImagePicker();
  File? _capturedImage;
  bool _isApproved = false;

  @override
  void initState() {
    super.initState();
    _isApproved = widget.isReportIn ?? false;
  }

  @override
  Widget build(BuildContext context) {
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
                  _buildInfoCard(),
                  const SizedBox(height: 20),
                  _buildPhotoCard(),
                  const SizedBox(height: 20),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            widget.adm ?? "241530",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          _buildRow("Student Name :", widget.name ?? "Gujjula Ganesh Reddy"),
          _buildRow("Father Name :", widget.fatherName ?? "Srinu"),
          _buildRow("Admission No :", widget.adm ?? "241530"),
          _buildRow("Mobile :", widget.mobile ?? ""),
          if (!_isApproved) ...[
            _buildRow(
              "Branch :",
              widget.branch ?? "SSJC-SSG NEET & MAINS CAMPUS",
            ),
            _buildRow("Group :", widget.group ?? "SR MPC"),
            _buildRow("Course :", widget.course ?? "MAINS"),
            _buildRow("Batch :", widget.batch ?? "SS-SR-SM1"),
          ],
          _buildRow("Out Date :", widget.outDate ?? "2026-03-05"),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(color: Colors.grey, height: 1),
          ),
          _buildRow("Permission By :", widget.permissionBy ?? "Ashok Reddy"),
          _buildRow("Purpose :", widget.purpose ?? "Temple Visit"),
          _buildRow("Type :", widget.type ?? "Home Pass"),
          _buildRow("Time :", widget.time ?? "08:47 PM"),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: _capturedImage != null
            ? Image.file(
                _capturedImage!,
                fit: BoxFit.cover,
                width: double.infinity,
              )
            : (_isApproved &&
                  widget.imageUrl != null &&
                  widget.imageUrl!.isNotEmpty)
            ? Image.network(
                widget.imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) =>
                    _buildCapturePlaceholder(),
              )
            : _buildCapturePlaceholder(),
      ),
    );
  }

  Widget _buildCapturePlaceholder() {
    return Center(
      child: Image.network(
        "https://cdn3d.iconscout.com/3d/premium/thumb/camera-5590723-4652414.png",
        width: 150,
        height: 150,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 80,
              color: const Color(0xFF8B5CF6).withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              "Tap to Capture Photo",
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_isApproved) {
      return Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7D74FC), Color(0xFFD08EF7)],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ElevatedButton(
          onPressed: () {
            // Report In logic
            Get.offAll(() => const OutingPendingListPage());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: const Text(
            "Report In",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7D74FC), Color(0xFFD08EF7)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ElevatedButton(
              onPressed: () => _showCaptureDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Take Photo",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: _capturedImage == null
                  ? null // Use disabled color instead of gradient if disabled
                  : const LinearGradient(
                      colors: [Color(0xFF7D74FC), Color(0xFFD08EF7)],
                    ),
              color: _capturedImage == null ? const Color(0xFFC4C4C4) : null,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ElevatedButton(
              onPressed: _capturedImage == null
                  ? null
                  : () {
                      setState(() {
                        _isApproved = true;
                      });
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Approve",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCaptureDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Capture Student Photo",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _dialogButton(
                  icon: Icons.camera_alt,
                  label: "Camera",
                  onTap: () {
                    _captureFromCamera();
                    Navigator.pop(context);
                  },
                ),
                _dialogButton(
                  icon: Icons.photo_library,
                  label: "Gallery",
                  onTap: () {
                    _pickFromGallery();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF8B5CF6), size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _captureFromCamera() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) setState(() => _capturedImage = File(photo.path));
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _capturedImage = File(image.path));
  }
}
