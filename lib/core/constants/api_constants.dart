class ApiConstants {
  // Toggle to run in high-fidelity mock mode without backend deployment
  static bool useMockData = true;

  // The base URL for your Azure Function App. Update this with your live URL when deployed.
  static String baseUrl = 'https://your-resume-app-function.azurewebsites.net';

  // API Endpoints
  static const String analyzeResume = '/api/analyze-resume';
  static const String improveResume = '/api/improve-resume';
  static const String chatResume = '/api/chat-resume';
  static const String careerRoadmap = '/api/career-roadmap';
}
