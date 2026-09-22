import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:audio_io/audio_io.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

import '../../core/config/voice_live_config.dart';
import '../../core/constants/api_constants.dart';
import '../models/voice_session_config.dart';

class VoiceLiveService {
  IOWebSocketChannel? _channel;

  final AudioIo _audio = AudioIo.instance;

  StreamSubscription<dynamic>? _socketSubscription;
  StreamSubscription<Uint8List>? _microphoneSubscription;

  final StreamController<String> _transcriptController =
  StreamController<String>.broadcast();

  final StreamController<String> _assistantTranscriptController =
  StreamController<String>.broadcast();

  final StreamController<String> _statusController =
  StreamController<String>.broadcast();

  final StreamController<String> _errorController =
  StreamController<String>.broadcast();

  bool _connected = false;
  bool _audioStarted = false;

  String get status => _connected ? 'Connected' : 'Disconnected';

  Stream<String> get transcriptStream => _transcriptController.stream;

  Stream<String> get assistantTranscriptStream =>
      _assistantTranscriptController.stream;

  Stream<String> get statusStream => _statusController.stream;

  Stream<String> get errorStream => _errorController.stream;

  bool get isConnected => _connected;

  Future<void> connect() async {
    if (_connected) return;

    try {
      _emitStatus('Requesting microphone permission...');

      final permission = await Permission.microphone.request();

      if (!permission.isGranted) {
        throw Exception(
          'Microphone permission is required for the interview.',
        );
      }

      _emitStatus('Requesting Voice Live session...');

      final session = await _createVoiceSession();

      _emitStatus('Connecting to Voice Live...');

      final socket = IOWebSocketChannel.connect(
        Uri.parse(session.webSocketUrl),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
        },
        connectTimeout: const Duration(seconds: 15),
      );

      _channel = socket;

      await socket.ready;

      _connected = true;

      _emitStatus('Voice Live connected');

      _socketSubscription = socket.stream.listen(
        _handleServerEvent,
        onError: (error) {
          _emitError('WebSocket error: $error');
        },
        onDone: () {
          _connected = false;
          _emitStatus('Voice Live disconnected');
        },
        cancelOnError: false,
      );

      _sendSessionUpdate();

      await _startAudio();
    } catch (e) {
      _connected = false;
      _emitError(e.toString());
      rethrow;
    }
  }

  Future<VoiceSessionConfig> _createVoiceSession() async {
    final response = await http.post(
      Uri.parse(ApiConstants.url(ApiConstants.voiceSession)),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'apiVersion': VoiceLiveConfig.apiVersion,
        'agentName': VoiceLiveConfig.agentName,
        'agentProjectName': VoiceLiveConfig.agentProjectName,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Voice session function failed '
            '(${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid voice session response.');
    }

    return VoiceSessionConfig.fromJson(decoded);
  }

  void _sendSessionUpdate() {
    _send({
      'type': 'session.update',
      'session': {
        'modalities': ['text', 'audio'],
        'voice': {
          'type': 'azure-standard',
          'name': VoiceLiveConfig.voiceName,
          'locale': VoiceLiveConfig.voiceLocale,
        },
        'instructions': VoiceLiveConfig.instructions,
        'input_audio_format': 'pcm16',
        'output_audio_format': 'pcm16',
        'input_audio_sampling_rate': VoiceLiveConfig.inputSampleRate,
        'turn_detection': {
          'type': 'server_vad',
          'threshold': 0.5,
          'prefix_padding_ms': 420,
          'silence_duration_ms': 600,
          'create_response': true,
          'interrupt_response': true,
          'auto_truncate': true,
        },
        'input_audio_noise_reduction': {
          'type': 'azure_deep_noise_suppression',
        },
        'input_audio_echo_cancellation': {
          'type': 'server_echo_cancellation',
        },
        'input_audio_transcription': {
          'model': 'azure-speech',
          'language': 'en-US',
        },
      },
    });
  }

  Future<void> _startAudio() async {
    if (_audioStarted) return;

    await _audio.startWith(
      const AudioIoConfig(
        format: AudioIoFormat.pcm16,
        inputSampleRate: AudioIoSampleRate.rate16000,
        outputSampleRate: AudioIoSampleRate.rate24000,
        outputBufferDuration: 1,
      ),
    );

    _audioStarted = true;

    _microphoneSubscription = _audio.inputBytes.listen(
          (bytes) {
        if (!_connected || bytes.isEmpty) return;

        _send({
          'type': 'input_audio_buffer.append',
          'audio': base64Encode(bytes),
        });
      },
      onError: (error) {
        _emitError('Microphone error: $error');
      },
    );
  }

  void _handleServerEvent(dynamic rawEvent) {
    try {
      if (rawEvent is! String) return;

      final event = jsonDecode(rawEvent);

      if (event is! Map<String, dynamic>) return;

      final type = event['type']?.toString() ?? '';

      switch (type) {
        case 'session.created':
          _emitStatus('Session created');
          break;

        case 'session.updated':
          _emitStatus('Interview ready');

          // Ask the first interview question.
          _send({
            'type': 'response.create',
          });
          break;

        case 'input_audio_buffer.speech_started':
          _emitStatus('Listening...');

          // Stop any assistant audio when candidate starts speaking.
          _audio.clearOutput();
          break;

        case 'input_audio_buffer.speech_stopped':
          _emitStatus('Processing answer...');
          break;

        case 'conversation.item.input_audio_transcription.delta':
          final delta = event['delta']?.toString() ?? '';

          if (delta.isNotEmpty) {
            _transcriptController.add(delta);
          }

          break;

        case 'conversation.item.input_audio_transcription.completed':
          final transcript = event['transcript']?.toString() ?? '';

          if (transcript.isNotEmpty) {
            _transcriptController.add(
              '[FINAL] $transcript',
            );
          }

          break;

        case 'response.audio.delta':
          final delta = event['delta']?.toString();

          if (delta == null || delta.isEmpty) return;

          final audioBytes = base64Decode(delta);

          _audio.outputBytes.add(audioBytes);

          break;

        case 'response.audio_transcript.delta':
          final delta = event['delta']?.toString() ?? '';

          if (delta.isNotEmpty) {
            _assistantTranscriptController.add(delta);
          }

          break;

        case 'response.audio_transcript.done':
          final transcript = event['transcript']?.toString() ?? '';

          if (transcript.isNotEmpty) {
            _assistantTranscriptController.add(
              '[FINAL] $transcript',
            );
          }

          _emitStatus('Listening for your answer...');
          break;

        case 'response.audio.done':
          _emitStatus('Waiting for answer...');
          break;

        case 'error':
          final error = event['error'];

          if (error is Map<String, dynamic>) {
            final message =
                error['message']?.toString() ??
                    'Unknown Voice Live error';

            _emitError(message);
          } else {
            _emitError(event.toString());
          }

          break;

        default:
        // Ignore events that are not needed by the current UI.
          break;
      }
    } catch (e) {
      _emitError('Failed to process Voice Live event: $e');
    }
  }

  void _send(Map<String, dynamic> event) {
    if (!_connected || _channel == null) return;

    _channel!.sink.add(jsonEncode(event));
  }

  Future<void> stop() async {
    try {
      await _microphoneSubscription?.cancel();
      _microphoneSubscription = null;

      if (_audioStarted) {
        await _audio.stop();
        _audioStarted = false;
      }

      if (_channel != null) {
        await _channel!.sink.close(ws_status.normalClosure);
        _channel = null;
      }

      await _socketSubscription?.cancel();
      _socketSubscription = null;

      _connected = false;

      _emitStatus('Interview stopped');
    } catch (e) {
      _emitError('Error stopping interview: $e');
    }
  }

  Future<void> dispose() async {
    await stop();

    await _transcriptController.close();
    await _assistantTranscriptController.close();
    await _statusController.close();
    await _errorController.close();

    _audio.dispose();
  }

  void _emitStatus(String value) {
    if (!_statusController.isClosed) {
      _statusController.add(value);
    }
  }

  void _emitError(String value) {
    if (!_errorController.isClosed) {
      _errorController.add(value);
    }
  }
}