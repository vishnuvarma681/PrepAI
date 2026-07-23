import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../resume/providers/resume_provider.dart';
import 'ats_result_screen.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(resumeProvider);
    final history = state.history;

    return Scaffold(
      appBar: AppBar(title: const Text('Analysis History')),
      body: history.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.history_outlined, size: 64, color: AppColors.textSecondary),
                    SizedBox(height: 16),
                    Text('No analysis history found', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(
                      'Any resumes you analyze will show up here, enabling you to inspect older reports.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final report = history[index];
                final scoreColor = report.atsScore >= 80
                    ? AppColors.success
                    : (report.atsScore >= 60 ? AppColors.warning : AppColors.error);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      // Swap current analysis and navigate to results screen
                      ref.read(resumeProvider.notifier).selectAnalysis(report);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AtsResultScreen()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Score Circular Badge
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: scoreColor.withOpacity(0.1),
                              border: Border.all(color: scoreColor, width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                '${report.atsScore}',
                                style: TextStyle(fontWeight: FontWeight.bold, color: scoreColor, fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  report.targetRole,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textSecondary),
                                    const SizedBox(width: 4),
                                    const Text('Today', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.link_outlined, size: 12, color: AppColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Text('${report.keywordMatchPercentage}% keywords', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
