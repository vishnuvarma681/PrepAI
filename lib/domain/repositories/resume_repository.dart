import '../entities/resume_analysis_entity.dart';
import '../entities/chat_message_entity.dart';

abstract class ResumeRepository {
  Future<ResumeAnalysisEntity> analyzeResume({
    required List<int> fileBytes,
    required String fileName,
    required String targetRole,
    required String jobDescription,
  });

  Future<BulletSuggestionEntity> improveResumeSection({
    required String text,
    required String targetRole,
    required String sectionType, // 'bullet', 'summary', 'project', etc.
  });

  Future<String> chatWithResume({
    required List<ChatMessageEntity> history,
    required String message,
    required String resumeText,
    required String jobDescription,
  });

  Future<List<RoadmapStepEntity>> getCareerRoadmap({
    required String resumeText,
    required String targetRole,
    required String jobDescription,
  });

  Future<List<ResumeAnalysisEntity>> getAnalysisHistory();
}
