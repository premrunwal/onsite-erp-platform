import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/socket/socket_service.dart';

class ProjectChatScreen extends StatefulWidget {
  const ProjectChatScreen({super.key});

  @override
  State<ProjectChatScreen> createState() => _ProjectChatScreenState();
}

class _ProjectChatScreenState extends State<ProjectChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'sender_name': 'Rajesh Kumar (Site PM)',
      'message_text': 'Welcome to Metro Tower Site 04 chat channel. Please submit DPR by 6 PM today.',
      'media_type': 'TEXT',
      'created_at': '10:30 AM',
      'is_me': false,
    },
    {
      'sender_name': 'Suresh Sharma (Foreman)',
      'message_text': 'Slab casting completed on 5th floor. 40 bags cement consumed.',
      'media_type': 'TEXT',
      'created_at': '11:15 AM',
      'is_me': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Connect Socket.IO
    SocketService().connect('http://localhost:4000', 'demo_token');
    SocketService().joinProjectChannel('p1111111-1111-1111-1111-111111111111');

    SocketService().onMessageReceived((data) {
      if (mounted) {
        setState(() {
          _messages.add({
            'sender_name': data['sender_name'] ?? 'Team Member',
            'message_text': data['message_text'],
            'media_type': data['media_type'] ?? 'TEXT',
            'created_at': 'Just now',
            'is_me': false,
          });
        });
      }
    });
  }

  void _sendMessage() {
    if (_msgController.text.trim().isEmpty) return;

    final text = _msgController.text.trim();
    _msgController.clear();

    setState(() {
      _messages.add({
        'sender_name': 'You (Site Lead)',
        'message_text': text,
        'media_type': 'TEXT',
        'created_at': 'Just now',
        'is_me': true,
      });
    });

    SocketService().sendChatMessage(
      channelId: 'p1111111-1111-1111-1111-111111111111',
      senderId: 'u1111111-1111-1111-1111-111111111111',
      senderName: 'Rajesh Kumar',
      messageText: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Metro Tower Site 04 Channel'),
            Text('🟢 14 site engineers online', style: TextStyle(fontSize: 11, color: Color(0xFF86EFAC))),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages ListView
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['is_me'] == true;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isMe ? AppTheme.primaryOrange : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: Radius.circular(isMe ? 12 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 12),
                      ),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isMe)
                          Text(
                            msg['sender_name'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.slateNavyDark),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          msg['message_text'] ?? '',
                          style: TextStyle(
                            color: isMe ? Colors.white : AppTheme.slateNavyDark,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            msg['created_at'],
                            style: TextStyle(
                              fontSize: 10,
                              color: isMe ? Colors.white70 : const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Message Input Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: AppTheme.primaryOrange),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Attaching site photo with watermark...')),
                    );
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: InputDecoration(
                      hintText: 'Type project update message...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      filled: true,
                      fillColor: AppTheme.backgroundOffWhite,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppTheme.primaryOrange,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
