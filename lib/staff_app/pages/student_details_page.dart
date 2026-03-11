import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/student_model.dart';
import '../model/student_details_model.dart';
import '../api/api_service.dart';
import '../controllers/hostel_controller.dart';
import '../widgets/skeleton.dart';
import '../widgets/staff_header.dart';

class StudentDetailsPage extends StatefulWidget {
  final StudentModel? student;
  final String? admissionNo;

  const StudentDetailsPage({super.key, this.student, this.admissionNo});

  @override
  State<StudentDetailsPage> createState() => _StudentDetailsPageState();
}

class _StudentDetailsPageState extends State<StudentDetailsPage> {
  bool isLoading = true;
  StudentDetailsModel? studentDetails;
  String? errorMessage;
  late final HostelController hostelCtrl;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<HostelController>()) {
      Get.put(HostelController(), permanent: true);
    }
    hostelCtrl = Get.find<HostelController>();
    _loadStudentDetails();
  }

  Future<void> _loadStudentDetails() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final admNo = widget.admissionNo ?? widget.student?.admNo;

      if (admNo == null || admNo.trim().isEmpty) {
        throw Exception('Admission number is required');
      }

      final data = await ApiService.getStudentDetailsByAdmNo(admNo);

      setState(() {
        studentDetails = StudentDetailsModel.fromJson(data);
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
          if (widget.student != null) {
            studentDetails = StudentDetailsModel.fromStudentModel(
              widget.student!,
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: StaffLoadingAnimation())
          : errorMessage != null && studentDetails == null
          ? _buildErrorWidget()
          : _buildMainBody(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadStudentDetails,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainBody() {
    return Column(
      children: [
        const StaffHeader(title: "Student Details"),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileCard(),
                const SizedBox(height: 25),
                const Text(
                  "Personal Information",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),
                _buildPersonalInfoContainer(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Header UI is now managed by imported StaffHeader widget.

  Widget _buildProfileCard() {
    if (studentDetails == null) return const SizedBox.shrink();

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 50),
          padding: const EdgeInsets.only(
            top: 60,
            bottom: 25,
            left: 20,
            right: 20,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
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
              Text(
                '${studentDetails!.sFirstName} ${studentDetails!.sLastName}'
                    .toUpperCase(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black54, fontSize: 16),
                  children: [
                    const TextSpan(text: "Admission No : "),
                    TextSpan(
                      text: studentDetails!.admNo,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF006400).withOpacity(0.9), // Dark green
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  studentDetails!.status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 45,
              backgroundColor: Color(0xFF8147E7),
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoContainer() {
    if (studentDetails == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0FF),
        borderRadius: BorderRadius.circular(35),
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
          _buildInfoRow(
            Icons.edit_outlined,
            "Full Name",
            '${studentDetails!.sFirstName} ${studentDetails!.sLastName}',
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            Icons.groups_outlined,
            "Father Name",
            studentDetails!.fatherName,
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            Icons.phone_outlined,
            "Mobile",
            studentDetails!.mobile.isEmpty ? "N/A" : studentDetails!.mobile,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFDCD6FD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF8147E7), size: 24),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
