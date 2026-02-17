import 'package:flutter/material.dart';
import 'package:student_app/student_app/services/remarks_service.dart';

import 'package:student_app/student_app/student_app_bar.dart';

class RemarksPage extends StatefulWidget {
  const RemarksPage({super.key});

  @override
  State<RemarksPage> createState() => _RemarksPageState();
}

class _RemarksPageState extends State<RemarksPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _remarks = [];
  bool _isLoading = true;
  int _positiveCount = 0;
  int _warningCount = 0;
  int _criticalCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchRemarks();
  }

  List<dynamic> _positiveRemarks = [];
  List<dynamic> _warningRemarks = [];
  List<dynamic> _criticalRemarks = [];

  Future<void> _fetchRemarks({bool refresh = false}) async {
    if (!refresh && !_isLoading) setState(() => _isLoading = true);
    try {
      final remarks = await RemarksService.getRemarks();
      if (mounted) {
        setState(() {
          _remarks = remarks;

          // Categorize based on 'remark_type' if available, otherwise use 'related_to' as a fallback
          _positiveRemarks = _remarks.where((r) {
            final type =
                (r['remark_type'] ?? r['related_to'])
                    ?.toString()
                    .toLowerCase() ??
                '';
            return type.contains('positive') ||
                type.contains('good') ||
                type.contains('appreciation') ||
                type.contains('academic'); // Example fallback
          }).toList();

          _warningRemarks = _remarks.where((r) {
            final type =
                (r['remark_type'] ?? r['related_to'])
                    ?.toString()
                    .toLowerCase() ??
                '';
            return type.contains('warning') ||
                type.contains('attendance') || // Common warning trigger
                type.contains('late');
          }).toList();

          _criticalRemarks = _remarks.where((r) {
            final type =
                (r['remark_type'] ?? r['related_to'])
                    ?.toString()
                    .toLowerCase() ??
                '';
            return type.contains('critical') ||
                type.contains('bad') ||
                type.contains('severe') ||
                type.contains('discipline');
          }).toList();

          _positiveCount = _positiveRemarks.length;
          _warningCount = _warningRemarks.length;
          _criticalCount = _criticalRemarks.length;

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const StudentAppBar(title: "Remarks"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Remarks",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "View remarks from hostel staff",
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _fetchRemarks(refresh: true),
                    icon: Icon(
                      Icons.refresh,
                      size: 18,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    label: Text(
                      "Refresh",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Stats Cards Row
              Column(
                children: [
                  _StatCard(
                    title: "Total Remarks",
                    count: _remarks.length.toString(),
                    icon: Icons.chat_bubble_outline,
                    iconColor: Colors.blue,
                    countColor: Colors.blue,
                  ),

                  const SizedBox(height: 12),

                  _StatCard(
                    title: "Positive",
                    count: _positiveCount.toString(),
                    icon: Icons.check_circle,
                    iconColor: Colors.green,
                    countColor: Colors.green,
                  ),

                  const SizedBox(height: 12),

                  _StatCard(
                    title: "Warnings",
                    count: _warningCount.toString(),
                    icon: Icons.warning_amber_rounded,
                    iconColor: Colors.orange,
                    countColor: Colors.orange,
                  ),

                  const SizedBox(height: 12),

                  _StatCard(
                    title: "Critical",
                    count: _criticalCount.toString(),
                    icon: Icons.error,
                    iconColor: Colors.red,
                    countColor: Colors.red,
                  ),
                ],
              ),

              // Main Remarks Card
              Container(
                margin: const EdgeInsets.only(top: 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black.withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Tabs
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final isMobile = constraints.maxWidth < 360;

                                return TabBar(
                                  controller: _tabController,
                                  isScrollable:
                                      isMobile, // scroll only on very small screens
                                  indicator: const UnderlineTabIndicator(
                                    borderSide: BorderSide(
                                      color: Color(0xFF2563EB),
                                      width: 3,
                                    ),
                                  ),
                                  labelColor: const Color(0xFF2563EB),
                                  unselectedLabelColor:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade700,
                                  labelStyle: TextStyle(
                                    fontSize: isMobile ? 12 : 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  unselectedLabelStyle: TextStyle(
                                    fontSize: isMobile ? 12 : 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  tabs: [
                                    const Tab(text: "All Remarks"),
                                    Tab(
                                      icon: Icon(
                                        Icons.check_circle,
                                        size: isMobile ? 16 : 18,
                                      ),
                                      text: "Positive",
                                    ),
                                    Tab(
                                      icon: Icon(
                                        Icons.warning_amber_rounded,
                                        size: isMobile ? 16 : 18,
                                      ),
                                      text: "Warnings",
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),

                          IconButton(
                            icon: Icon(
                              Icons.more_vert,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade700,
                            ),
                            onPressed: () {
                              // More options
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('No more options available'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Content Area
                    SizedBox(
                      height: 400,
                      child: RefreshIndicator(
                        onRefresh: () => _fetchRemarks(refresh: true),
                        child: TabBarView(
                          controller: _tabController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            // All Remarks Tab
                            _isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : _remarks.isEmpty
                                ? const _EmptyState()
                                : _RemarksList(remarks: _remarks),
                            // Positive Tab
                            _isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : _positiveRemarks.isEmpty
                                ? const _EmptyState()
                                : _RemarksList(remarks: _positiveRemarks),
                            // Warnings Tab
                            _isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : _warningRemarks.isEmpty
                                ? const _EmptyState()
                                : _RemarksList(remarks: _warningRemarks),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color iconColor;
  final Color countColor;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.iconColor,
    required this.countColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Icon(icon, color: iconColor, size: 24)],
          ),
          const SizedBox(height: 12),
          Text(
            count,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: countColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade400
                  : Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _RemarksList extends StatelessWidget {
  final List<dynamic> remarks;
  const _RemarksList({super.key, required this.remarks});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: remarks.length,
      itemBuilder: (context, index) {
        final remark = remarks[index];
        final remarkText =
            remark['remark']?.toString() ?? 'No details available';
        final relatedTo = remark['related_to']?.toString() ?? 'General';
        final rawDate = remark['created_at']?.toString() ?? '';

        // Simple date formatting
        String dateStr = rawDate;
        if (rawDate.length >= 10) {
          try {
            final date = DateTime.parse(rawDate);
            dateStr = "${date.day}/${date.month}/${date.year}";
          } catch (_) {}
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.grey.shade100,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      relatedTo,
                      style: const TextStyle(
                        color: Color(0xFF2563EB),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      remarkText,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : const Color(0xFF334155),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade600
                  : Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              "No remarks found",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade300
                    : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "There are no remarks to display at this time",
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade500
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
