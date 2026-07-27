import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'earnings_list_controller.dart';

class ProjectsScreen extends StatelessWidget {
  ProjectsScreen({super.key});
  final controller = Get.isRegistered<EarningsListController>()
      ? Get.find<EarningsListController>()
      : Get.put(EarningsListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Earnings History")),
      body: GetBuilder<EarningsListController>(
        builder: (controller) {
          // First Loading
          if (controller.isLoading && controller.earningList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // First Load Error
          if (controller.firstLoadError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Failed to load Data"),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: controller.fetchProjects,
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          // Empty State
          if (controller.earningList.isEmpty) {
            return RefreshIndicator(
              onRefresh: controller.refreshProjects,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 300),
                  Center(child: Text("No Data Found")),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.refreshProjects,
            child: ListView.builder(
              controller: controller.scrollController,
              itemCount: controller.earningList.length + 1,
              itemBuilder: (context, index) {
                if (index == controller.earningList.length) {
                  if (controller.isPageLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (controller.pageLoadError) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text("Failed to load more data"),
                          ElevatedButton(
                            onPressed: controller.fetchProjects,
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!controller.hasMore) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          "No More Data",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                }

                final project = controller.earningList[index];

                return ListTile(
                  leading: CircleAvatar(child: Text("${index + 1}")),
                  title: Text(project.title!),
                  subtitle: Text(project.company!),
                  trailing: Text("₹${project.payout}"),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
