import 'package:flutter/material.dart';

class ReceiptPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const ReceiptPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 16,
                  left: 24,
                  right: 16,
                  bottom: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Color(0xFF4ADE80),
                      child: Icon(Icons.check, color: Colors.white, size: 36),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Payment Successful",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4ADE80),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['amount']?.toString() ?? "₹0",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Divider(color: Colors.grey.shade300, thickness: 1),
                    const SizedBox(height: 24),
                    _row(
                      "Receipt No",
                      data['receipt_no']?.toString() ?? "N/A",
                      Colors.black87,
                      Colors.black54,
                    ),
                    const SizedBox(height: 16),
                    _row(
                      "Date",
                      data['date']?.toString() ?? "N/A",
                      Colors.black87,
                      Colors.black54,
                    ),
                    const SizedBox(height: 16),
                    _row(
                      "Status",
                      "Completed",
                      const Color(0xFF4ADE80),
                      Colors.black54,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7C6FDF), Color(0xFFD4A0E8)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 4,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Download successful"),
                                backgroundColor: Color(0xFF4ADE80),
                              ),
                            );
                            Navigator.pop(
                              context,
                            ); // Pop back to hostel fee page
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Download Receipt",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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

  Widget _row(
    String label,
    String value,
    Color? valueColor,
    Color? labelColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
