import 'dart:async';

import 'package:get/get.dart';

import '../../model/deal_model.dart';
import '../../repository/deal_repo.dart';
import '../../util/log_service.dart';

class SearchDealsController extends GetxController {
  final DealRepo dealRepo;

  SearchDealsController({required this.dealRepo});

  final results = <DealModel>[].obs;
  final isLoading = false.obs;
  final hasSearched = false.obs;

  Timer? debounce;
  String latestQuery = '';

  @override
  void onClose() {
    debounce?.cancel();
    super.onClose();
  }

  void onQueryChanged(String query) {
    latestQuery = query.trim();

    if (latestQuery.isEmpty) {
      results.clear();
      hasSearched.value = false;
      isLoading.value = false;
      return;
    }

    debounce?.cancel();
    debounce = Timer(
      const Duration(milliseconds: 300),
      () => _search(latestQuery),
    );
  }

  Future<void> _search(String query) async {
    isLoading.value = true;
    hasSearched.value = true;

    try {
      final found = await dealRepo.search(query);
      if (query != latestQuery) return;
      results.assignAll(found);
    } catch (e) {
      LogService.error('search failed', e);
    } finally {
      isLoading.value = false;
    }
  }
}
