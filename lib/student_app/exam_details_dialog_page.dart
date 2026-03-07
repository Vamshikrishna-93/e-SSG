import 'package:flutter/material.dart';

class ExamDetailsPhysicsDialog extends StatefulWidget {
  const ExamDetailsPhysicsDialog({super.key});

  @override
  State<ExamDetailsPhysicsDialog> createState() =>
      _ExamDetailsPhysicsDialogState();
}

class _ExamDetailsPhysicsDialogState extends State<ExamDetailsPhysicsDialog> {
  @override
  Widget build(BuildContext context) {
    const isMobile = true; // Defaulting for simple static UI or compute as needed
    const scaffoldBackgroundColor = Color(0xFFF8FAFC);
    const cardColor = Colors.white;
    const dividerColor = Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 20,
          ),
          child: Material(
            elevation: 24,
            shadowColor: Colors.black.withOpacity(0.45),
            borderRadius: BorderRadius.circular(14),
            color: cardColor,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 600,
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// HEADER
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
                      child: Row(
                        children: [
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF1E293B),
                                fontWeight: FontWeight.w500,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Exam Details - ',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                  text: 'PHYSICS',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),

                    const Divider(color: dividerColor),

                    /// SUMMARY CARDS
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(children: _summaryCards(isMobile)),
                    ),

                    /// TABLE
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: dividerColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            _tableHeader(dividerColor),
                            _tableRow(
                              dividerColor: dividerColor,
                              exam: 'weekend Exam',
                              marks: '-1/5',
                              percentage: '0.00%',
                              showBar: true,
                              status: '',
                            ),
                            _tableRow(
                              dividerColor: dividerColor,
                              exam: 'Total',
                              marks: '-1/5',
                              percentage: '-20.00%',
                              status: 'Needs Improvement',
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// FOOTER
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Row(
                        children: [
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.download, size: 18),
                            label: const Text('Download PDF'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// SUMMARY CARDS (COLUMN ON MOBILE)
  List<Widget> _summaryCards(bool isMobile) {
    return [
      _summaryCard(
        title: 'Total Exams',
        value: '1',
        icon: Icons.check_circle,
        bg: Colors.blue.withOpacity(0.08),
        iconColor: Colors.blue,
        isMobile: isMobile,
      ),
      _gap(isMobile),
      _summaryCard(
        title: 'Average Score',
        value: '0.0 %',
        icon: Icons.trending_down,
        bg: Colors.green.withOpacity(0.10),
        iconColor: Colors.green,
        isMobile: isMobile,
      ),
      _gap(isMobile),
      _summaryCard(
        title: 'Best Performance',
        value: '0.0 %',
        icon: Icons.star,
        bg: Colors.orange.withOpacity(0.12),
        iconColor: Colors.orange,
        isMobile: isMobile,
      ),
    ];
  }

  Widget _gap(bool isMobile) =>
      SizedBox(height: isMobile ? 12 : 0, width: isMobile ? 0 : 12);

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color bg,
    required Color iconColor,
    required bool isMobile,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: bg.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// TABLE
  Widget _tableHeader(Color dividerColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      color: dividerColor.withOpacity(0.05),
      child: Row(
        children: const [
          Expanded(child: Text('Exam Name')),
          Expanded(child: Text('Marks')),
          Expanded(child: Text('Percentage')),
          Expanded(child: Text('Status')),
        ],
      ),
    );
  }

  Widget _tableRow({
    required Color dividerColor,
    required String exam,
    required String marks,
    required String percentage,
    String status = '',
    bool showBar = false,
    bool isTotal = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              exam,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.w600 : null,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              marks,
              style: const TextStyle(color: Color(0xFF1E293B)),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  percentage,
                  style: const TextStyle(color: Color(0xFF1E293B)),
                ),
                if (showBar)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    height: 6,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: status.isEmpty
                ? const SizedBox()
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Needs Improvement',
                      style: TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
