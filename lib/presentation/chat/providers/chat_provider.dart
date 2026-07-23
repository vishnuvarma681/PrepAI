import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../resume/providers/resume_provider.dart';
import '../../../domain/entities/chat_message_entity.dart';
import '../../../domain/repositories/resume_repository.dart';

class ChatState {
  final List<ChatMessageEntity> messages;
  final bool isLoading;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessageEntity>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);

class ChatNotifier extends Notifier<ChatState> {
  late final ResumeRepository _repository;
  late ResumeState _resumeState;

  @override
  ChatState build() {
    _repository = ref.watch(resumeRepositoryProvider);
    _resumeState = ref.watch(resumeProvider);
    return _initialState();
  }

  ChatState _initialState() {
    final role = _resumeState.targetRole.isNotEmpty ? _resumeState.targetRole : 'Target Role';
    return ChatState(
      messages: [
        ChatMessageEntity(
          text: "Hi! I am your AI Career Assistant. I have loaded your resume and the job description for the **$role** role. Ask me anything about how to optimize your resume or prepare for this role!",
          sender: ChatSender.assistant,
          timestamp: DateTime.now(),
        )
      ],
    );
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || state.isLoading) return;

    final userMessage = ChatMessageEntity(
      text: text,
      sender: ChatSender.user,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    try {
      // Pass the resume text/job description context if available (otherwise mock takes care of it)
      final resumeContext = _resumeState.currentAnalysis?.skillsFound.join(', ') ?? 'Loaded resume';
      final responseText = await _repository.chatWithResume(
        history: state.messages,
        message: text,
        resumeText: resumeContext,
        jobDescription: _resumeState.jobDescription,
      );

      final assistantMessage = ChatMessageEntity(
        text: responseText,
        sender: ChatSender.assistant,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, assistantMessage],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearHistory() {
    state = _initialState();
  }
}
