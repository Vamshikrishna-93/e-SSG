import 'package:flutter/material.dart';
import 'package:student_app/student_app/full_image_view_page.dart';

class OutingDetailsPage extends StatelessWidget {
  final Map<String, dynamic> outing;

  const OutingDetailsPage({super.key, required this.outing});

  @override
  Widget build(BuildContext context) {
    // Parse data safely
    final dateStr = outing['out_date']?.toString() ?? '2025-10-27';
    final outTime = outing['outing_time'] ?? '12:23:00';
    final reportTime = outing['in_report'] ?? "Not Reported";
    final purpose = outing['purpose'] ?? 'Personal';
    final type = outing['outingtype'] ?? 'Home Pass';
    final status = outing['status']?.toString().toUpperCase() ?? 'APPROVED';
    final permissionId =
        outing['permission']?.toString() ?? outing['id']?.toString() ?? '2849';
    final createdAt = outing['created_at']?.toString() ?? "29 Jan 2026 6:03 PM";
    final lastUpdated =
        outing['updated_at']?.toString() ?? "23 Jan 2026 11:04 AM";

    final isHomePass = type.toString().toLowerCase().contains('home');

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailsGrid(context, {
                    'date': dateStr,
                    'type': type,
                    'isHomePass': isHomePass,
                    'outTime': outTime,
                    'reportTime': reportTime,
                    'purpose': purpose,
                    'permissionId': permissionId,
                    'status': status,
                    'createdAt': createdAt,
                    'lastUpdated': lastUpdated,
                  }),
                  const SizedBox(height: 32),
                  const Text(
                    "Documents",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDocumentCard(
                          context,
                          "Permission Lett..",
                          Icons.description_outlined,
                          outing['letterpic']?.toString() ??
                              "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&q=80&w=2070",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDocumentCard(
                          context,
                          "Guardian Cons..",
                          Icons.person_pin_outlined,
                          outing['guardianpic']?.toString() ??
                              "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&q=80&w=2073",
                        ),
                      ),
                    ],
                  ),
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
        color: Color(0xFF7C3AED),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
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
            "Outing Details",
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

  Widget _buildDetailsGrid(BuildContext context, Map<String, dynamic> data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          _buildGridRow([
            _buildGridCell(
              "Date",
              data['date'],
              icon: Icons.calendar_today_outlined,
            ),
            _buildGridCell(
              "Outing Type",
              data['type'],
              isHomePass: data['isHomePass'],
              showTypeBadge: true,
            ),
          ]),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          _buildGridRow([
            _buildGridCell(
              "Departure Time",
              data['outTime'],
              icon: Icons.access_time,
            ),
            _buildGridCell(
              "Return Time(Reported)",
              data['reportTime'],
              icon: Icons.access_time,
            ),
          ]),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          _buildGridRow([
            _buildGridCell("Purpose", data['purpose']),
            _buildGridCell(
              "Permission ID",
              data['permissionId'],
              showIdBadge: true,
            ),
          ]),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          _buildGridRow([
            _buildGridCell("Status", data['status'], showStatusBadge: true),
            _buildGridCell("Created At", data['createdAt']),
          ]),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: double.infinity),
                const Text(
                  "Last Updated",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data['lastUpdated'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridRow(List<Widget> children) {
    return IntrinsicHeight(
      child: Row(
        children: children.asMap().entries.map((entry) {
          int idx = entry.key;
          Widget child = entry.value;
          return Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: idx < children.length - 1
                    ? const Border(right: BorderSide(color: Color(0xFFE5E7EB)))
                    : null,
              ),
              child: child,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGridCell(
    String label,
    String value, {
    IconData? icon,
    bool showTypeBadge = false,
    bool isHomePass = false,
    bool showStatusBadge = false,
    bool showIdBadge = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          if (showTypeBadge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B82F6),
                ),
              ),
            )
          else if (showStatusBadge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF16A34A),
                ),
              ),
            )
          else if (showIdBadge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEF4444),
                ),
              ),
            )
          else
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: Colors.black87),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(
    BuildContext context,
    String title,
    IconData icon,
    String imageUrl,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(icon, size: 16, color: Colors.black87),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          ClipRRect(
            child: Image.network(
              imageUrl,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                height: 100,
                color: Colors.grey[100],
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        FullImageViewPage(imageUrl: imageUrl, title: title),
                  ),
                );
              },
              child: const Text(
                "View Full Image",
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
