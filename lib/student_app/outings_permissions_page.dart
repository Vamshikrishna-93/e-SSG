import 'package:flutter/material.dart';
import 'package:student_app/student_app/outing_details_page.dart';
import 'package:student_app/student_app/services/outing_service.dart';
import 'package:student_app/student_app/widgets/loading_animation.dart';

class OutingsPermissionsPage extends StatefulWidget {
  const OutingsPermissionsPage({super.key});

  @override
  State<OutingsPermissionsPage> createState() => _OutingsPermissionsPageState();
}

class _OutingsPermissionsPageState extends State<OutingsPermissionsPage> {
  bool _isLoading = true;
  List<dynamic> _outings = [];
  int _monthlyLimit = 6;
  int _used = 0;
  String _lastOutingDate = "29 Jan 2026";
  int _selectedTabIndex = 0;

  static const Color primaryPurple = Color(0xFF7E3FF2);

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final response = await OutingService.getOutings();
      if (mounted) {
        setState(() {
          _outings = response['data'] is List ? response['data'] : [];
          _monthlyLimit = 6;
          _calculateStats();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _calculateStats() {
    final now = DateTime.now();
    _used = _outings.where((o) {
      final dateStr = o['out_date'] ?? o['date'];
      if (dateStr == null) return false;
      try {
        final date = DateTime.parse(dateStr);
        return date.month == now.month && date.year == now.year;
      } catch (e) {
        return false;
      }
    }).length;

    if (_outings.isNotEmpty) {
      final sorted = List.from(_outings);
      sorted.sort((a, b) {
        final da = DateTime.tryParse(a['out_date'] ?? '') ?? DateTime(1900);
        final db = DateTime.tryParse(b['out_date'] ?? '') ?? DateTime(1900);
        return db.compareTo(da);
      });
      final last = sorted.first;
      final dateStr = last['out_date'] ?? last['date'];
      if (dateStr != null) {
        try {
          final date = DateTime.parse(dateStr);
          _lastOutingDate = "${date.day} ${_month(date.month)} ${date.year}";
        } catch (_) {
          _lastOutingDate = dateStr;
        }
      }
    }
  }

  String _month(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
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
                          "Outing & Permission",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "View your outing records and permissions",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildRefreshButton(),
                        const SizedBox(height: 20),
                        _buildStatusBanner(),
                        const SizedBox(height: 20),
                        _buildStatCard(
                          "Monthly Limit",
                          "$_monthlyLimit outings",
                          const Color(0xFF2563EB),
                        ),
                        const SizedBox(height: 12),
                        _buildStatCard(
                          "Used",
                          "$_used",
                          const Color(0xFF16A34A),
                        ),
                        const SizedBox(height: 12),
                        _buildStatCard(
                          "Remaining",
                          "${_monthlyLimit - _used} outings",
                          const Color(0xFFF59E0B),
                        ),
                        const SizedBox(height: 12),
                        _buildStatCard(
                          "Last Outing",
                          _lastOutingDate,
                          const Color(0xFF2563EB),
                        ),
                        const SizedBox(height: 32),
                        _buildTabs(),
                        const SizedBox(height: 2),
                        const Divider(height: 1, color: Color(0xFFE5E7EB)),
                        const SizedBox(height: 16),
                        _selectedTabIndex == 0
                            ? _buildOutingTable()
                            : _buildRulesSection(),
                        const SizedBox(height: 32),
                        _buildQuickStates(),
                        const SizedBox(height: 24),
                        _buildRecentActivity(),
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
            "Outings",
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
      onTap: _fetchData,
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

  Widget _buildStatusBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "No outing this month",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "You haven't used any outing this month.",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
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
        _buildTabItem("Outing Records(${_outings.length})", 0),
        const SizedBox(width: 32),
        _buildTabItem("Rules & Guidelines", 1),
      ],
    );
  }

  Widget _buildTabItem(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? const Color(0xFF7C3AED) : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          if (isSelected)
            Container(height: 2, width: 110, color: const Color(0xFF7C3AED)),
        ],
      ),
    );
  }

  Widget _buildOutingTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 40,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      "Date",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: Text(
                      "Timing",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: Text(
                      "Purpose",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      "Action",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ..._outings.map((o) => _buildTableRow(o)),
          ],
        ),
      ),
    );
  }

  Widget _buildTableRow(Map<String, dynamic> outing) {
    final date = outing['out_date']?.toString() ?? "2025-10-27";
    final time = outing['outing_time']?.toString() ?? "06:02PM";
    final purpose = outing['purpose']?.toString() ?? "Personal";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Colors.black87,
                ),
                const SizedBox(width: 6),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              time,
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              purpose,
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 80,
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OutingDetailsPage(outing: outing),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        size: 12,
                        color: Colors.black,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "View",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesSection() {
    final rules = [
      "Maximum 8 outings per month",
      "Day outing: 8AM TO 8PM",
      "Night outings require special permission",
      "Overnight stays need parent consent",
      "Medical emergencies have priority",
      "Submit request at least 24 hours in advance",
      "Always carry your ID card during outing",
      "Inform hostel warden about any delays",
    ];

    return Column(
      children: [
        const Row(
          children: [
            Icon(Icons.info_outline, size: 20, color: Colors.black),
            SizedBox(width: 8),
            Text(
              "Outing Rules & Guidelines",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...rules.map(
          (rule) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Icon(Icons.circle, size: 8, color: Color(0xFF3B82F6)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    rule,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStates() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Text(
              "Quick States",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildQuickStateRow(
                  "Total Outing :",
                  "${_outings.length}",
                  isBold: true,
                ),
                _buildQuickStateRow(
                  "Approved :",
                  "${_outings.where((o) => o['status'].toString().toLowerCase() == 'approved').length}",
                  isBold: true,
                ),
                _buildQuickStateRow(
                  "Rejected :",
                  "${_outings.where((o) => o['status'].toString().toLowerCase() == 'rejected').length}",
                  isBold: true,
                ),
                _buildQuickStateRow(
                  "Pending :",
                  "${_outings.where((o) => o['status'].toString().toLowerCase() == 'pending').length}",
                  isBold: true,
                ),
                _buildQuickStateRow(
                  "Success Rate :",
                  _outings.isEmpty
                      ? "0%"
                      : "${((_outings.where((o) => o['status'].toString().toLowerCase() == 'approved').length / _outings.length) * 100).toStringAsFixed(0)}%",
                  isBold: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStateRow(
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Text(
              "Recent Activity",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: _outings.take(3).map((o) {
                final date = o['out_date']?.toString() ?? "N/A";
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildActivityItem("Outing ($date)"),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String text) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
