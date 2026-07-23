import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/resume_analysis_entity.dart';
import '../../resume/providers/resume_provider.dart';

class AtsResultScreen extends ConsumerWidget {
  const AtsResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(resumeProvider);
    final analysis = state.currentAnalysis;

    if (analysis == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analysis Report')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.analytics_outlined, size: 64, color: AppColors.textSecondary),
              const SizedBox(height: 16),
              const Text('No active analysis found.', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Upload Resume'),
              )
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(analysis.targetRole),
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: const [
              Tab(text: 'ATS Audit', icon: Icon(Icons.insights_outlined, size: 20)),
              Tab(text: 'Skill Gap', icon: Icon(Icons.extension_outlined, size: 20)),
              Tab(text: 'Roadmap', icon: Icon(Icons.alt_route_outlined, size: 20)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAtsAuditTab(context, ref, analysis),
            _buildSkillGapTab(context, ref, analysis),
            _buildRoadmapTab(context, ref, analysis),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: ATS AUDIT & VERDICT
  // ==========================================
  Widget _buildAtsAuditTab(BuildContext context, WidgetRef ref, ResumeAnalysisEntity analysis) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Score Dashboard Header
          Card(
            color: AppColors.surface,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // ATS Circular Score
                      CircularPercentIndicator(
                        radius: 65.0,
                        lineWidth: 12.0,
                        animation: true,
                        percent: analysis.atsScore / 100,
                        center: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${analysis.atsScore}",
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            const Text("ATS Score", style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                          ],
                        ),
                        circularStrokeCap: CircularStrokeCap.round,
                        progressColor: _getScoreColor(analysis.atsScore),
                        backgroundColor: AppColors.border,
                      ),
                      // Keyword Match Linear Indicator
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Keyword Match', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              LinearPercentIndicator(
                                width: 120.0,
                                lineHeight: 10.0,
                                percent: analysis.keywordMatchPercentage / 100,
                                backgroundColor: AppColors.border,
                                progressColor: AppColors.secondary,
                                animation: true,
                                barRadius: const Radius.circular(5),
                              ),
                              const SizedBox(width: 8),
                              Text('${analysis.keywordMatchPercentage}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text('RAG Context Grounding', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          Row(
                            children: const [
                              Icon(Icons.shield_outlined, color: AppColors.success, size: 14),
                              SizedBox(width: 4),
                              Text('Verified Safe AI', style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.bold)),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 8),
                  const Text(
                    'ATS Score weightings based on keywords/skill matches (30%), experience (20%), projects (20%), education (10%), accomplishments (10%), and layouts (10%).',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Strengths & Weaknesses
          _buildCollapsibleSection(
            context: context,
            title: 'Resume Strengths',
            icon: Icons.check_circle_outline,
            iconColor: AppColors.success,
            children: analysis.strengths.map<Widget>((s) => _buildListItem(s, Icons.check, AppColors.success)).toList(),
          ),
          const SizedBox(height: 12),

          _buildCollapsibleSection(
            context: context,
            title: 'Critical Weaknesses',
            icon: Icons.error_outline,
            iconColor: AppColors.warning,
            children: analysis.weaknesses.map<Widget>((w) => _buildListItem(w, Icons.close, AppColors.error)).toList(),
          ),
          const SizedBox(height: 12),

          _buildCollapsibleSection(
            context: context,
            title: 'Formatting & Layout Audit',
            icon: Icons.grid_view,
            iconColor: AppColors.secondary,
            children: analysis.formattingIssues.isEmpty
                ? [const Text('No formatting issues detected! Your resume structure is ATS-friendly.', style: TextStyle(color: AppColors.success, fontSize: 13))]
                : analysis.formattingIssues.map<Widget>((f) => _buildListItem(f, Icons.warning_amber_rounded, AppColors.warning)).toList(),
          ),
          const SizedBox(height: 20),

          // Experience & Project Breakdown
          const Text('Deep AI Section Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          _buildAnalysisCard('Work Experience Audit', analysis.experienceAnalysis, Icons.business_center_outlined),
          const SizedBox(height: 12),
          _buildAnalysisCard('Projects & Implementations', analysis.projectAnalysis, Icons.code_outlined),
          const SizedBox(height: 12),
          _buildAnalysisCard('Education & Academics', analysis.educationAnalysis, Icons.school_outlined),
          const SizedBox(height: 12),
          _buildAnalysisCard('Certifications & Credentials', analysis.certificationAnalysis, Icons.workspace_premium_outlined),
          const SizedBox(height: 20),

          // Action Recommendations
          const Text('Optimization Action Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Card(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.glassGradient,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: analysis.recommendations
                    .map<Widget>((r) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.arrow_circle_right_outlined, color: AppColors.primaryLight, size: 18),
                              const SizedBox(width: 12),
                              Expanded(child: Text(r, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: SKILL GAP AUDIT
  // ==========================================
  Widget _buildSkillGapTab(BuildContext context, WidgetRef ref, ResumeAnalysisEntity analysis) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Technical Skill Match Matrix',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 8),
          const Text(
            'We have cross-referenced the skills explicitly extracted from your resume against the target role requirements.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 24),

          // Skill Categories
          _buildSkillCard(
            title: 'Strong Match Skills',
            subtitle: 'Skills mentioned in your resume that perfectly match the job requirements.',
            icon: Icons.verified_outlined,
            iconColor: AppColors.success,
            skills: analysis.matchingSkills,
            chipColor: AppColors.success,
          ),
          const SizedBox(height: 16),

          _buildSkillCard(
            title: 'Partial Match Skills',
            subtitle: 'Skills that are close but might need explicit project achievements or details to stand out.',
            icon: Icons.check_circle_outline,
            iconColor: AppColors.warning,
            skills: analysis.partialMatchSkills,
            chipColor: AppColors.warning,
          ),
          const SizedBox(height: 16),

          _buildSkillCard(
            title: 'Missing Required Skills',
            subtitle: 'Critical requirements from the job description not found in your resume.',
            icon: Icons.cancel_outlined,
            iconColor: AppColors.error,
            skills: analysis.missingSkills,
            chipColor: AppColors.error,
          ),
          const SizedBox(height: 20),

          // Keyword analysis
          const Text('ATS Keywords Audit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Missing Industry Terms', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: analysis.missingKeywords.isEmpty
                      ? [const Text('Awesome, zero missing key phrases detected!', style: TextStyle(color: AppColors.success, fontSize: 12))]
                      : analysis.missingKeywords.map<Widget>((k) => Chip(
                            label: Text(k, style: const TextStyle(fontSize: 12, color: Colors.white)),
                            backgroundColor: AppColors.surfaceLight,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: AppColors.error, width: 0.5),
                            ),
                          )).toList(),
                )
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: CAREER ROADMAP
  // ==========================================
  Widget _buildRoadmapTab(BuildContext context, WidgetRef ref, ResumeAnalysisEntity analysis) {
    final roadmap = analysis.careerRoadmap;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Step-by-Step Upskilling Path',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 8),
          const Text(
            'Recommended order of learning and action plans to bridge your missing skills gaps and secure this role.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 24),
          
          if (roadmap.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Column(
                  children: const [
                    Icon(Icons.thumb_up_alt_outlined, color: AppColors.success, size: 48),
                    SizedBox(height: 12),
                    Text('You match all core capabilities for this role! No roadmap needed.', textAlign: TextAlign.center),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: roadmap.length,
              itemBuilder: (context, index) {
                final step = roadmap[index];
                return _buildTimelineItem(context, step, index == roadmap.length - 1);
              },
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ==========================================
  // HELPER METRICS & WIDGET BUILDERS
  // ==========================================
  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }

  Widget _buildCollapsibleSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Card(
      color: AppColors.surface,
      child: ExpansionTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildListItem(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(String title, String content, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primaryLight, size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required List<String> skills,
    required Color chipColor,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            const SizedBox(height: 16),
            if (skills.isEmpty)
              const Text('None detected.', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontStyle: FontStyle.italic))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: skills.map((s) => Chip(
                      label: Text(s, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                      backgroundColor: chipColor.withOpacity(0.12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: chipColor.withOpacity(0.4), width: 1),
                      ),
                    )).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, RoadmapStepEntity step, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline Dot & Line
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: Center(
                child: Text(
                  "${step.stepNumber}",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 190,
                color: AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Timeline Card Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      step.description,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    // Suggested Technologies
                    if (step.suggestedTechnologies.isNotEmpty) ...[
                      const Text('Focus Technologies:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppColors.textMuted)),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: step.suggestedTechnologies.map<Widget>((t) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(6)),
                              child: Text(t, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                            )).toList(),
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Suggested Projects
                    if (step.suggestedProjects.isNotEmpty) ...[
                      const Text('Practical Portfolio Projects:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppColors.textMuted)),
                      const SizedBox(height: 4),
                      Column(
                        children: step.suggestedProjects.map<Widget>((p) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.keyboard_arrow_right, color: AppColors.secondary, size: 14),
                                  Expanded(child: Text(p, style: const TextStyle(fontSize: 11, color: AppColors.textPrimary))),
                                ],
                              ),
                            )).toList(),
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Suggested Certs
                    if (step.suggestedCertifications.isNotEmpty) ...[
                      const Text('Target Certifications:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppColors.textMuted)),
                      const SizedBox(height: 4),
                      Wrap(
                        children: step.suggestedCertifications.map<Widget>((c) => Row(
                              children: [
                                const Icon(Icons.workspace_premium, color: AppColors.warning, size: 14),
                                const SizedBox(width: 4),
                                Expanded(child: Text(c, style: const TextStyle(fontSize: 11, color: AppColors.textPrimary))),
                              ],
                            )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
