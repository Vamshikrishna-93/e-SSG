import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_app/staff_app/controllers/profile_controller.dart';
import 'package:student_app/staff_app/widgets/staff_bottom_nav_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  static const LinearGradient darkHeaderGradient = LinearGradient(
    colors: [
      Color(0xFF1a1a2e),
      Color(0xFF16213e),
      Color(0xFF0f3460),
      Color(0xFF533483),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF0f3460), Color(0xFF533483)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileController controller;
  int? selectedTabIndex; // Null means show menu

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<ProfileController>()) {
      controller = Get.find<ProfileController>();
    } else {
      controller = Get.put(ProfileController(), permanent: true);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchProfile();
      controller.changeIndex(3);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value || controller.profile.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF7E49FF)),
          );
        }

        final p = controller.profile.value!;

        // If a tab is selected, show the detail view
        if (selectedTabIndex != null) {
          return _buildDetailView(selectedTabIndex!, isDark);
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. Purple Header
                  Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 10,
                      bottom: 25,
                      left: 20,
                      right: 20,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFF7E49FF),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(
                            Icons.account_circle_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Profile",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. Profile Card (Overlapping)
                  Positioned(
                    top: 170,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 55, 20, 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F2FF),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            p.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _infoText("Email :", p.email),
                          _infoText("Phone Number :", p.mobile),
                          _infoText("User ID :", p.userLogin),
                        ],
                      ),
                    ),
                  ),

                  // 3. Circular Avatar (Overlapping Card)
                  Positioned(
                    top: 120,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: ClipOval(
                            child:
                                p.avatar.isNotEmpty && p.avatar != "avatar.png"
                                ? Image.network(
                                    "https://dev.srisaraswathigroups.in/uploads/${p.avatar}",
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.person,
                                              size: 60,
                                              color: Colors.grey,
                                            ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Spacer to handle the overlap
              const SizedBox(height: 250),

              // 4. Action List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.grey.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _actionItem(
                        "Profile",
                        () => setState(() => selectedTabIndex = 0),
                      ),
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      _actionItem(
                        "Attendance",
                        () => setState(() => selectedTabIndex = 1),
                      ),
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      _actionItem(
                        "Pay Scale",
                        () => setState(() => selectedTabIndex = 2),
                      ),
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      _actionItem(
                        "Leaves",
                        () => setState(() => selectedTabIndex = 3),
                      ),
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      _actionItem(
                        "Change Password",
                        () => setState(() => selectedTabIndex = 4),
                      ),
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      _actionItem(
                        "TFA",
                        () => setState(() => selectedTabIndex = 5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
      bottomNavigationBar: const StaffBottomNavBar(),
    );
  }

  Widget _buildDetailView(int index, bool isDark) {
    String title = "";
    Widget content = const SizedBox();

    switch (index) {
      case 0:
        title = "Profile";
        content = ProfileTab(isDark: isDark);
        break;
      case 1:
        title = "Attendance";
        content = AttendanceTab(isDark: isDark);
        break;
      case 2:
        title = "Pay Scale";
        content = PayScaleTab(isDark: isDark);
        break;
      case 3:
        title = "Leaves";
        content = LeavesTab(isDark: isDark);
        break;
      case 4:
        title = "Change Password";
        content = ChangePasswordTab(isDark: isDark);
        break;
      case 5:
        title = "TFA";
        content = TfaTab(isDark: isDark);
        break;
    }

    return Column(
      children: [
        Container(
          height: 80,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF7E49FF),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                const SizedBox(width: 10),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
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
                  onPressed: () => setState(() => selectedTabIndex = null),
                ),
                const SizedBox(width: 5),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: content),
      ],
    );
  }

  Widget _infoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
          children: [
            TextSpan(
              text: "$label ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _actionItem(String title, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF111827),
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF374151)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
    );
  }
}

class ProfileTab extends StatelessWidget {
  final bool isDark;
  const ProfileTab({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Obx(() {
      if (controller.isLoading.value || controller.profile.value == null) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF7E49FF)),
        );
      }

      final p = controller.profile.value!;

      return SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            // ================= PERSONAL INFORMATION =================
            _sectionContainer(
              title: "Personal Information",
              children: [
                _infoCard("Name", p.name, Icons.person),
                _infoCard("Father's Name", p.father, Icons.badge_outlined),
                _infoCard("Gender", p.gender, Icons.wc_outlined),
                _infoCard("D.O.T", p.dob, Icons.calendar_month_outlined),
                _infoCard(
                  "Nationality",
                  p.nationality,
                  Icons.language_outlined,
                ),
                _infoCard(
                  "Marital Status",
                  p.marital,
                  Icons.favorite_border_outlined,
                ),
                _infoCard("Religion", p.religion, Icons.handshake_outlined),
                _infoCard("Community", p.community, Icons.groups_outlined),
              ],
            ),

            // ================= CONTACT INFORMATION =================
            _sectionContainer(
              title: "Contact Information",
              children: [
                _infoCard("Phone", p.mobile, Icons.phone_android_outlined),
                _infoCard("Email", p.email, Icons.email_outlined),
                _infoCard("Current Address", p.cAddress, Icons.send_outlined),
                _infoCard(
                  "Permanent Address",
                  p.pAddress,
                  Icons.location_on_outlined,
                ),
              ],
            ),

            // ================= PROFESSIONAL INFORMATION =================
            _sectionContainer(
              title: "Professional Information",
              children: [
                _infoCard(
                  "Designation",
                  p.designation,
                  Icons.assignment_ind_outlined,
                ),
                _infoCard("Job Type", p.jobType, Icons.work_outline),
                _infoCard(
                  "Department",
                  p.department,
                  Icons.account_tree_outlined,
                ),
                _infoCard("Experience", "N/A", Icons.history_outlined),
              ],
            ),
          ],
        ),
      );
    });
  }

  // ================= SECTION CONTAINER =================
  Widget _sectionContainer({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEBEEFF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.25,
            children: children,
          ),
        ),
      ],
    );
  }

  // ================= INFO CARD =================
  Widget _infoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF7E49FF), size: 24),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////////
/// PAY SCALE TAB
////////////////////////////////////////////////////////////////
class PayScaleTab extends StatelessWidget {
  final bool isDark;
  const PayScaleTab({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? ProfilePage.darkHeaderGradient : null,
        color: isDark ? null : Colors.transparent,
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionTitle("Pay Scale"),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16213e) : const Color(0xFFEBEEFF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                _infoCard(Icons.account_tree, "Branch", "N/A"),
                _infoCard(Icons.account_balance_wallet, "Salary Head", "N/A"),
                _infoCard(Icons.monetization_on, "Amount", "N/A"),
                _infoCard(Icons.create_new_folder, "Created At", "N/A"),
                _infoCard(Icons.history, "Update At", "N/A"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- SECTION TITLE ----------------
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }

  // ---------------- INFO CARD ----------------
  Widget _infoCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isDark ? ProfilePage.cardGradient : null,
        color: isDark ? null : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFF7E49FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////////
/// CHANGE PASSWORD TAB (FINAL – IMAGE MATCHED)
////////////////////////////////////////////////////////////////
class ChangePasswordTab extends StatelessWidget {
  final bool isDark;
  const ChangePasswordTab({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? ProfilePage.darkHeaderGradient : null,
        color: isDark ? null : Colors.transparent,
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ===== TITLE =====
          Text(
            "Change Password",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 10),

          // ===== FORM CONTAINER =====
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16213e) : const Color(0xFFEBEEFF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ===== CURRENT PASSWORD =====
                _label("Current Password", isDark),
                const SizedBox(height: 8),
                _field("Enter current password", isDark),

                const SizedBox(height: 16),

                // ===== NEW PASSWORD =====
                _label("New Password", isDark),
                const SizedBox(height: 8),
                _field("Enter new password", isDark),

                const SizedBox(height: 16),

                // ===== CONFIRM PASSWORD =====
                _label("Confirm Password", isDark),
                const SizedBox(height: 8),
                _field("Re-enter password", isDark),

                const SizedBox(height: 24),

                // ===== BUTTON =====
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFC084FC)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      "Change Password",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= LABEL =================
  Widget _label(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }

  // ================= TEXT FIELD =================
  Widget _field(String hint, bool isDark) {
    return TextField(
      obscureText: true,
      style: TextStyle(
        fontSize: 14,
        color: isDark ? Colors.white : Colors.black,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 13,
          color: isDark ? Colors.white54 : Colors.grey[600],
        ),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////
/// LEAVES TAB
////////////////////////////////////////////////////////////////
class LeavesTab extends StatelessWidget {
  final bool isDark;
  const LeavesTab({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? ProfilePage.darkHeaderGradient : null,
        color: isDark ? null : Colors.transparent,
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionTitle("Leaves"),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16213e) : const Color(0xFFEBEEFF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                _infoCard(Icons.logout, "Leave Type", "N/A"),
                _infoCard(Icons.calendar_month, "From Date", "N/A"),
                _infoCard(Icons.calendar_month, "To Date", "N/A"),
                _infoCard(Icons.edit_calendar, "Days", "N/A"),
                _infoCard(Icons.article, "Reason", "N/A"),
                _infoCard(Icons.edit, "Status", "N/A"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- TITLE ----------
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }

  // ---------- CARD ----------
  Widget _infoCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isDark ? ProfilePage.cardGradient : null,
        color: isDark ? null : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFF7E49FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/////////////////////////////////////////////////////////////////
/// TFA TAB – MATCHES PAY SCALE UI
////////////////////////////////////////////////////////////////
class TfaTab extends StatefulWidget {
  final bool isDark;
  const TfaTab({super.key, required this.isDark});

  @override
  State<TfaTab> createState() => _TfaTabState();
}

class _TfaTabState extends State<TfaTab> {
  bool isEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: widget.isDark ? ProfilePage.darkHeaderGradient : null,
        color: widget.isDark ? null : Colors.transparent,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== TITLE =====
            Text(
              "Two Factor Authentication",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : Colors.black,
              ),
            ),

            const SizedBox(height: 16),

            // ===== MAIN CARD (LIKE PAY SCALE CARD) =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: widget.isDark ? ProfilePage.cardGradient : null,
                color: widget.isDark ? null : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (!widget.isDark)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                ],
              ),
              child: Column(
                children: [
                  // ===== SWITCH ROW =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Enable 2FA",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: widget.isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Switch(
                        value: isEnabled,
                        activeThumbColor: Colors.white,
                        activeTrackColor: const Color(0xFF7C7CE6),
                        inactiveThumbColor: widget.isDark
                            ? Colors.white70
                            : null,
                        onChanged: (value) {
                          setState(() => isEnabled = value);
                          _showResultDialog(value);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ===== QR CODE CARD =====
                  if (isEnabled)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Image.asset(
                        "assets/QRcode.svg",
                        width: 160,
                        height: 160,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            Center(
              child: Text(
                "2026 © SSJC.",
                style: TextStyle(
                  color: widget.isDark ? Colors.white70 : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= ENABLE / DISABLE DIALOG =================
  void _showResultDialog(bool enabled) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // CHECK ICON
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withOpacity(0.15),
                ),
                child: const Icon(Icons.check, size: 46, color: Colors.green),
              ),

              const SizedBox(height: 18),

              const Text(
                "Good job!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Text(
                enabled
                    ? "Two Factor Authentication Successfully Enabled"
                    : "Two Factor Authentication Successfully Disabled",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF533483),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 36,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "OK",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////
/// ATTENDANCE TAB – VERTICAL TABLE (LIGHT & DARK THEME)
////////////////////////////////////////////////////////////////
class AttendanceTab extends StatelessWidget {
  final bool isDark;
  const AttendanceTab({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Staff Attendance (2026)",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 15),

          // 1. Stats Dashboard
          Row(
            children: [
              _statCard(
                "Working Days",
                "26",
                const Color(0xFF2ECC71),
                Icons.calendar_month,
              ),
              const SizedBox(width: 10),
              _statCard(
                "Present Days",
                "22",
                const Color(0xFFF39C12),
                Icons.check,
              ),
              const SizedBox(width: 10),
              _statCard(
                "Absent Days",
                "4",
                const Color(0xFFF06292),
                Icons.close,
              ),
            ],
          ),
          const SizedBox(height: 25),

          // 2. Calendar Container
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F2FF),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              children: [
                // Month Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "January 2026",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.chevron_left, color: Colors.grey[800]),
                        const SizedBox(width: 15),
                        Icon(Icons.chevron_right, color: Colors.grey[800]),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Days Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ["S", "M", "T", "W", "T", "F", "S"]
                      .map(
                        (day) => Text(
                          day,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 10),

                // Calendar Grid
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                        ),
                    itemCount: 35, // 5 weeks
                    itemBuilder: (context, index) {
                      int day =
                          index -
                          1; // Aligning with Jan 1st being Thursday (roughly matching image)
                      // This is a mockup alignment
                      if (index < 3)
                        return _calendarCell(
                          "",
                          status: null,
                          isInactive: true,
                        );
                      if (day > 31)
                        return _calendarCell(
                          "${day - 31}",
                          status: null,
                          isInactive: true,
                        );

                      // Mock status based on image (Approximate)
                      String? status = "present";
                      if (day == 6 || day == 13 || day == 20 || day == 27)
                        status = "holiday";
                      if (day == 12 || day == 15 || day == 23 || day == 26)
                        status = "absent";

                      return _calendarCell("$day", status: status);
                    },
                  ),
                ),
                const SizedBox(height: 15),

                // Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _legendItem("Present", const Color(0xFF2ECC71)),
                    const SizedBox(width: 15),
                    _legendItem("Absent", const Color(0xFFF06292)),
                    const SizedBox(width: 15),
                    _legendItem("Holiday", const Color(0xFF5D6D7E)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 100), // Space for bottom nav
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _calendarCell(
    String text, {
    required String? status,
    bool isInactive = false,
  }) {
    Color? dotColor;
    if (status == "present") dotColor = const Color(0xFF2ECC71);
    if (status == "absent") dotColor = const Color(0xFFF06292);
    if (status == "holiday") dotColor = const Color(0xFF5D6D7E);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade100, width: 0.5),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isInactive ? Colors.grey[300] : Colors.black,
              ),
            ),
          ),
          if (dotColor != null)
            Positioned(
              top: 5,
              right: 5,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
