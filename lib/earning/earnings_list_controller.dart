import 'dart:math';

import 'package:flutter/material.dart';
import 'package:funngro_assessment/earning/earnings_list_model.dart';
import 'package:get/get.dart';

class EarningsListController extends GetxController {
  final _rng = Random();

  bool isLoading = false;
  bool isPageLoading = false;
  bool hasMore = true;

  bool firstLoadError = false;
  bool pageLoadError = false;

  int currentPage = 0;

  final List<EarningsListModel> earningList = [];

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();

    fetchProjects();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !isLoading &&
          !isPageLoading &&
          hasMore &&
          !pageLoadError) {
        fetchProjects();
      }
    });
  }

  Future<void> refreshProjects() async {
    currentPage = 0;
    hasMore = true;
    firstLoadError = false;
    pageLoadError = false;

    earningList.clear();

    update();

    await fetchProjects();
  }

  Future<void> fetchProjects() async {
    try {
      if (currentPage == 0) {
        isLoading = true;
        firstLoadError = false;
      } else {
        isPageLoading = true;
        pageLoadError = false;
      }

      update();

      await Future.delayed(const Duration(milliseconds: 900));

      if (_rng.nextInt(5) == 0) {
        throw ApiException("Server Error");
      }

      if (currentPage > 7) {
        hasMore = false;
        update();
        return;
      }

      earningList.addAll(
        List.generate(
          20,
          (i) => EarningsListModel(
            id: 'p${currentPage * 20 + i}',
            title: 'Project ${currentPage * 20 + i}',
            company: 'Company ${_rng.nextInt(50)}',
            payout: 200 + _rng.nextInt(1800),
          ),
        ),
      );

      currentPage++;
    } catch (e) {
      if (earningList.isEmpty) {
        firstLoadError = true;
      } else {
        pageLoadError = true;
      }
    } finally {
      isLoading = false;
      isPageLoading = false;
      update();
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
