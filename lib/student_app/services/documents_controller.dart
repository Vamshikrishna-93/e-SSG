import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:student_app/student_app/services/documents_service.dart';

class DocumentsController extends GetxController {
  var isLoading = true.obs;
  var isInitialLoadDone = false.obs;
  var errorMessage = RxnString();
  var documents = <dynamic>[].obs;
  var totalDocs = 0.obs;
  var verifiedDocs = 0.obs;
  var pendingDocs = 0.obs;
  var rejectedDocs = 0.obs;
  var lastUpdated = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    _refreshFlow();
  }

  Future<void> _refreshFlow() async {
    // 1. Load from cache instantly
    await fetchDocuments(forceRefresh: false);

    // 2. Refresh from server in background
    await fetchDocuments(forceRefresh: true);
  }

  Future<void> fetchDocuments({bool forceRefresh = false}) async {
    // Only fetch if forced or if we haven't successfully loaded this session
    if (!forceRefresh && isInitialLoadDone.value) return;

    // Show skeleton if we have no data at all
    if (documents.isEmpty) {
      isLoading.value = true;
    }

    errorMessage.value = null;

    try {
      final data = await DocumentsService.getDocuments(
        forceRefresh: forceRefresh,
      );

      if (data['success'] == true) {
        documents.value = data['documents'] ?? [];
        totalDocs.value = data['total_docs'] ?? documents.length;
      } else {
        documents.value = [];
        totalDocs.value = 0;
      }

      verifiedDocs.value = documents
          .where(
            (d) =>
                d['status'].toString().toLowerCase() == 'approved' ||
                d['status'].toString().toLowerCase() == 'verified',
          )
          .length;

      pendingDocs.value = documents
          .where((d) => d['status'].toString().toLowerCase() == 'pending')
          .length;

      rejectedDocs.value = documents
          .where((d) => d['status'].toString().toLowerCase() == 'rejected')
          .length;

      lastUpdated.value = DateTime.now();

      if (forceRefresh) {
        isInitialLoadDone.value = true;
        if (Get.isSnackbarOpen != true) {
          Get.snackbar(
            'Success',
            'Documents refreshed',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF4CAF50),
            colorText: const Color(0xFFFFFFFF),
            duration: const Duration(seconds: 1),
          );
        }
      }
      isLoading.value = false;
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Failed to refresh: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: const Color(0xFFFFFFFF),
      );
    }
  }

  double get verificationProgress =>
      totalDocs.value == 0 ? 0 : (verifiedDocs.value / totalDocs.value);
}
