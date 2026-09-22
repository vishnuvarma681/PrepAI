class VoiceSessionConfig {
  final String accessToken;
  final String webSocketUrl;

  const VoiceSessionConfig({
    required this.accessToken,
    required this.webSocketUrl,
  });

  factory VoiceSessionConfig.fromJson(Map<String, dynamic> json) {
    final token =
        json['accessToken'] ??
            json['access_token'] ??
            json['token'];

    final wsUrl =
        json['webSocketUrl'] ??
            json['websocketUrl'] ??
            json['wsUrl'] ??
            json['web_socket_url'];

    if (token == null || token.toString().isEmpty) {
      throw Exception('Voice session response does not contain an access token.');
    }

    if (wsUrl == null || wsUrl.toString().isEmpty) {
      throw Exception('Voice session response does not contain a WebSocket URL.');
    }

    return VoiceSessionConfig(
      accessToken: token.toString(),
      webSocketUrl: wsUrl.toString(),
    );
  }
}