class VoiceLiveConfig {
  // Current stable Voice Live API version.
  static const String apiVersion = '2026-04-10';

  // These are placeholders for your future Foundry voice agent.
  static const String agentName = 'YOUR_VOICE_AGENT';

  static const String agentProjectName = 'YOUR_FOUNDRY_PROJECT';

  // Azure standard voice.
  static const String voiceName = 'en-US-AvaNeural';

  static const String voiceLocale = 'en-US';

  // Voice Live input.
  static const int inputSampleRate = 16000;

  // Voice Live PCM16 output defaults to 24 kHz.
  static const int outputSampleRate = 24000;

  static const String instructions = '''
You are an AI technical interviewer.

Conduct a professional technical interview for a software engineering candidate.

Ask one question at a time.

Wait for the candidate to answer before asking the next question.

Keep questions concise and natural.

Cover Java, Data Structures, Algorithms, OOP, SQL, Spring Boot, REST APIs,
Android, Flutter and basic System Design.

Ask follow-up questions when the candidate's answer is incomplete.

Do not give the answer immediately.

At the end, provide concise feedback about technical correctness,
communication, strengths and areas for improvement.
''';
}