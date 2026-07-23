class ResumeAnalysisEntity {
  final int atsScore;
  final int keywordMatchPercentage;
  final String targetRole;
  final List<String> skillsFound;
  final List<String> matchingSkills;
  final List<String> partialMatchSkills;
  final List<String> missingSkills;
  final List<String> matchedKeywords;
  final List<String> missingKeywords;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> formattingIssues;
  final String experienceAnalysis;
  final String projectAnalysis;
  final String educationAnalysis;
  final String certificationAnalysis;
  final List<String> recommendations;
  final List<BulletSuggestionEntity> improvedBulletSuggestions;
  final List<RoadmapStepEntity> careerRoadmap;

  const ResumeAnalysisEntity({
    required this.atsScore,
    required this.keywordMatchPercentage,
    required this.targetRole,
    required this.skillsFound,
    required this.matchingSkills,
    required this.partialMatchSkills,
    required this.missingSkills,
    required this.matchedKeywords,
    required this.missingKeywords,
    required this.strengths,
    required this.weaknesses,
    required this.formattingIssues,
    required this.experienceAnalysis,
    required this.projectAnalysis,
    required this.educationAnalysis,
    required this.certificationAnalysis,
    required this.recommendations,
    required this.improvedBulletSuggestions,
    required this.careerRoadmap,
  });
}

class BulletSuggestionEntity {
  final String original;
  final String improved;
  final String explanation;

  const BulletSuggestionEntity({
    required this.original,
    required this.improved,
    required this.explanation,
  });
}

class RoadmapStepEntity {
  final int stepNumber;
  final String title;
  final String description;
  final List<String> suggestedTechnologies;
  final List<String> suggestedProjects;
  final List<String> suggestedCertifications;

  const RoadmapStepEntity({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.suggestedTechnologies,
    required this.suggestedProjects,
    required this.suggestedCertifications,
  });
}
