class ApiConstants {
  // Keep true until your Azure Functions are actually deployed.
  static bool useMockData = false;

  // ============================================================
  // AZURE FUNCTIONS
  // ============================================================

  // Put your real Function App URL here later.
  static const String baseUrl =
      'https://prepai-functions-fuatf8cca2b9hje6.westus3-01.azurewebsites.net';

  // Resume analysis -> Foundry Agent 1
  static const String analyzeResume = '/api/analyze-resume';

  // Bullet optimization -> Foundry Agent 1
  static const String improveResume = '/api/improve-resume';

  // Optional future career-chat endpoint.
  static const String chatResume = '/api/chat-resume';

  // Optional future roadmap endpoint.
  static const String careerRoadmap = '/api/career-roadmap';

  // Voice Live session/token endpoint.
  //
  // Azure Function will eventually return:
  // {
  //   "accessToken": "...",
  //   "webSocketUrl": "wss://..."
  // }
  static const String voiceSession = '/api/voice-session';

  // Helper for complete URLs.
  static String url(String endpoint) {
    return '$baseUrl$endpoint';
  }
}