import 'package:flutter/material.dart';
import 'package:student_app/student_app/services/documents_service.dart';
import 'package:student_app/student_app/student_app_bar.dart';
import 'package:student_app/student_app/upload_document_dialog.dart';
import 'package:student_app/theme_controllers.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _documents = [];

  int totalDocs = 0;
  int verifiedDocs = 0;
  int pendingDocs = 0;
  int rejectedDocs = 0;
  DateTime? _lastUpdated;

  String selectedCategory = "Financial";

  final List<String> categories = [
    "ID Proof",
    "Academic",
    "Medical",
    "Hostel",
    "Financial",
    "Other",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await DocumentsService.getDocuments();
      if (mounted) {
        setState(() {
          // Map data using correct keys from API response
          if (data['success'] == true) {
            _documents = data['documents'] ?? [];
            totalDocs = data['total_docs'] ?? _documents.length;
          } else {
            _documents = [];
            totalDocs = 0;
          }

          // Update stats based on status strings in fetched data
          verifiedDocs = _documents
              .where(
                (d) =>
                    d['status'].toString().toLowerCase() == 'approved' ||
                    d['status'].toString().toLowerCase() == 'verified',
              )
              .length;
          pendingDocs = _documents
              .where((d) => d['status'].toString().toLowerCase() == 'pending')
              .length;
          rejectedDocs = _documents
              .where((d) => d['status'].toString().toLowerCase() == 'rejected')
              .length;

          _lastUpdated = DateTime.now();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // ================= COLORS (THEME AWARE) =================

  Color get bg => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF0F172A)
      : const Color(0xFFF8FAFC);

  Color get card => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF020617)
      : Colors.white;

  Color get border => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF1E293B)
      : const Color(0xFFE5E7EB);

  Color get textPrimary => Theme.of(context).brightness == Brightness.dark
      ? Colors.white
      : const Color(0xFF020617);

  Color get textSecondary => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF94A3B8)
      : const Color(0xFF6B7280);

  // ================= ACTIONS =================

  void _refreshData() {
    _fetchData();
  }

  double get verificationProgress =>
      totalDocs == 0 ? 0 : verifiedDocs / totalDocs;

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return ThemeControllerWrapper(
      themeController: StudentThemeController.themeMode,
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: bg,
            appBar: const StudentAppBar(title: ""),
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Error: $_errorMessage"),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchData,
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  )
                : SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _header(),
                          const SizedBox(height: 24),
                          _statCard(
                            title: "Total Documents",
                            count: totalDocs,
                            icon: Icons.folder_outlined,
                            color: const Color(0xFF2563EB),
                          ),
                          _statCard(
                            title: "Verified",
                            count: verifiedDocs,
                            icon: Icons.check_circle_outline,
                            color: const Color(0xFF22C55E),
                          ),
                          _statCard(
                            title: "Pending",
                            count: pendingDocs,
                            icon: Icons.access_time,
                            color: const Color(0xFFF59E0B),
                          ),
                          _statCard(
                            title: "Rejected",
                            count: rejectedDocs,
                            icon: Icons.warning_amber_rounded,
                            color: const Color(0xFFEF4444),
                          ),
                          const SizedBox(height: 28),
                          _tabsSection(),
                          const SizedBox(height: 28),
                          _categoriesSection(),
                          const SizedBox(height: 28),
                          _verificationProgress(),
                        ],
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  // ================= HEADER =================

  Widget _header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.folder_outlined, size: 28, color: textPrimary),
              const SizedBox(height: 12),
              Text(
                "Documents",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Manage your student\n"
                "documents and\n"
                "verifications",
                style: TextStyle(
                  fontSize: 14,
                  height: 1.55,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) =>
                      const UploadDocumentDialog(initialCategory: ''),
                );
              },
              icon: const Icon(Icons.upload, size: 18),
              label: const Text("Upload Document"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text("Refresh"),
              style: OutlinedButton.styleFrom(
                foregroundColor: textPrimary,
                side: BorderSide(color: border),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ================= STATS =================

  Widget _statCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textPrimary,
              ),
            ),
          ),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ================= TABS =================

  Widget _tabsSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF2563EB),
            unselectedLabelColor: textSecondary,
            indicatorColor: const Color(0xFF2563EB),
            indicatorWeight: 2,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              Tab(text: "All Documents ($totalDocs)"),
              Tab(text: "Pending Verification ($pendingDocs)"),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 120,
            child: TabBarView(
              controller: _tabController,
              children: [
                _documentList(_documents),
                _documentList(
                  _documents
                      .where(
                        (d) =>
                            d['status'].toString().toLowerCase() == 'pending',
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.inbox_outlined, size: 44, color: border),
        const SizedBox(height: 10),
        Text(
          "No documents found",
          style: TextStyle(fontSize: 14, color: textSecondary),
        ),
      ],
    );
  }

  Widget _documentList(List<dynamic> docs) {
    if (docs.isEmpty) return _emptyState();

    return ListView.builder(
      itemCount: docs.length,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemBuilder: (context, index) {
        final doc = docs[index];
        // Handle dynamic keys (fallback for outings vs documents)
        final title =
            doc['document_name'] ??
            doc['outing_type'] ??
            doc['reason'] ??
            'Document';
        final date =
            doc['created_at'] ?? doc['date'] ?? doc['out_time'] ?? 'N/A';
        final status = doc['status']?.toString() ?? 'Pending';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: Color(0xFF2563EB),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                  ],
                ),
              ),
              _statusBadge(status),
            ],
          ),
        );
      },
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'approved':
      case 'verified':
        color = const Color(0xFF22C55E);
        break;
      case 'rejected':
        color = const Color(0xFFEF4444);
        break;
      default:
        color = const Color(0xFFF59E0B);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ================= CATEGORIES =================

  Widget _categoriesSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Document Categories",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          ...categories.map(_categoryTile),
        ],
      ),
    );
  }

  Widget _categoryTile(String title) {
    final bool selected = title == selectedCategory;

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
        height: 44,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFF2563EB) : border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_outlined,
              size: 18,
              color: selected ? const Color(0xFF2563EB) : textPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: selected ? const Color(0xFF2563EB) : textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= PROGRESS =================

  Widget _verificationProgress() {
    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            child: Text(
              "Verification Progress",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ),

          Divider(height: 1, color: border),

          // BODY
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PROGRESS ROW
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: verificationProgress,
                          minHeight: 8,
                          backgroundColor: border,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "${(verificationProgress * 100).round()}%",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // VERIFIED TEXT
                Text(
                  "$verifiedDocs of $totalDocs documents verified",
                  style: TextStyle(fontSize: 14, color: textSecondary),
                ),

                const SizedBox(height: 10),

                // LAST UPDATED
                Text(
                  "Last updated: ${_lastUpdated != null ? "${_lastUpdated!.day}/${_lastUpdated!.month}/${_lastUpdated!.year} ${_lastUpdated!.hour}:${_lastUpdated!.minute.toString().padLeft(2, '0')}" : "Never"}",
                  style: TextStyle(fontSize: 12, color: textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
