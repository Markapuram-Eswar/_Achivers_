import 'package:flutter/material.dart';
import 'widgets/progress_widgets.dart';
import 'data_service.dart';
import 'data_models.dart';

class ReportsZonePage extends StatelessWidget {
  final Future<UserData> userDataFuture;

  ReportsZonePage({super.key}) : userDataFuture = DataService().fetchUserData();

  @override
  Widget build(BuildContext context) {
    /* Backend TODO: Fetch reports data from backend (API call, database read) */
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF4285F4),
        centerTitle: true,
        title: const Text(
          'Report Name',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      // Keeping the existing navigation bar, not adding a new one
      body: FutureBuilder<UserData>(
        future: userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading data: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available.'));
          }

          final data = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                UserSummary(user: data.user),
                const SizedBox(height: 16),
                TopLearners(learners: data.learners),
                const SizedBox(height: 16),
                ProgressReport(reports: data.reports),
                const SizedBox(height: 20),
                RecentAchievements(achievements: data.achievements),
                const SizedBox(height: 20),
                LearningProgress(progressList: data.progressList),
                const SizedBox(height: 20),
                QASummary(stats: data.qaStats),
                const SizedBox(height: 20),
                AchievementOverview(items: data.overviewItems),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text("Download Report"),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.bar_chart),
                      label: const Text("Show Progress"),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
