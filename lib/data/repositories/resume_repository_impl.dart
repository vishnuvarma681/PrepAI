import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../domain/entities/resume_analysis_entity.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/resume_repository.dart';
import '../models/resume_analysis_model.dart';

class ResumeRepositoryImpl implements ResumeRepository {
  final http.Client _client;
  final List<ResumeAnalysisEntity> _historyCache = [];

  ResumeRepositoryImpl({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<ResumeAnalysisEntity> analyzeResume({
    required List<int> fileBytes,
    required String fileName,
    required String targetRole,
    required String jobDescription,
  }) async {
    if (ApiConstants.useMockData) {
      await Future.delayed(const Duration(seconds: 2)); // Simulate analysis latency
      
      final mockAnalysis = ResumeAnalysisModel(
        atsScore: 78,
        keywordMatchPercentage: 74,
        targetRole: targetRole.isNotEmpty ? targetRole : 'Azure AI Engineer',
        skillsFound: const ['Python', 'SQL', 'REST APIs', 'Git', 'Flutter', 'Prompt Engineering', 'Azure OpenAI'],
        matchingSkills: const ['Python', 'Prompt Engineering', 'Azure OpenAI'],
        partialMatchSkills: const ['Git', 'SQL', 'REST APIs'],
        missingSkills: const ['Azure AI Search', 'AI Evaluation', 'MLOps', 'Docker', 'Kubernetes'],
        matchedKeywords: const ['Azure OpenAI', 'Prompt Engineering', 'Python', 'REST APIs'],
        missingKeywords: const ['Azure AI Search', 'MLOps', 'RAG Evaluation', 'Vector DB', 'Semantic Kernel'],
        strengths: const [
          'Demonstrates strong practical experience with LLMs and prompt engineering.',
          'Solid fundamentals in backend API integrations and database queries.',
          'Clear layout structure with dedicated sections for Skills, Projects, and Experience.'
        ],
        weaknesses: const [
          'Resume bullet points are task-focused rather than action/metric-focused.',
          'No mention of AI evaluation methodologies or safety guardrails.',
          'Lacks experience with advanced cloud indexing services like Azure AI Search.'
        ],
        formattingIssues: const [
          'The layout uses an inconsistent font scale between sections.',
          'The contact section takes up too much vertical space.'
        ],
        experienceAnalysis: 'Candidate shows 2 years of software development experience with recent projects in GenAI. However, the descriptions fail to quantify business value (e.g., speedups, user retention, cost reduction).',
        projectAnalysis: 'Projects demonstrate capability in building AI chatbots and full-stack integrations. To make them stand out, highlight token optimizations and grounding strategies used.',
        educationAnalysis: 'BS in Computer Science. Relevancy is high, though additional coursework in AI/ML could be mentioned.',
        certificationAnalysis: 'Includes basic cloud certifications. Adding AI-102 (Azure AI Engineer Associate) would instantly resolve missing cloud credentials.',
        recommendations: const [
          'Add quantitative metrics to your experience bullets (e.g., "reduced latency by 30%").',
          'Deploy a small RAG pipeline using Azure AI Search and include it in your projects.',
          'List certifications clearly at the top or in a dedicated sidebar.'
        ],
        improvedBulletSuggestions: const [
          BulletSuggestionEntity(
            original: 'Worked on a Flutter application.',
            improved: 'Developed a responsive Flutter-based mobile application, integrating REST APIs and Firebase Auth, resulting in a 15% increase in user retention.',
            explanation: 'Quantified the impact and highlighted specific technology integrations.',
          ),
          BulletSuggestionEntity(
            original: 'Responsible for writing Python scripts for AI models.',
            improved: 'Engineered Python-based prompt pipelines utilizing Azure OpenAI API, optimizing token usage by 25% and reducing inference latency.',
            explanation: 'Replaced passive verb "responsible for writing" with strong action verb "Engineered" and added specific metrics.',
          ),
        ],
        careerRoadmap: [
          const RoadmapStepEntity(
            stepNumber: 1,
            title: 'Master Vector Indexing & Semantic Search',
            description: 'Learn how to ingest, chunk, and index resume/documents in Azure AI Search.',
            suggestedTechnologies: ['Azure AI Search', 'Python SDK', 'LlamaIndex'],
            suggestedProjects: ['Build a PDF Semantic Knowledge Base with Azure AI Search'],
            suggestedCertifications: ['Azure AI Engineer Associate (AI-102)'],
          ),
          const RoadmapStepEntity(
            stepNumber: 2,
            title: 'Implement AI Evaluation & Guardrails',
            description: 'Deepen knowledge in prompt flow, grounding checks, and hallucination metrics.',
            suggestedTechnologies: ['Azure Prompt Flow', 'LangSmith', 'LlamaGuard'],
            suggestedProjects: ['Setup an automated LLM evaluation pipeline with test datasets'],
            suggestedCertifications: [],
          ),
          const RoadmapStepEntity(
            stepNumber: 3,
            title: 'Learn MLOps and Model Deployment',
            description: 'Automate model training/fine-tuning deployments and monitor logs in production.',
            suggestedTechnologies: ['Azure Machine Learning', 'GitHub Actions', 'MLflow'],
            suggestedProjects: ['Configure a CI/CD pipeline for deploying LLM prompt flows'],
            suggestedCertifications: [],
          ),
        ],
      );

      _historyCache.insert(0, mockAnalysis);
      return mockAnalysis;
    }

    // Live HTTP communication with Azure Functions backend
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.analyzeResume}');
    
    try {
      final request = http.MultipartRequest('POST', uri);
      request.fields['targetRole'] = targetRole;
      request.fields['jobDescription'] = jobDescription;
      
      request.files.add(
        http.MultipartFile.fromBytes(
          'resume',
          fileBytes,
          filename: fileName,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final analysis = ResumeAnalysisModel.fromJson(jsonResponse);
        _historyCache.insert(0, analysis);
        return analysis;
      } else {
        throw Exception('Failed to analyze resume. Server returned code ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error during analysis: $e');
    }
  }

  @override
  Future<BulletSuggestionEntity> improveResumeSection({
    required String text,
    required String targetRole,
    required String sectionType,
  }) async {
    if (ApiConstants.useMockData) {
      await Future.delayed(const Duration(milliseconds: 1200));
      return BulletSuggestionEntity(
        original: text,
        improved: 'Spearheaded the development of a high-performance $targetRole solution, leveraging optimized system models which boosted operational efficiency by 34%.',
        explanation: 'Used active metrics, strong verbs, and customized content for the target role ($targetRole). Never invent metrics in your real resume unless true; use this template as a structure.',
      );
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.improveResume}');
    try {
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'text': text,
          'targetRole': targetRole,
          'sectionType': sectionType,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BulletSuggestionEntity(
          original: text,
          improved: data['improved'] as String? ?? '',
          explanation: data['explanation'] as String? ?? '',
        );
      } else {
        throw Exception('Failed to improve section. Server returned code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<String> chatWithResume({
    required List<ChatMessageEntity> history,
    required String message,
    required String resumeText,
    required String jobDescription,
  }) async {
    if (ApiConstants.useMockData) {
      await Future.delayed(const Duration(milliseconds: 1500));
      
      final query = message.toLowerCase();
      if (query.contains('strong') || query.contains('skill')) {
        return 'Based on your resume, your strongest skills are **Python**, **Azure OpenAI**, and **Prompt Engineering**. You also have experience with core application programming (REST APIs, databases, Flutter).';
      } else if (query.contains('suitable') || query.contains('role') || query.contains('azure')) {
        return 'You have a good foundation for an **Azure AI Engineer** role, particularly with Azure OpenAI. However, to be fully competitive, you should learn **Azure AI Search** for implementing RAG architectures, and **Azure Prompt Flow** for evaluation. These are currently listed as missing in your skill gap analysis.';
      } else if (query.contains('project') || query.contains('highlight')) {
        return 'I recommend highlighting your Python-based GenAI projects. Make sure to update the descriptions to explicitly mention that you integrated Azure OpenAI services, optimized prompt tokens, and designed the UI in Flutter. This directly bridges mobile and cloud AI engineering skills.';
      }
      
      return 'I have reviewed your resume and job description. You have strong technical experience in Python and Flutter. Is there a specific section or missing skill you would like to know how to address?';
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.chatResume}');
    try {
      final mappedHistory = history.map((m) => {
        'role': m.sender == ChatSender.user ? 'user' : 'assistant',
        'content': m.text,
      }).toList();

      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'history': mappedHistory,
          'message': message,
          'resumeText': resumeText,
          'jobDescription': jobDescription,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['response'] as String? ?? 'No response returned from agent.';
      } else {
        throw Exception('Chat failed. Server returned code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<List<RoadmapStepEntity>> getCareerRoadmap({
    required String resumeText,
    required String targetRole,
    required String jobDescription,
  }) async {
    if (ApiConstants.useMockData) {
      await Future.delayed(const Duration(milliseconds: 1000));
      return [
        const RoadmapStepEntity(
          stepNumber: 1,
          title: 'Master Vector Indexing & Semantic Search',
          description: 'Learn how to ingest, chunk, and index resume/documents in Azure AI Search.',
          suggestedTechnologies: ['Azure AI Search', 'Python SDK', 'LlamaIndex'],
          suggestedProjects: ['Build a PDF Semantic Knowledge Base with Azure AI Search'],
          suggestedCertifications: ['Azure AI Engineer Associate (AI-102)'],
        ),
        const RoadmapStepEntity(
          stepNumber: 2,
          title: 'Implement AI Evaluation & Guardrails',
          description: 'Deepen knowledge in prompt flow, grounding checks, and hallucination metrics.',
          suggestedTechnologies: ['Azure Prompt Flow', 'LangSmith', 'LlamaGuard'],
          suggestedProjects: ['Setup an automated LLM evaluation pipeline with test datasets'],
          suggestedCertifications: [],
        ),
      ];
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.careerRoadmap}');
    try {
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'resumeText': resumeText,
          'targetRole': targetRole,
          'jobDescription': jobDescription,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => RoadmapStepModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to generate career roadmap. Server returned ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<List<ResumeAnalysisEntity>> getAnalysisHistory() async {
    // Return cached reports from the current session
    return _historyCache;
  }
}
