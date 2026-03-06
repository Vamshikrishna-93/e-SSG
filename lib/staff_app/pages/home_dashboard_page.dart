import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../controllers/main_controller.dart';
import '../controllers/auth_controller.dart';
import '../widgets/staff_bottom_nav_bar.dart';
import 'package:student_app/staff_app/pages/profile_page.dart';
import '../api/api_service.dart';
import './student_details_page.dart';

class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  late ProfileController profileCtrl;
  String selectedYear = "2025-2026";

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _isSearchingInAppBar = false;

  @override
  void initState() {
    super.initState();
    profileCtrl = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController(), permanent: true);
    Get.put(StaffMainController(), permanent: true).changeIndex(0);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = [];
    });

    try {
      final results = await ApiService.searchStudentByAdmNo(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
    }
  }

  final List<String> years = [
    "2023-2024",
    "2024-2025",
    "2025-2026",
    "2026-2027",
  ];

  final List<Map<String, dynamic>> colleges = const [
    {"name": "Pelluru", "present": 75, "absent": 25},
    {"name": "VRB", "present": 65, "absent": 35},
    {"name": "PVB", "present": 75, "absent": 25},
    {"name": "Vidya Bhavan", "present": 75, "absent": 25},
    {"name": "Padmavathi", "present": 65, "absent": 35},
    {"name": "MM Road", "present": 75, "absent": 25},
    {"name": "AVP", "present": 65, "absent": 35},
    {"name": "Tallur", "present": 75, "absent": 25},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: _buildDrawer(),
      appBar: _buildAppBar(context),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8B5CF6), // Primary Purple
              Color(0xFFC084FC), // Lighter Purple
              Colors.white, // Bottom White
            ],
            stops: [0.0, 0.3, 0.7],
          ),
        ),
        child: _buildDashboardBody(),
      ),
      bottomNavigationBar: const StaffBottomNavBar(),
    );
  }

  // ================= APP BAR =================

  AppBar _buildAppBar(BuildContext context) {
    if (_isSearchingInAppBar) {
      return AppBar(
        backgroundColor: const Color(0xFF8B5CF6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            setState(() {
              _isSearchingInAppBar = false;
              _searchController.clear();
              _searchResults = [];
            });
          },
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          decoration: const InputDecoration(
            hintText: "Search Admission No...",
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onSubmitted: (_) => _handleSearch(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchResults = [];
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _handleSearch,
          ),
        ],
      );
    }

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: Builder(
        builder: (context) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.short_text_rounded, color: Colors.black87),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            setState(() {
              _isSearchingInAppBar = true;
            });
          },
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
              ),
            ),
          ],
        ),
        PopupMenuButton<String>(
          position: PopupMenuPosition.under,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 8,
          onSelected: (v) async {
            switch (v) {
              case 'profile':
                Get.to(() => const ProfilePage());
                break;
              case 'logout':
                Get.find<AuthController>().logout();
                break;
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    size: 20,
                    color: Color(0xFF8B5CF6),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Profile",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            PopupMenuDivider(),
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, size: 20, color: Colors.redAccent),
                  SizedBox(width: 10),
                  Text(
                    "Logout",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Obx(() {
              final p = profileCtrl.profile.value;
              final avatar = p?.avatar ?? "";
              final bool hasValidAvatar =
                  avatar.isNotEmpty && avatar != "avatar.png";

              return CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white30,
                backgroundImage: hasValidAvatar
                    ? NetworkImage(
                        "https://dev.srisaraswathigroups.in/uploads/$avatar",
                      )
                    : null,
                child: !hasValidAvatar
                    ? const Icon(Icons.person, color: Colors.white, size: 20)
                    : null,
              );
            }),
          ),
        ),
      ],
    );
  }

  // Dashboard Body

  Widget _buildDashboardBody() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, Color(0xFFE0E7FF)],
                  ).createShader(bounds),
                  child: const Text(
                    "Dashboard",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) => setState(() => selectedYear = v),
                  itemBuilder: (context) => years
                      .map((y) => PopupMenuItem(value: y, child: Text(y)))
                      .toList(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          selectedYear,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            if (_isSearching)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),

            if (_searchResults.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                    child: Text(
                      "Found ${_searchResults.length} students",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _searchResults.length > 5
                        ? 5
                        : _searchResults.length,
                    itemBuilder: (context, index) {
                      final student = _searchResults[index];
                      final adm =
                          (student['admno'] ?? student['adm_no'])?.toString() ??
                          '';
                      final name =
                          (student['student_name'] ?? student['name'])
                              ?.toString() ??
                          '';
                      final branch = student['branch_name']?.toString() ?? '';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          onTap: () {
                            Get.to(() => StudentDetailsPage(admissionNo: adm));
                          },
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF7C3AED),
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'S',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            name.toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF7C3AED),
                            ),
                          ),
                          subtitle: Text(
                            "Adm: $adm | $branch",
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            const SizedBox(height: 25),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.7,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              children: [
                _buildStatCard("Total Students", "6902", Icons.groups_rounded, [
                  const Color(0xFF26C6DA),
                  const Color(0xFF00ACC1),
                ]),
                _buildStatCard(
                  "Day Scholars",
                  "2,047",
                  Icons.directions_bus_rounded,
                  [const Color(0xFFF06292), const Color(0xFFD81B60)],
                ),
                _buildStatCard("Hostel", "4,854", Icons.business_rounded, [
                  const Color(0xFFFFB74D),
                  const Color(0xFFF57C00),
                ]),
                _buildStatCard(
                  "Today's Outing",
                  "14",
                  Icons.person_pin_rounded,
                  [const Color(0xFF38BDF8), const Color(0xFF0284C7)],
                ),
                _buildStatCard(
                  "Today Present",
                  "4,130",
                  Icons.how_to_reg_rounded,
                  [const Color(0xFF66BB6A), const Color(0xFF388E3C)],
                ),
                _buildStatCard(
                  "Today Absent",
                  "772",
                  Icons.person_remove_rounded,
                  [const Color(0xFFEC4899), const Color(0xFFD81B60)],
                ),
              ],
            ),

            const SizedBox(height: 30),
            const Text(
              "Quick Actions",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 18),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.45,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              children: [
                _buildQuickAction(
                  "Class Attendance",
                  Icons.people_alt_rounded,
                  const Color(0xFF26C6DA),
                  () => Get.toNamed('/studentAttendanceFilter'),
                ),
                _buildQuickAction(
                  "Hostel Attendance",
                  Icons.calendar_month_rounded,
                  const Color(0xFFFFA726),
                  () => Get.toNamed('/hostelAttendanceFilter'),
                ),
                _buildQuickAction(
                  "Issue Outing",
                  Icons.backpack_rounded,
                  const Color(0xFF42A5F5),
                  () => Get.toNamed('/outingList'),
                ),
                _buildQuickAction(
                  "Verify Outing",
                  Icons.verified_rounded,
                  const Color(0xFFEC4899),
                  () => Get.toNamed('/outingPending'),
                ),
              ],
            ),

            const SizedBox(height: 30),
            const Text(
              "Students Attendance",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E7FF).withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: colleges
                    .map(
                      (c) => _buildAttendanceBar(
                        c["name"],
                        c["present"],
                        c["present"] >= 70
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    List<Color> colors,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 38),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    String title,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 36),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceBar(String label, int percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                "$percentage%",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.white,
              color: color,
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ================= DRAWER =================

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Container(
        color: const Color(0xFFF5F3FF),
        child: Column(
          children: [
            _buildDrawerHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
                children: [
                  _buildExpandableDrawerItem(
                    icon: Icons.fact_check_rounded, // Exam Icon from image
                    title: "Exams",
                    children: [
                      _buildDrawerSubItem(
                        "Exam Category List",
                        () => Get.toNamed('/examCategoryList'),
                      ),
                      _buildDrawerSubItem(
                        "Exams List",
                        () => Get.toNamed('/examsList'),
                      ),
                      _buildDrawerSubItem(
                        "Student Marks Upload",
                        () => Get.toNamed('/subjectMarksUploadPage'),
                      ),
                    ],
                  ),
                  _buildDrawerPillItem(
                    icon: Icons.chat_bubble_rounded, // Chat Icon from image
                    title: "Pro Admission",
                    onTap: () => Get.toNamed('/proAdmission'),
                  ),
                  _buildExpandableDrawerItem(
                    icon: Icons.apartment_rounded, // Hostel Icon from image
                    title: "Hostels",
                    children: [
                      _buildDrawerSubItem(
                        "Hostel List",
                        () => Get.toNamed('/hostelList'),
                      ),
                      _buildDrawerSubItem("Rooms", () => Get.toNamed('/rooms')),
                      _buildDrawerSubItem(
                        "Floors",
                        () => Get.toNamed('/floors'),
                      ),
                      _buildDrawerSubItem(
                        "Members",
                        () => Get.toNamed('/hostelMembers'),
                      ),
                      _buildDrawerSubItem(
                        "Add Hostel",
                        () => Get.toNamed('/addHostel'),
                      ),
                      _buildDrawerSubItem(
                        "Non-Hostel Students",
                        () => Get.toNamed('/nonHostel'),
                      ),
                    ],
                  ),
                  _buildExpandableDrawerItem(
                    icon: Icons.manage_accounts_rounded, // Hr Icon from image
                    title: "Hr Management",
                    children: [
                      _buildDrawerSubItem(
                        "Staff List",
                        () => Get.toNamed('/staff'),
                      ),
                      _buildDrawerSubItem(
                        "Staff Attendance",
                        () => Get.toNamed('/staffAttendance'),
                      ),
                    ],
                  ),
                  _buildDrawerPillItem(
                    icon: Icons.chat_bubble_rounded, // Chat Icon from image
                    title: "Chat",
                    onTap: () => Get.toNamed('/chat'),
                  ),
                  _buildDrawerPillItem(
                    icon: Icons.forum_rounded, // Communication Icon from image
                    title: "Communication",
                    onTap: () => Get.toNamed('/communication'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 30,
        left: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B5CF6), Color(0xFFC084FC)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Circle
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                "Logo",
                style: TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // User Name
          Obx(
            () => Text(
              profileCtrl.profile.value?.name ?? "Ashok Reddy",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          // User ID
          const Text(
            "User ID :  666700",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerPillItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        leading: Icon(icon, color: Colors.black, size: 22),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableDrawerItem({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20),
          leading: Icon(icon, color: Colors.black, size: 22),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          trailing: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.black,
            size: 22,
          ),
          children: children,
        ),
      ),
    );
  }

  Widget _buildDrawerSubItem(String title, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.only(left: 60, right: 20),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black54,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
