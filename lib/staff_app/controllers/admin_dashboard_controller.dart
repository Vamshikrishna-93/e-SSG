import 'package:get/get.dart';

class AdminDashboardController extends GetxController {
  var isLoading = false.obs;
  
  // Mock data based on images
  var totalStudents = 6869.obs;
  var boys = 3995.obs;
  var girls = 2874.obs;
  var dayScholars = 2018.obs;
  var hostelStudents = 4850.obs;

  var branchData = [
    {"name": "SSJC-ADARSA CAMPUS", "count": 1063},
    {"name": "SSJC-VICTORY CAMPUS", "count": 324},
    {"name": "SSJC-BN GIRLS", "count": 506},
    {"name": "SSJC-BN BOYS", "count": 645},
    {"name": "SSJC-VRB CAMPUS", "count": 541},
    {"name": "SSJC-PVB CAMPUS", "count": 254},
    {"name": "SSJC-VIDHYA BHAVAN", "count": 1211},
    {"name": "SSJC-SSG EAMCET CAMPUS", "count": 478},
    {"name": "SSHS-TALLUR", "count": 1248},
    {"name": "SSJC-SSG NEET&MAINS CAMPUS", "count": 599},
  ].obs;

  @override
  void onInit() {
    super.onInit();
    // In a real app, fetch data from API here
  }
}
