import { Server, Socket } from 'socket.io';
import { v4 as uuidv4 } from 'uuid';
import { db, ChatMessage } from '../../database/db';

export function setupSocketIO(io: Server) {
  io.on('connection', (socket: Socket) => {
    console.log(`[Socket.IO] Client connected: ${socket.id}`);

    // Join Project Channel
    socket.on('join_project_channel', (data: { project_id: string }) => {
      const channelRoom = `project_${data.project_id}`;
      socket.join(channelRoom);
      console.log(`[Socket.IO] Client ${socket.id} joined channel ${channelRoom}`);

      // Send recent channel history
      const history = db.chatMessages.filter((m) => m.channel_id === data.project_id);
      socket.emit('channel_history', history);
    });

    // Send Chat Message
    socket.on('send_chat_message', (data: {
      channel_id: string;
      sender_id: string;
      sender_name: string;
      message_text?: string;
      media_url?: string;
      media_type?: 'TEXT' | 'IMAGE' | 'VOICE_NOTE' | 'DOCUMENT';
    }) => {
      const newMsg: ChatMessage = {
        id: uuidv4(),
        channel_id: data.channel_id,
        sender_id: data.sender_id,
        sender_name: data.sender_name || 'Site User',
        message_text: data.message_text,
        media_url: data.media_url,
        media_type: data.media_type || 'TEXT',
        created_at: new Date().toISOString(),
      };

      db.chatMessages.push(newMsg);

      // Broadcast to channel
      const channelRoom = `project_${data.channel_id}`;
      io.to(channelRoom).emit('new_chat_message', newMsg);
    });

    // Typing indicator
    socket.on('typing_indicator', (data: { channel_id: string; is_typing: boolean; user_name: string }) => {
      const channelRoom = `project_${data.channel_id}`;
      socket.to(channelRoom).emit('user_typing', data);
    });

    socket.on('disconnect', () => {
      console.log(`[Socket.IO] Client disconnected: ${socket.id}`);
    });
  });
}
