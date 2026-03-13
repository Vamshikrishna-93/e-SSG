import 'package:get/get.dart';
import '../model/exam_model.dart';
import '../api/api_service.dart';

class ExamsController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<ExamModel> exams = <ExamModel>[].obs;
  RxString query = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadExams();
  }

  Future<void> loadExams() async {
    try {
      isLoading.value = true;

      final response = await ApiService.getRequest("/exams_list");

      // 🔍 DEBUG (IMPORTANT)
      print("EXAMS RESPONSE => $response");

      List list = [];

      if (response is List) {
        // API returns list directly
        list = response;
      } else if (response['indexdata'] != null) {
        list = response['indexdata'];
      } else if (response['data'] != null) {
        list = response['data'];
      } else if (response['exams'] != null) {
        list = response['exams'];
      }

      exams.value = list.map<ExamModel>((e) => ExamModel.fromJson(e)).toList();

      print("TOTAL EXAMS LOADED => ${exams.length}");
    } catch (e) {
      print("EXAMS ERROR => $e");
      Get.snackbar(
        "Error",
        "Failed to load exams",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 🔍 SEARCH FILTER
  List<ExamModel> get filteredExams {
    if (query.value.isEmpty) return exams;

    final q = query.value.toLowerCase();

    return exams.where((e) {
      return e.examName.toLowerCase().contains(q) ||
          e.category.toLowerCase().contains(q) ||
          e.branchName.toLowerCase().contains(q);
    }).toList();
  }
}
