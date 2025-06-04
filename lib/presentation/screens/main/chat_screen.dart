import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _messages.add(
      ChatMessage(
        text: "Hello! I'm your AI facial analysis coach. I can help you understand your results and provide personalized improvement tips. How can I assist you today?",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
    });

    _messageController.clear();

    // Simulate AI response
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add(
          ChatMessage(
            text: "Thank you for your message! This AI coach feature is coming soon. In the meantime, complete a facial scan to get detailed analysis and improvement recommendations.",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Add top padding for status bar
          SizedBox(height: MediaQuery.of(context).padding.top),
          
          // Messages List
          Expanded(
            child: ListView.builder(
              padding: AppSpacing.screenPadding,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          
          // Message Input
          Container(
            padding: AppSpacing.screenPadding,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              border: Border(
                top: BorderSide(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask about your facial analysis...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
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

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 16,
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: message.isUser 
                    ? AppColors.primary 
                    : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: AppTextStyles.body.copyWith(
                  color: message.isUser 
                      ? Colors.white 
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: AppSpacing.sm),
            CircleAvatar(
              backgroundColor: AppColors.textSecondary,
              radius: 16,
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
} 