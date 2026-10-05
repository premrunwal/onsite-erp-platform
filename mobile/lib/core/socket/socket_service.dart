import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  SocketService._internal();

  io.Socket? _socket;

  void connect(String serverUrl, String token) {
    if (_socket != null && _socket!.connected) return;

    _socket = io.io(
      serverUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({'token': 'Bearer $token'})
          .build(),
    );

    _socket!.onConnect((_) {
      print('[Socket.IO Mobile Client] Connected to Server');
    });

    _socket!.onDisconnect((_) {
      print('[Socket.IO Mobile Client] Disconnected');
    });
  }

  void joinProjectChannel(String projectId) {
    _socket?.emit('join_project_channel', {'project_id': projectId});
  }

  void sendChatMessage({
    required String channelId,
    required String senderId,
    required String senderName,
    String? messageText,
    String? mediaUrl,
    String mediaType = 'TEXT',
  }) {
    _socket?.emit('send_chat_message', {
      'channel_id': channelId,
      'sender_id': senderId,
      'sender_name': senderName,
      'message_text': messageText,
      'media_url': mediaUrl,
      'media_type': mediaType,
    });
  }

  void onMessageReceived(Function(dynamic data) callback) {
    _socket?.on('new_chat_message', callback);
  }

  void onChannelHistory(Function(dynamic data) callback) {
    _socket?.on('channel_history', callback);
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}
