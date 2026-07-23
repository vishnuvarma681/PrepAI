import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/resume_repository_impl.dart';
import '../../../domain/entities/resume_analysis_entity.dart';
import '../../../domain/repositories/resume_repository.dart';

// Provider for ResumeRepository
final resumeRepositoryProvider = Provider<ResumeRepository>((ref) {
  return ResumeRepositoryImpl();
});

// Resume State representation
class ResumeState {
  final List<int>? fileBytes;
  final String? fileName;
  final int? fileSize; // In bytes
  final String targetRole;
  final String jobDescription;
  final bool isAnalyzing;
  final String? errorMessage;
  final ResumeAnalysisEntity? currentAnalysis;
  final List<ResumeAnalysisEntity> history;

  const ResumeState({
    this.fileBytes,
    this.fileName,
    this.fileSize,
    this.targetRole = '',
    this.jobDescription = '',
    this.isAnalyzing = false,
    this.errorMessage,
    this.currentAnalysis,
    this.history = const [],
  });

  ResumeState copyWith({
    List<int>? fileBytes,
    String? fileName,
    int? fileSize,
    String? targetRole,
    String? jobDescription,
    bool? isAnalyzing,
    String? errorMessage,
    ResumeAnalysisEntity? currentAnalysis,
    List<ResumeAnalysisEntity>? history,
    bool clearFile = false,
  }) {
    return ResumeState(
      fileBytes: clearFile ? null : (fileBytes ?? this.fileBytes),
      fileName: clearFile ? null : (fileName ?? this.fileName),
      fileSize: clearFile ? null : (fileSize ?? this.fileSize),
      targetRole: targetRole ?? this.targetRole,
      jobDescription: jobDescription ?? this.jobDescription,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      errorMessage: errorMessage,
      currentAnalysis: currentAnalysis ?? this.currentAnalysis,
      history: history ?? this.history,
    );
  }
}

// NotifierProvider for ResumeState (Riverpod 3 replacement for StateNotifierProvider)
final resumeProvider = NotifierProvider<ResumeNotifier, ResumeState>(ResumeNotifier.new);

class ResumeNotifier extends Notifier<ResumeState> {
  late final ResumeRepository _repository;

  @override
  ResumeState build() {
    _repository = ref.watch(resumeRepositoryProvider);
    _loadHistory();
    return const ResumeState();
  }

  Future<void> _loadHistory() async {
    try {
      final history = await _repository.getAnalysisHistory();
      state = state.copyWith(history: history);
    } catch (_) {}
  }

  void setFile({required List<int> bytes, required String name, required int size}) {
    state = state.copyWith(
      fileBytes: bytes,
      fileName: name,
      fileSize: size,
      errorMessage: null,
    );
  }

  void removeFile() {
    state = state.copyWith(
      clearFile: true,
      errorMessage: null,
    );
  }

  void setTargetRole(String role) {
    state = state.copyWith(targetRole: role);
  }

  void setJobDescription(String description) {
    state = state.copyWith(jobDescription: description);
  }

  Future<void> runAnalysis() async {
    if (state.fileBytes == null || state.fileName == null) {
      state = state.copyWith(errorMessage: 'Please select a resume file first.');
      return;
    }
    if (state.targetRole.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter a target role.');
      return;
    }
    if (state.jobDescription.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter a job description.');
      return;
    }

    state = state.copyWith(isAnalyzing: true, errorMessage: null);

    try {
      final analysis = await _repository.analyzeResume(
        fileBytes: state.fileBytes!,
        fileName: state.fileName!,
        targetRole: state.targetRole,
        jobDescription: state.jobDescription,
      );
      
      final history = await _repository.getAnalysisHistory();

      state = state.copyWith(
        isAnalyzing: false,
        currentAnalysis: analysis,
        history: history,
      );
    } catch (e) {
      state = state.copyWith(
        isAnalyzing: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<BulletSuggestionEntity> improveBullet(String text, String type) async {
    return await _repository.improveResumeSection(
      text: text,
      targetRole: state.targetRole,
      sectionType: type,
    );
  }

  void selectAnalysis(ResumeAnalysisEntity analysis) {
    state = state.copyWith(currentAnalysis: analysis);
  }
}
