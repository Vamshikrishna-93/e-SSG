import 'package:flutter/material.dart';
import 'package:student_app/student_app/widgets/loading_animation.dart';

class UploadDocumentDialog extends StatefulWidget {
  final String initialCategory;

  const UploadDocumentDialog({super.key, required this.initialCategory});

  @override
  State<UploadDocumentDialog> createState() => _UploadDocumentDialogState();
}

class _UploadDocumentDialogState extends State<UploadDocumentDialog> {
  late String selectedType;

  final List<String> documentTypes = [
    "ID Proof(Aadhar, PAN, etc.)",
    "Academic (Marksheets, Certificates)",
    "Medical (Health Certificate)",
    "Hostel (Allocation, Consent Forms)",
    "Financial (Fee Receipts)",
    "Other Documents",
  ];

  @override
  void initState() {
    super.initState();
    selectedType = _mapCategory(widget.initialCategory);
  }

  String _mapCategory(String category) {
    switch (category) {
      case "ID Proof":
        return documentTypes[0];
      case "Academic":
        return documentTypes[1];
      case "Medical":
        return documentTypes[2];
      case "Hostel":
        return documentTypes[3];
      case "Financial":
        return documentTypes[4];
      default:
        return documentTypes[5];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Upload Documents",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.black, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // UPLOAD AREA (Dashed look from image)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.file_upload_outlined,
                    size: 36,
                    color: Color(0xFF6366F1),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Click or drag file to this area to upload",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Support for PDF, PNG, DOC, XLS. Max file size 5MB",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // SELECT DOCUMENT TYPE LABEL
            const Text(
              "Select Document Type",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),

            // DROPDOWN
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedType,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.black54,
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  items: documentTypes
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedType = value!);
                  },
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ACTION BUTTONS
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _simulateUpload,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD497FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          "Upload Document",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: const Center(
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: Color(0xFF6366F1),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _simulateUpload() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: StudentLoadingAnimation()),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context); // Close loading indicator
        Navigator.pop(context); // Close upload dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Document uploaded successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }
}
