import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_app/student_app/services/documents_controller.dart';
import 'package:student_app/student_app/upload_document_dialog.dart';
import 'package:intl/intl.dart';
import 'package:student_app/student_app/widgets/loading_animation.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final DocumentsController _controller;

  static const Color primaryPurple = Color(0xFF7E3FF2);

  String selectedCategory = "Financial";

  final List<String> categories = [
    "ID Proof",
    "Academic",
    "Medical",
    "Hostel",
    "Financial",
    "Others",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });

    // Self-healing check
    if (!Get.isRegistered<DocumentsController>()) {
      Get.put(DocumentsController(), permanent: true);
    }
    _controller = Get.find<DocumentsController>();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value) {
                return const Center(child: StudentLoadingAnimation());
              }

              if (_controller.errorMessage.value != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.folder_off_outlined,
                          size: 56,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Unable to load documents",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Please check your connection and try again.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () =>
                              _controller.fetchDocuments(forceRefresh: true),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text("Retry"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7E3FF2),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Documents",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Manage your student documents and verifications",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _actionButton(
                            label: "Upload Documents",
                            icon: Icons.upload_outlined,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFFC084FC)],
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => const UploadDocumentDialog(
                                  initialCategory: '',
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _actionButton(
                            label: "Refresh",
                            icon: Icons.refresh,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4DB6AC), Color(0xFFAED581)],
                            ),
                            onTap: () =>
                                _controller.fetchDocuments(forceRefresh: true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _statTile(
                      "Total Documents",
                      _controller.totalDocs.value,
                      const Color(0xFF2196F3),
                      Icons.folder_outlined,
                    ),
                    _statTile(
                      "Verified",
                      _controller.verifiedDocs.value,
                      const Color(0xFF4CAF50),
                      Icons.check_circle_outline,
                    ),
                    _statTile(
                      "Pending",
                      _controller.pendingDocs.value,
                      const Color(0xFFF59E0B),
                      Icons.access_time,
                    ),
                    _statTile(
                      "Rejected",
                      _controller.rejectedDocs.value,
                      const Color(0xFFEF4444),
                      Icons.warning_amber_rounded,
                    ),
                    const SizedBox(height: 24),
                    _buildTabs(),
                    const SizedBox(height: 20),
                    _buildTabContent(),
                    const SizedBox(height: 24),
                    _buildCategories(),
                    const SizedBox(height: 24),
                    _buildVerificationProgress(),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
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
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            "Documents",
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

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statTile(String title, int count, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Text(
            "$count",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1.5),
        ),
      ),
      child: Row(
        children: [
          _tabItem("All Documents(${_controller.documents.length})", 0),
          const SizedBox(width: 24),
          _tabItem("Pending Verification(${_controller.pendingDocs.value})", 1),
        ],
      ),
    );
  }

  Widget _tabItem(String label, int index) {
    bool isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () => setState(() => _tabController.index = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: isSelected
              ? const Border(
                  bottom: BorderSide(color: Color(0xFF8B5CF6), width: 2.5),
                )
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? const Color(0xFF8B5CF6) : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    List<dynamic> docsToDisplay = _tabController.index == 0
        ? _controller.documents
        : _controller.documents
              .where((d) => d['status'].toString().toLowerCase() == 'pending')
              .toList();

    if (docsToDisplay.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD).withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.find_in_page_outlined,
              size: 40,
              color: Colors.blueGrey[300],
            ),
            const SizedBox(height: 12),
            const Text(
              "No Documents found",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: docsToDisplay.map((doc) => _buildDocCard(doc)).toList(),
    );
  }

  Widget _buildDocCard(dynamic doc) {
    String status = doc['status']?.toString() ?? 'Pending';
    String title = doc['document_name'] ?? 'Total Documents';
    String subtitle = 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: Color(0xFF2196F3),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            status,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF59E0B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAF6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Documents",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _categoryTile("ID Proof", Icons.folder_open_outlined, false),
          _categoryTile("Academic", Icons.folder_open_outlined, false),
          _categoryTile("Medical", Icons.folder_open_outlined, false),
          _categoryTile("Hostel", Icons.folder_open_outlined, false),
          _categoryTile("Financial", Icons.folder_open_outlined, true),
          _categoryTile("Others", Icons.folder_open_outlined, false),
        ],
      ),
    );
  }

  Widget _categoryTile(String title, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() => selectedCategory = title);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => UploadDocumentDialog(initialCategory: title),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF2196F3) : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF2196F3) : Colors.black87,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF2196F3) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationProgress() {
    String dateStr = _controller.lastUpdated.value != null
        ? DateFormat('d/M/yyyy HH:mm').format(_controller.lastUpdated.value!)
        : 'Never';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAF6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Verification Progress",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _controller.verificationProgress,
                          minHeight: 8,
                          backgroundColor: const Color(0xFFEEEEEE),
                          color: const Color(0xFF43A047),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "${(_controller.verificationProgress * 100).toInt()}%",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  "${_controller.verifiedDocs.value} of ${_controller.totalDocs.value} documents verified",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Last update : $dateStr",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
