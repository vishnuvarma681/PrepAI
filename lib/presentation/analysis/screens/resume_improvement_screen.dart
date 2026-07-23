import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../resume/providers/resume_provider.dart';

class ResumeImprovementScreen extends ConsumerStatefulWidget {
  const ResumeImprovementScreen({super.key});

  @override
  ConsumerState<ResumeImprovementScreen> createState() => _ResumeImprovementScreenState();
}

class _ResumeImprovementScreenState extends ConsumerState<ResumeImprovementScreen> {
  final _inputController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _improvementType = 'bullet';
  bool _isLoading = false;
  String? _originalResult;
  String? _improvedResult;
  String? _explanationResult;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _handleImprove() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _originalResult = null;
      _improvedResult = null;
      _explanationResult = null;
    });

    try {
      final input = _inputController.text.trim();
      final result = await ref.read(resumeProvider.notifier).improveBullet(input, _improvementType);

      setState(() {
        _originalResult = result.original;
        _improvedResult = result.improved;
        _explanationResult = result.explanation;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error improving text: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Resume Optimizer',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Paste your current resume section, summaries, or bullet points to optimize them with action-oriented phrases and metrics.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              
              // Dropdown Selection
              DropdownButtonFormField<String>(
                value: _improvementType,
                decoration: const InputDecoration(
                  labelText: 'Section Category',
                ),
                items: const [
                  DropdownMenuItem(value: 'bullet', child: Text('Work Bullet Point')),
                  DropdownMenuItem(value: 'summary', child: Text('Professional Summary')),
                  DropdownMenuItem(value: 'project', child: Text('Project Description')),
                  DropdownMenuItem(value: 'achievement', child: Text('Achievement Wording')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _improvementType = val);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Multiline text input
              TextFormField(
                controller: _inputController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Draft Text',
                  hintText: 'e.g. "Worked on writing code for a Flutter app and fixed bugs."',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter some draft text to improve';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Improve Button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleImprove,
                icon: _isLoading 
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                  : const Icon(Icons.auto_awesome),
                label: Text(_isLoading ? 'Optimizing Wording...' : 'Optimize Text'),
              ),
              
              const SizedBox(height: 24),
              
              // Results Display
              if (_improvedResult != null) ...[
                const Divider(color: AppColors.border),
                const SizedBox(height: 16),
                const Text('AI Optimization Result', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                
                // Optimized Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.glassGradient,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryLight.withOpacity(0.5), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 10, spreadRadius: 1),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.stars, color: AppColors.accent, size: 18),
                          SizedBox(width: 8),
                          Text('Optimized Phrasing:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _improvedResult!,
                        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.4, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Explanations Card
                Card(
                  color: AppColors.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Improvement Breakdown:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        Text(_explanationResult!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Responsible AI Warning
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error.withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.gavel_outlined, color: AppColors.error, size: 18),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Responsible AI Guardrail: The AI suggests template metrics to illustrate impact. Do not claim credit for fake percentages. Edit the suggestions to match your actual, authentic career metrics.',
                          style: TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.bold, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
