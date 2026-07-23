import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import '../../../core/constants/app_colors.dart';
import '../providers/resume_provider.dart';
import '../../analysis/screens/ats_result_screen.dart';

class ResumeUploadScreen extends ConsumerStatefulWidget {
  const ResumeUploadScreen({super.key});

  @override
  ConsumerState<ResumeUploadScreen> createState() => _ResumeUploadScreenState();
}

class _ResumeUploadScreenState extends ConsumerState<ResumeUploadScreen> {
  final _roleController = TextEditingController();
  final _jdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Pre-populate fields from state if they exist
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(resumeProvider);
      _roleController.text = state.targetRole;
      _jdController.text = state.jobDescription;
    });
  }

  @override
  void dispose() {
    _roleController.dispose();
    _jdController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await file_picker.FilePicker.platform.pickFiles(
        type: file_picker.FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final file = result.files.single;

        ref.read(resumeProvider.notifier).setFile(
          bytes: file.bytes!,
          name: file.name,
          size: file.size,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting file: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _triggerAnalysis() async {
    if (!_formKey.currentState!.validate()) return;
    
    final notifier = ref.read(resumeProvider.notifier);
    notifier.setTargetRole(_roleController.text);
    notifier.setJobDescription(_jdController.text);

    await notifier.runAnalysis();

    final updatedState = ref.read(resumeProvider);
    if (updatedState.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(updatedState.errorMessage!), backgroundColor: AppColors.error),
      );
    } else if (updatedState.currentAnalysis != null && mounted) {
      // Auto-navigate to result dashboard
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AtsResultScreen()),
      );
    }
  }

  String _formatFileSize(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resumeProvider);

    if (state.isAnalyzing) {
      return const _AnalysisLoadingStateWidget();
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'AI Analysis Board',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Upload your resume and enter the target job description to get a comprehensive ATS and Skill Gap analysis.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              // PDF Upload Box
              GestureDetector(
                onTap: state.fileName == null ? _pickFile : null,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: state.fileName != null ? AppColors.success : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: state.fileName != null
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.picture_as_pdf, color: AppColors.success, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                state.fileName!,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatFileSize(state.fileSize),
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () => ref.read(resumeProvider.notifier).removeFile(),
                                icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                                label: const Text('Remove File', style: TextStyle(color: AppColors.error)),
                              )
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 48),
                            SizedBox(height: 12),
                            Text(
                              'Select Resume PDF',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Supports PDF format up to 5MB',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              // Target Role Field
              TextFormField(
                controller: _roleController,
                decoration: const InputDecoration(
                  labelText: 'Target Job Role',
                  hintText: 'e.g., Azure AI Engineer, Flutter Developer',
                  prefixIcon: Icon(Icons.work_outline, color: AppColors.textSecondary),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a target role';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Job Description Field
              TextFormField(
                controller: _jdController,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Job Description',
                  hintText: 'Paste the requirements and skills sought by the employer...',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please paste the job description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              // Action Buttons
              if (state.currentAnalysis != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _triggerAnalysis,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Re-Analyze', style: TextStyle(color: AppColors.primary)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const AtsResultScreen()),
                          );
                        },
                        child: const Text('View Results'),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: _triggerAnalysis,
                  child: const Text('Analyze Resume'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Gorgeous Dynamic Loading State representing Azure Functions + Document Intelligence pipeline steps
class _AnalysisLoadingStateWidget extends StatefulWidget {
  const _AnalysisLoadingStateWidget();

  @override
  State<_AnalysisLoadingStateWidget> createState() => _AnalysisLoadingStateWidgetState();
}

class _AnalysisLoadingStateWidgetState extends State<_AnalysisLoadingStateWidget> {
  int _stepIndex = 0;
  final List<String> _loadingSteps = [
    'Sending payload to Azure Function endpoints...',
    'Running Azure AI Document Intelligence parsing...',
    'Extracting raw resume text...',
    'Grounding content using Career Knowledge Base...',
    'Invoking Microsoft Foundry Agent pipeline...',
    'Evaluating ATS keywords & scoring constraints...',
    'Generating career skill roadmap...',
    'Parsing structured JSON analysis output...',
  ];

  @override
  void initState() {
    super.initState();
    _advanceSteps();
  }

  void _advanceSteps() async {
    for (int i = 0; i < _loadingSteps.length; i++) {
      if (!mounted) return;
      setState(() => _stepIndex = i);
      await Future.delayed(const Duration(milliseconds: 1800));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Glowing CPU / Brain animation
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.1),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            Center(
              child: Text(
                'AI Engine Processing',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Please wait. Generative AI is evaluating your career assets...',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            // Current action step display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _loadingSteps[_stepIndex],
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Progress Bar indicator
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (_stepIndex + 1) / _loadingSteps.length,
                minHeight: 8,
                backgroundColor: AppColors.surface,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${((_stepIndex + 1) / _loadingSteps.length * 100).toInt()}% Complete',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
