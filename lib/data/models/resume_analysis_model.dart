import '../../domain/entities/resume_analysis_entity.dart';

class ResumeAnalysisModel extends ResumeAnalysisEntity {
  const ResumeAnalysisModel({
    required super.atsScore,
    required super.keywordMatchPercentage,
    required super.targetRole,
    required super.skillsFound,
    required super.matchingSkills,
    required super.partialMatchSkills,
    required super.missingSkills,
    required super.matchedKeywords,
    required super.missingKeywords,
    required super.strengths,
    required super.weaknesses,
    required super.formattingIssues,
    required super.experienceAnalysis,
    required super.projectAnalysis,
    required super.educationAnalysis,
    required super.certificationAnalysis,
    required super.recommendations,
    required super.improvedBulletSuggestions,
    required super.careerRoadmap,
  });

  factory ResumeAnalysisModel.fromJson(Map<String, dynamic> json) {
    return ResumeAnalysisModel(
      atsScore: json['atsScore'] as int? ?? 0,
      keywordMatchPercentage: json['keywordMatchPercentage'] as int? ?? 0,
      targetRole: json['targetRole'] as String? ?? '',
      skillsFound: _toStringList(json['skillsFound']),
      matchingSkills: _toStringList(json['matchingSkills']),
      partialMatchSkills: _toStringList(json['partialMatchSkills']),
      missingSkills: _toStringList(json['missingSkills']),
      matchedKeywords: _toStringList(json['matchedKeywords']),
      missingKeywords: _toStringList(json['missingKeywords']),
      strengths: _toStringList(json['strengths']),
      weaknesses: _toStringList(json['weaknesses']),
      formattingIssues: _toStringList(json['formattingIssues']),
      experienceAnalysis: json['experienceAnalysis'] as String? ?? 'No experience analysis available.',
      projectAnalysis: json['projectAnalysis'] as String? ?? 'No project analysis available.',
      educationAnalysis: json['educationAnalysis'] as String? ?? 'No education analysis available.',
      certificationAnalysis: json['certificationAnalysis'] as String? ?? 'No certification analysis available.',
      recommendations: _toStringList(json['recommendations']),
      improvedBulletSuggestions: _toBulletSuggestionsList(json['improvedBulletSuggestions']),
      careerRoadmap: _toRoadmapStepsList(json['careerRoadmap']),
    );
  }

  static List<String> _toStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  static List<BulletSuggestionEntity> _toBulletSuggestionsList(dynamic value) {
    if (value is List) {
      return value.map((e) {
        if (e is Map<String, dynamic>) {
          return BulletSuggestionModel.fromJson(e);
        }
        // Handle direct string suggestions if LLM returns flat array
        return BulletSuggestionEntity(
          original: '',
          improved: e.toString(),
          explanation: 'Improved phrasing suggestion',
        );
      }).toList();
    }
    return [];
  }

  static List<RoadmapStepEntity> _toRoadmapStepsList(dynamic value) {
    if (value is List) {
      return value.map((e) {
        if (e is Map<String, dynamic>) {
          return RoadmapStepModel.fromJson(e);
        }
        return RoadmapStepEntity(
          stepNumber: 1,
          title: 'Additional Skill',
          description: e.toString(),
          suggestedTechnologies: [],
          suggestedProjects: [],
          suggestedCertifications: [],
        );
      }).toList();
    }
    return [];
  }
}

class BulletSuggestionModel extends BulletSuggestionEntity {
  const BulletSuggestionModel({
    required super.original,
    required super.improved,
    required super.explanation,
  });

  factory BulletSuggestionModel.fromJson(Map<String, dynamic> json) {
    return BulletSuggestionModel(
      original: json['original'] as String? ?? '',
      improved: json['improved'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
    );
  }
}

class RoadmapStepModel extends RoadmapStepEntity {
  const RoadmapStepModel({
    required super.stepNumber,
    required super.title,
    required super.description,
    required super.suggestedTechnologies,
    required super.suggestedProjects,
    required super.suggestedCertifications,
  });

  factory RoadmapStepModel.fromJson(Map<String, dynamic> json) {
    return RoadmapStepModel(
      stepNumber: json['stepNumber'] as int? ?? 1,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      suggestedTechnologies: ResumeAnalysisModel._toStringList(json['suggestedTechnologies'] ?? json['technologies']),
      suggestedProjects: ResumeAnalysisModel._toStringList(json['suggestedProjects'] ?? json['projects']),
      suggestedCertifications: ResumeAnalysisModel._toStringList(json['suggestedCertifications'] ?? json['certifications']),
    );
  }
}
