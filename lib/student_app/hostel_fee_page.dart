import 'package:flutter/material.dart';
import 'package:student_app/student_app/hostel_payment_page.dart';
import 'package:student_app/student_app/receipt_page.dart';
import 'package:student_app/student_app/services/fee_services_page.dart';
import 'package:student_app/student_app/studentdrawer.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

enum SummaryType { danger, success, warning, info }

class HostelFeesPage extends StatefulWidget {
  const HostelFeesPage({super.key});

  @override
  State<HostelFeesPage> createState() => _HostelFeesPageState();
}

class _HostelFeesPageState extends State<HostelFeesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  dynamic _feeData;
  String? _errorMessage;

  // Safe accessors
  Map<String, dynamic> get _data =>
      _feeData is Map<String, dynamic> ? _feeData : {};

  List<dynamic> get _feeDetails =>
      _data['fee_details'] is Map && _data['fee_details']['Deatls'] is List
      ? _data['fee_details']['Deatls']
      : [];

  List<dynamic> get _paymentHistory =>
      _data['payment_details'] is Map &&
          _data['payment_details']['payments'] is List
      ? _data['payment_details']['payments']
      : [];

  Map<String, dynamic> get _totals =>
      (_data['fee_details'] is Map && _data['fee_details']['Totals'] is Map)
      ? _data['fee_details']['Totals'] as Map<String, dynamic>
      : {};

  double get _totalFee =>
      double.tryParse(_totals['total_actual_fee']?.toString() ?? '0') ?? 0.0;
  double get _totalPaid =>
      double.tryParse(_totals['total_paid']?.toString() ?? '0') ?? 0.0;
  double get _totalDue =>
      double.tryParse(_totals['total_balance']?.toString() ?? '0') ?? 0.0;
  double get _totalDiscount =>
      double.tryParse(_totals['total_discount']?.toString() ?? '0') ?? 0.0;
  double get _totalCommitted =>
      double.tryParse(_totals['total_committed_fee']?.toString() ?? '0') ?? 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchData(showLoading: true, forceRefresh: false);
  }

  Future<void> _fetchData({
    bool showLoading = true,
    bool forceRefresh = true,
  }) async {
    if (showLoading && mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    try {
      final response = await HostelFeeService.getHostelFeeData(
        forceRefresh: forceRefresh,
      );
      if (mounted) {
        setState(() {
          if (response is Map<String, dynamic> && response['status'] == true) {
            _feeData = response['data'];
          } else {
            _feeData = response;
          }
          _isLoading = false;
        });
        if (forceRefresh && !showLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Fee data refreshed"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to refresh: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // BACKGROUND
  Color get bg => const Color(0xFFF8FAFC);

  // CARD SURFACE
  Color get card => Colors.white;

  // BORDER
  Color get border => const Color(0xFFE5E7EB);

  // PRIMARY TEXT
  Color get textPrimary => const Color(0xFF020617);

  // SECONDARY TEXT
  Color get textSecondary => const Color(0xFF6B7280);

  // MUTED / HINT TEXT
  Color get textMuted => const Color(0xFF9CA3AF);

  // SUCCESS (PAID)
  Color get success => const Color(0xFF16A34A);

  // WARNING (PENDING / ATTENTION)
  Color get warning => const Color(0xFFF59E0B);

  // ERROR (DUE / OVERDUE)
  Color get danger => const Color(0xFFDC2626);

  // INFO / PRIMARY ACTION
  Color get primary => const Color(0xFF1677FF);

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      drawer: const StudentDrawerPage(),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              left: 25,
              right: 20,
              bottom: 20,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF8B5CF6),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    // Check if drawer is open, if not pop context or open drawer depending on needs,
                    // image shows back arrow, but drawer was previous behavior. I will match image (back arrow to pop, or open drawer).
                    // Given we have a StudentDrawerPage, a back button might pop or open it. Image shows back arrow.
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
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
                  "Hostel Fees",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
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
                : RefreshIndicator(
                    onRefresh: () => _fetchData(showLoading: false),
                    child: SafeArea(
                      top:
                          false, // Don't add top padding here since our custom header handles it
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _header(),
                            const SizedBox(height: 16),
                            _summaryCard(
                              type: SummaryType.danger,
                              title: "Total Due Amount",
                              value: "₹${_totalDue.toStringAsFixed(0)}",
                              badgeText: "Immediate attention required",
                            ),
                            const SizedBox(height: 16),
                            _summaryCard(
                              type: SummaryType.success,
                              title: "Total Paid Amount",
                              value: "₹${_totalPaid.toStringAsFixed(0)}",
                              badgeText:
                                  "${(_totalFee > 0 ? (_totalPaid / _totalFee * 100) : 0).toStringAsFixed(1)}% of total fee paid",
                            ),
                            const SizedBox(height: 16),
                            _summaryCard(
                              type: SummaryType.warning,
                              title: "Next Due Date",
                              value:
                                  _data['next_due_date']?.toString() ??
                                  "Immediate Payment Required",
                              badgeText: _totalDue > 0
                                  ? "Payment pending"
                                  : "No dues",
                            ),
                            const SizedBox(height: 16),
                            _summaryCard(
                              type: SummaryType.info,
                              title: "Payment Status",
                              value: _totalDue > 0 ? "Pending" : "Completed",
                              badgeText:
                                  "Total Fee: ₹${_totalFee.toStringAsFixed(0)}",
                            ),
                            const SizedBox(height: 28),
                            _tabsSection(),
                            const SizedBox(height: 28),
                            _quickPayCard(),
                            const SizedBox(height: 24),
                            _feeSummaryCard(),
                            const SizedBox(height: 28),
                            _branchSummaryCard(),
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

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Hostel Fees & Payments",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Manage your hostel fees, track payments, and view receipts",
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _customBtn(Icons.refresh, "Refresh", [
                const Color(0xFF9F7AEA),
                const Color(0xFFD6BCFA),
              ], () => _fetchData(showLoading: false, forceRefresh: true)),
              const SizedBox(width: 8),
              _customBtn(Icons.print, "Print Statement", [
                const Color(0xFF48BB78),
                const Color(0xFF9AE6B4),
              ], () => _toast("Statement sent")),
              const SizedBox(width: 8),
              _customBtn(Icons.download, "Export History", [
                const Color(0xFF38B2AC),
                const Color(0xFF81E6D9),
              ], () => _toast("Exporting...")),
            ],
          ),
        ),
      ],
    );
  }

  Widget _customBtn(
    IconData icon,
    String label,
    List<Color> gradientColors,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 16),
        label: Text(label, style: const TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
    );
  }

  // ================= SUMMARY CARD =================

  Widget _summaryCard({
    required SummaryType type,
    required String title,
    required String value,
    required String badgeText,
  }) {
    Color valueColor;
    Color badgeBg;
    Color badgeTextColor;

    switch (type) {
      case SummaryType.danger:
        valueColor = const Color(0xFFEF4444);
        badgeBg = const Color(0xFFFFE4E6);
        badgeTextColor = const Color(0xFFEF4444);
        break;
      case SummaryType.success:
        valueColor = const Color(0xFF22C55E);
        badgeBg = const Color(0xFFDCFCE7);
        badgeTextColor = const Color(0xFF22C55E);
        break;
      case SummaryType.warning:
        valueColor = const Color(0xFFF97316);
        badgeBg = const Color(0xFFFFEDD5);
        badgeTextColor = const Color(0xFFF97316);
        break;
      case SummaryType.info:
        valueColor = const Color(0xFF3B82F6);
        badgeBg = const Color(0xFFDBEAFE);
        badgeTextColor = const Color(0xFF3B82F6);
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badgeText,
              style: TextStyle(fontSize: 12, color: badgeTextColor),
            ),
          ),
        ],
      ),
    );
  }

  // ================= TABS + TABLE =================

  Widget _tabsSection() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF8B5CF6),
          unselectedLabelColor: Colors.black87,
          indicatorColor: const Color(0xFF8B5CF6),
          isScrollable: true,
          tabs: const [
            Tab(text: "Current Fees"),
            Tab(text: "Payment History"),
            Tab(text: "Payment By Head"),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 600,
          child: TabBarView(
            controller: _tabController,
            children: [
              currentFeesScrollableTable(),
              paymentHistoryView(),
              _paymentByHeadCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget currentFeesScrollableTable() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_totalDue > 0)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFF97316),
                    radius: 14,
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "₹ ${_totalDue.toStringAsFixed(0)} Payment Pending",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "Please make the payment at the earliest to avoid any inconvenience",
                          style: TextStyle(color: Colors.black54, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              HostelPaymentPage(payableAmount: _totalDue),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      minimumSize: const Size(0, 0),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Pay Now",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              width: 800,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        _buildHeaderCell("Fee Head", 3),
                        _buildHeaderCell("Total Amount", 2),
                        _buildHeaderCell("Paid Amount", 2),
                        _buildHeaderCell("Balance", 2),
                        _buildHeaderCell("Status", 2),
                        _buildHeaderCell("Actions", 2),
                      ],
                    ),
                  ),
                  if (_feeDetails.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text("No fee details available"),
                    ),
                  ..._feeDetails.map((fee) {
                    final balance =
                        double.tryParse(
                          fee['balance_fee']?.toString() ?? '0',
                        ) ??
                        0;
                    return _feeRow(
                      head: fee['feehead']?.toString() ?? 'Unknown',
                      committed: "₹${fee['commit'] ?? 0}",
                      total: "₹${fee['fee'] ?? 0}",
                      paid: "₹${fee['paid_fee'] ?? 0}",
                      balance: "₹${fee['balance_fee'] ?? 0}",
                      pending: balance > 0,
                      balanceValue: balance,
                      discount: "₹${fee['discount_amount'] ?? 0}",
                    );
                  }),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    child: Row(
                      children: [
                        _buildGrandTotalCell("Grand Total", 3),
                        _buildGrandTotalCell(
                          "₹${_totalFee.toStringAsFixed(0)}",
                          2,
                        ),
                        _buildGrandTotalCell(
                          "₹${_totalPaid.toStringAsFixed(0)}",
                          2,
                          color: const Color(0xFF16A34A),
                        ),
                        _buildGrandTotalCell(
                          "₹${_totalDue.toStringAsFixed(0)}",
                          2,
                          color: const Color(0xFFEF4444),
                        ),
                        const Expanded(flex: 4, child: SizedBox()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _feeRow({
    required String head,
    required String committed,
    required String total,
    required String paid,
    required String balance,
    bool pending = false,
    double balanceValue = 0.0,
    required String discount,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              head,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
          _cell(total, const Color(0xFF16A34A), 2),
          _cell(paid, const Color(0xFF16A34A), 2),
          _cell(
            balance,
            pending ? const Color(0xFFEF4444) : const Color(0xFF16A34A),
            2,
          ),
          Expanded(
            flex: 2,
            child: pending
                ? _tag(
                    "Pending",
                    const Color(0xFFF97316),
                    const Color(0xFFFFEDD5),
                  )
                : _tag(
                    "Paid",
                    const Color(0xFF22C55E),
                    const Color(0xFFDCFCE7),
                  ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                if (pending)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              HostelPaymentPage(payableAmount: balanceValue),
                        ),
                      ).then((_) => _fetchData());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: const Size(0, 0),
                    ),
                    child: const Text(
                      "Pay Now",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (context, _, __) => ReceiptPage(
                            data: {
                              'amount': paid,
                              'receipt_no':
                                  "STMT-${head.replaceAll(RegExp(r'[^a-zA-Z]'), '').substring(0, 3).toUpperCase()}-${DateTime.now().year}",
                              'date': DateTime.now().toString().split(' ')[0],
                            },
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.receipt,
                      size: 14,
                      color: Colors.black,
                    ),
                    label: const Text(
                      "Receipt",
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      minimumSize: const Size(0, 0),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cell(String text, Color color, int flex) => Expanded(
    flex: flex,
    child: Text(
      text,
      style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 13),
    ),
  );

  Widget _tag(String text, Color textColor, Color bgColor) => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );

  Widget _buildHeaderCell(String text, int flex) => Expanded(
    flex: flex,
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontSize: 13,
      ),
    ),
  );

  Widget _buildGrandTotalCell(String text, int flex, {Color? color}) =>
      Expanded(
        flex: flex,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black,
            fontSize: 13,
          ),
        ),
      );

  // ================= PAYMENT HISTORY =================

  Widget paymentHistoryView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Transaction: ${_paymentHistory.length}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Total Paid: ₹${_totalPaid.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Showing payments distribution\nacross all fee categories",
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 800,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        _HeaderPH("S.No", 1),
                        _HeaderPH("Date", 2),
                        _HeaderPH("Invoice No.", 2),
                        _HeaderPH("Branch", 2),
                        _HeaderPH("Amount", 2),
                        _HeaderPH("Mode", 2),
                        _HeaderPH("Status", 2),
                        _HeaderPH("Actions", 1),
                      ],
                    ),
                  ),
                  if (_paymentHistory.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text("No payment history available"),
                    ),
                  ..._paymentHistory.map((payment) => _paymentRow(payment)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- HELPERS ----------------

  Widget _HeaderPH(String text, int flex) => Expanded(
    flex: flex,
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontSize: 13,
      ),
    ),
  );

  Widget _paymentRow(Map<String, dynamic> payment) {
    final date = payment['date']?.toString() ?? '';
    final invoice = payment['invoice']?.toString() ?? '';
    final amount = "₹${payment['amount'] ?? 0}";
    final mode = payment['mode']?.toString() ?? 'Online';
    final status = payment['status']?.toString() ?? 'Paid';
    final branch = payment['branch']?.toString() ?? '';
    final viewUrl = payment['view_url']?.toString() ?? '';
    final sno = payment['sno']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          _cellPH(sno, 1),
          _cellPH(date, 2),
          _cellPH(invoice, 2),
          _cellPH(branch, 2),
          _cellPH(amount, 2, color: const Color(0xFF16A34A), bold: true),
          _tagPH(mode, 2, const Color(0xFFF97316), const Color(0xFFFFEDD5)),
          _tagPH(status, 2, const Color(0xFF22C55E), const Color(0xFFDCFCE7)),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.remove_red_eye,
                  color: Color(0xFF3B82F6),
                  size: 16,
                ),
                onPressed: () async {
                  if (viewUrl.isNotEmpty) {
                    final Uri url = Uri.parse(viewUrl);
                    if (await canLaunchUrl(url))
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                  } else {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (context, _, __) => ReceiptPage(
                          data: {
                            'amount': amount,
                            'receipt_no': invoice,
                            'date': date,
                            'sno': sno,
                          },
                        ),
                      ),
                    );
                  }
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(
                  Icons.download,
                  color: Color(0xFF3B82F6),
                  size: 16,
                ),
                onPressed: () => _toast("Downloading receipt..."),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cellPH(
    String text,
    int flex, {
    Color? color,
    bool bold = false,
    bool link = false,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          color: color ?? Colors.black,
          fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _tagPH(String text, int flex, Color textColor, Color bgColor) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _paymentByHeadCard() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFF3B82F6),
                  radius: 14,
                  child: Icon(Icons.info, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Payment Breakdown by Fee Head",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "This shows how your total payments are distributed across different fee categories.",
                        style: TextStyle(fontSize: 11, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Fee Heads: ${(_data['payments'] is List ? _data['payments'].length : 0)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Total Paid: ₹${_totalPaid.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Showing payments distribution\nacross all fee categories",
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 800,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: const [
                        Expanded(
                          flex: 3,
                          child: Text(
                            "Fee Head",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "Amount Paid",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "Percentage",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: SizedBox(),
                        ), // removed Contribution column header to match space if needed, wait Image says "Fee Head" and "Amount Paid" ONLY inside gray header.
                      ],
                    ),
                  ),
                  if (_feeDetails.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text("No fee details available"),
                    ),
                  ...(_data['payments'] is List ? _data['payments'] : []).map((
                    payment,
                  ) {
                    final paid =
                        double.tryParse(
                          payment['sum_amount']?.toString() ?? '0',
                        ) ??
                        0;
                    return paymentByHeadData(
                      payment['feehead']?.toString() ?? 'Unknown',
                      "₹${paid.toStringAsFixed(0)}",
                      paid == 500
                          ? const Color(0xFF9333EA)
                          : const Color(
                              0xFF16A34A,
                            ), // Use purple for Application fee, green otherwise
                    );
                  }),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    child: Row(
                      children: [
                        const Expanded(
                          flex: 3,
                          child: Text(
                            "Total Payment",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "₹${_totalPaid.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF16A34A),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Expanded(flex: 2, child: SizedBox()),
                        const Expanded(flex: 3, child: SizedBox()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Payment Distribution Visualization",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          ...(_data['payments'] is List ? _data['payments'] : []).map((
            payment,
          ) {
            final paid =
                double.tryParse(payment['sum_amount']?.toString() ?? '0') ?? 0;
            final percentage = _totalPaid > 0 ? paid / _totalPaid : 0.0;
            return visualRow(
              payment['feehead']?.toString() ?? 'Unknown',
              "₹${paid.toStringAsFixed(0)} (${(percentage * 100).toStringAsFixed(1)}%)",
              percentage,
              Colors.blue, // Image 4 shows blue bars and blue text for both
            );
          }),
        ],
      ),
    );
  }

  Widget paymentByHeadData(String head, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              head,
              style: const TextStyle(fontSize: 13, color: Colors.black),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              amount,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: color,
                fontSize: 13,
              ),
            ),
          ),
          const Expanded(flex: 2, child: SizedBox()),
          const Expanded(flex: 3, child: SizedBox()),
        ],
      ),
    );
  }

  Widget visualRow(String label, String value, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  // ================= FEE SUMMARY =================

  Widget _feeSummaryCard() {
    final double progress = _totalFee > 0 ? _totalPaid / _totalFee : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFEBE6FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Text(
              "Fee Summary",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 14,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                row("Total Fee", "₹${_totalFee.toStringAsFixed(0)}"),
                const SizedBox(height: 6),
                row("Discount", "₹${_totalDiscount.toStringAsFixed(0)}"),
                const SizedBox(height: 6),
                row("Committed Fee", "₹${_totalCommitted.toStringAsFixed(0)}"),
                const SizedBox(height: 16),
                row(
                  "Total Paid",
                  "₹${_totalPaid.toStringAsFixed(0)}",
                  valueColor: const Color(0xFF16A34A),
                ),
                const SizedBox(height: 6),
                row(
                  "Total Due",
                  "₹${_totalDue.toStringAsFixed(0)}",
                  valueColor: const Color(0xFFEF4444),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      "Payment Progress",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF22C55E),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "${(progress * 100).toStringAsFixed(0)}%",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= BRANCH SUMMARY =================

  Widget _branchSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFEBE6FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Text(
              "Branch Summary",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 14,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...(_data['branches'] is List ? _data['branches'] : []).map((
                  branch,
                ) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          branch['branch_name']?.toString() ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Total Paid : ₹${branch['sum_amount']?.toString() ?? '0'}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= COMMON ROW =================

  Widget row(
    String label,
    String value, {
    Color valueColor = const Color(0xFF111827),
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$label :",
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _quickPayCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // matching image style
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFEBE6FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Text(
              "Quick Pay",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 14,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Image.network(
                  "https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=HostelPayment_$_totalDue",
                  height: 160,
                  width: 160,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.qr_code_2,
                    size: 160,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Scan QR Code to pay via UPI",
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              HostelPaymentPage(payableAmount: _totalDue),
                        ),
                      );
                    },
                    icon: const Icon(Icons.credit_card, size: 18),
                    label: const Text(
                      "Pay Now",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _paymentMethodButton(
                  icon: Icons.account_balance,
                  label: "Net Banking",
                  onTap: () => _toast("Net Banking selected"),
                ),
                const SizedBox(height: 12),
                _paymentMethodButton(
                  icon: Icons.phone_android, // phone icon
                  label: "UPI Payment",
                  onTap: () => _toast("UPI Payment selected"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentMethodButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6), // subtle radius like image
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.black),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
