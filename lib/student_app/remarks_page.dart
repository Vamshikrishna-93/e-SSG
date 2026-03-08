import 'package:flutter/material.dart';
import 'package:student_app/student_app/services/remarks_service.dart';
import 'package:student_app/student_app/widgets/loading_animation.dart';

class RemarksPage extends StatefulWidget {
  const RemarksPage({super.key});

  @override
  State<RemarksPage> createState() => _RemarksPageState();
}

class _RemarksPageState extends State<RemarksPage> {
  bool _isLoading = true;
  List<dynamic> _remarks = [];
  int _selectedTabIndex = 0;

  static const Color primaryPurple = Color(0xFF7E3FF2);

  // Stats
  int _totalCount = 0;
  int _positiveCount = 0;
  int _warningCount = 0;
  int _criticalCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData({bool forceRefresh = true}) async {
    setState(() => _isLoading = true);
    try {
      final response = await RemarksService.getRemarks(forceRefresh: forceRefresh);
      if (mounted) {
        setState(() {
          _remarks = response;
          _calculateStats();
          _isLoading = false;
        });
        if (forceRefresh) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Remarks refreshed"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to refresh: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _calculateStats() {
    _totalCount = _remarks.length;
    _positiveCount = _remarks.where((r) {
      final type =
          (r['remark_type'] ?? r['related_to'])?.toString().toLowerCase() ?? '';
      return type.contains('positive') ||
          type.contains('good') ||
          type.contains('appreciation');
    }).length;

    _warningCount = _remarks.where((r) {
      final type =
          (r['remark_type'] ?? r['related_to'])?.toString().toLowerCase() ?? '';
      return type.contains('warning') ||
          type.contains('attendance') ||
          type.contains('late');
    }).length;

    _criticalCount = _remarks.where((r) {
      final type =
          (r['remark_type'] ?? r['related_to'])?.toString().toLowerCase() ?? '';
      return type.contains('critical') ||
          type.contains('bad') ||
          type.contains('severe') ||
          type.contains('discipline');
    }).length;
  }

  List<dynamic> get _filteredRemarks {
    if (_selectedTabIndex == 0) return _remarks;
    if (_selectedTabIndex == 1) {
      return _remarks.where((r) {
        final type =
            (r['remark_type'] ?? r['related_to'])?.toString().toLowerCase() ??
            '';
        return type.contains('positive') ||
            type.contains('good') ||
            type.contains('appreciation');
      }).toList();
    }
    if (_selectedTabIndex == 2) {
      return _remarks.where((r) {
        final type =
            (r['remark_type'] ?? r['related_to'])?.toString().toLowerCase() ??
            '';
        return type.contains('warning') ||
            type.contains('attendance') ||
            type.contains('late');
      }).toList();
    }
    return _remarks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: StudentLoadingAnimation())
          : Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Remarks",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "View remarks from hostel staff",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildRefreshButton(),
                        const SizedBox(height: 20),
                        _buildStatCard(
                          "Total Remarks",
                          "$_totalCount",
                          const Color(0xFF2563EB),
                        ),
                        const SizedBox(height: 12),
                        _buildStatCard(
                          "Positive",
                          "$_positiveCount",
                          const Color(0xFF16A34A),
                        ),
                        const SizedBox(height: 12),
                        _buildStatCard(
                          "Warnings",
                          "$_warningCount",
                          const Color(0xFFF59E0B),
                        ),
                        const SizedBox(height: 12),
                        _buildStatCard(
                          "Critical",
                          "$_criticalCount",
                          const Color(0xFFEF4444),
                        ),
                        const SizedBox(height: 32),
                        _buildTabs(),
                        const SizedBox(height: 2),
                        const Divider(height: 1, color: Color(0xFFE5E7EB)),
                        const SizedBox(height: 16),
                        _buildRemarksList(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
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
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            "Remarks",
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

  Widget _buildRefreshButton() {
    return GestureDetector(
      onTap: () => _fetchData(forceRefresh: true),
      child: Container(
        width: 160,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFFD8B4FE)],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.refresh, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              "Refresh",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color valueColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        _buildTabItem("All Remarks", 0),
        const SizedBox(width: 24),
        _buildTabItem("Positive", 1, icon: Icons.check_circle_outline),
        const SizedBox(width: 24),
        _buildTabItem("Warnings", 2, icon: Icons.warning_amber_rounded),
      ],
    );
  }

  Widget _buildTabItem(String label, int index, {IconData? icon}) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Column(
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? const Color(0xFF7C3AED) : Colors.black54,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? const Color(0xFF7C3AED) : Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (isSelected)
            Container(
              height: 2,
              width: icon != null ? 85 : 80,
              color: const Color(0xFF7C3AED),
            ),
        ],
      ),
    );
  }

  Widget _buildRemarksList() {
    final remarks = _filteredRemarks;
    if (remarks.isEmpty) {
      return _buildEmptyState();
    }

    return Column(children: remarks.map((r) => _buildRemarkCard(r)).toList());
  }

  Widget _buildRemarkCard(Map<String, dynamic> remark) {
    final text = remark['remark']?.toString() ?? 'No details available';
    final rawDate = remark['created_at']?.toString() ?? '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            rawDate,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 60,
                color: Colors.black87,
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cancel,
                    size: 20,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "No Remark Found",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "There are no remarks to display at this time",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
