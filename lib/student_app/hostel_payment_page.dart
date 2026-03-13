import 'package:flutter/material.dart';
import 'package:student_app/student_app/services/fee_services_page.dart';

class HostelPaymentPage extends StatefulWidget {
  final double payableAmount;

  const HostelPaymentPage({super.key, required this.payableAmount});

  @override
  State<HostelPaymentPage> createState() => _HostelPaymentPageState();
}

class _HostelPaymentPageState extends State<HostelPaymentPage> {
  int selectedMethod = 0;

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get bg => Theme.of(context).scaffoldBackgroundColor;
  Color get card => Theme.of(context).cardColor;
  Color get border => Theme.of(context).dividerColor;
  Color get textPrimary =>
      Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
  Color get textSecondary =>
      Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;
  Color get primary => const Color(0xFF1677FF);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              bottom: 25,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF8B5CF6),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
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
                  "Payment",
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Payment",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Pay your hostel fees securely",
                    style: TextStyle(color: Colors.black87, fontSize: 13),
                  ),

                  const SizedBox(height: 20),

                  // PAYMENT AMOUNT CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 4,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFF97316),
                          radius: 20,
                          child: Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Payment Amount: ₹${widget.payableAmount.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "This includes all pending fee heads",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    "Select Payment Method",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 16),

                  _paymentOption(
                    index: 0,
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: const Color(0xFF8B5CF6),
                    title: "UPI Payment",
                    subtitle: "Google Pay, Phonepe, Paytm",
                  ),
                  _paymentOption(
                    index: 1,
                    icon: Icons.credit_card,
                    iconColor: const Color(0xFF3B82F6),
                    title: "Credit/Debit Card",
                    subtitle: "Visa, MasterCard, Rupay",
                  ),
                  _paymentOption(
                    index: 2,
                    icon: Icons.account_balance,
                    iconColor: const Color(0xFFF97316),
                    title: "Net Banking",
                    subtitle: "All major Indian banks",
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7C6FDF), Color(0xFFD4A0E8)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          // Show loading indicator
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          try {
                            final response =
                                await HostelFeeService.saveHostelFeePayment({
                                  'amount': widget.payableAmount.toString(),
                                  'payment_method': [
                                    'UPI',
                                    'Card',
                                    'Net Banking',
                                  ][selectedMethod],
                                });

                            if (!mounted) return;
                            Navigator.pop(context); // Close loading indicator

                            if (response is Map &&
                                (response['status'] == true ||
                                    response['success'] == true)) {
                              // Show success dialog
                              if (!mounted) return;
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: Colors.white,
                                  title: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Payment Successful",
                                        style: TextStyle(color: textPrimary),
                                      ),
                                    ],
                                  ),
                                  content: Text(
                                    response['message']?.toString() ??
                                        "Your payment of ₹${widget.payableAmount.toStringAsFixed(0)} has been processed successfully.",
                                    style: TextStyle(color: textSecondary),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context); // Close dialog
                                        Navigator.pop(
                                          context,
                                        ); // Return to fees page
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primary,
                                      ),
                                      child: const Text(
                                        "Done",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              // Show error dialog
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    (response is Map
                                            ? response['message']
                                            : null) ??
                                        'Payment failed',
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (!mounted) return;
                            Navigator.pop(context); // Close loading indicator
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        },
                        child: const Text(
                          "Pay Now",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Center(
                    child: Text(
                      "Your payment is secured with 256-bit SSL encryption",
                      style: TextStyle(color: Colors.black54, fontSize: 12),
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

  // PAYMENT OPTION TILE
  Widget _paymentOption({
    required int index,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() => selectedMethod = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(
              0xFF3B82F6,
            ), // Match image where all have blue borders
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 4,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: Radio<int>(
                value: index,
                groupValue: selectedMethod,
                onChanged: (v) => setState(() => selectedMethod = v!),
                activeColor: const Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(width: 16),
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.black87, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
