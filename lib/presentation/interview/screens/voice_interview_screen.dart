import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/services/voice_live_service.dart';

class VoiceInterviewScreen extends StatefulWidget {
  const VoiceInterviewScreen({super.key});

  @override
  State<VoiceInterviewScreen> createState() =>
      _VoiceInterviewScreenState();
}

class _VoiceInterviewScreenState extends State<VoiceInterviewScreen> {
  final VoiceLiveService _voiceService = VoiceLiveService();

  StreamSubscription<String>? _statusSubscription;
  StreamSubscription<String>? _userTranscriptSubscription;
  StreamSubscription<String>? _assistantTranscriptSubscription;
  StreamSubscription<String>? _errorSubscription;

  String _status = 'Ready';
  String _userTranscript = '';
  String _assistantTranscript = '';
  String? _error;

  bool _isStarting = false;
  bool _isInterviewRunning = false;

  @override
  void initState() {
    super.initState();

    _statusSubscription = _voiceService.statusStream.listen((status) {
      if (!mounted) return;

      setState(() {
        _status = status;
      });
    });

    _userTranscriptSubscription =
        _voiceService.transcriptStream.listen((text) {
          if (!mounted) return;

          setState(() {
            if (text.startsWith('[FINAL] ')) {
              _userTranscript =
                  text.replaceFirst('[FINAL] ', '');
            } else {
              _userTranscript += text;
            }
          });
        });

    _assistantTranscriptSubscription =
        _voiceService.assistantTranscriptStream.listen((text) {
          if (!mounted) return;

          setState(() {
            if (text.startsWith('[FINAL] ')) {
              _assistantTranscript =
                  text.replaceFirst('[FINAL] ', '');
            } else {
              _assistantTranscript += text;
            }
          });
        });

    _errorSubscription = _voiceService.errorStream.listen((error) {
      if (!mounted) return;

      setState(() {
        _error = error;
      });
    });
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _userTranscriptSubscription?.cancel();
    _assistantTranscriptSubscription?.cancel();
    _errorSubscription?.cancel();

    _voiceService.dispose();

    super.dispose();
  }

  Future<void> _startInterview() async {
    if (_isInterviewRunning || _isStarting) return;

    setState(() {
      _isStarting = true;
      _error = null;
      _userTranscript = '';
      _assistantTranscript = '';
    });

    try {
      await _voiceService.connect();

      if (!mounted) return;

      setState(() {
        _isInterviewRunning = true;
        _isStarting = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isStarting = false;
        _isInterviewRunning = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _stopInterview() async {
    await _voiceService.stop();

    if (!mounted) return;

    setState(() {
      _isInterviewRunning = false;
      _isStarting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Voice Interview'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // AI visual
              Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: 76,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Technical AI Interview',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Answer naturally using your microphone. '
                    'The interviewer will ask one question at a time.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              // Status
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isInterviewRunning
                        ? AppColors.success.withOpacity(0.5)
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isInterviewRunning
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _status,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // AI response
              if (_assistantTranscript.isNotEmpty)
                _buildTranscriptCard(
                  title: 'AI Interviewer',
                  icon: Icons.smart_toy_outlined,
                  text: _assistantTranscript,
                  alignment: Alignment.centerLeft,
                ),

              const SizedBox(height: 12),

              // User response
              if (_userTranscript.isNotEmpty)
                _buildTranscriptCard(
                  title: 'Your Answer',
                  icon: Icons.person_outline,
                  text: _userTranscript,
                  alignment: Alignment.centerRight,
                ),

              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isStarting
                      ? null
                      : (_isInterviewRunning
                      ? _stopInterview
                      : _startInterview),
                  icon: _isStarting
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Icon(
                    _isInterviewRunning
                        ? Icons.stop_rounded
                        : Icons.mic_rounded,
                  ),
                  label: Text(
                    _isStarting
                        ? 'Starting Interview...'
                        : (_isInterviewRunning
                        ? 'End Interview'
                        : 'Start Interview'),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              if (!_isInterviewRunning)
                const Text(
                  'Microphone permission will be requested when the interview starts.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTranscriptCard({
    required String title,
    required IconData icon,
    required String text,
    required Alignment alignment,
  }) {
    return Align(
      alignment: alignment,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: AppColors.primaryLight,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}