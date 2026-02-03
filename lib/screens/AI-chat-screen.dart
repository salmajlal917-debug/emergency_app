// ai_chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projec/models/ai-chat-model.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _addAIMessage(
      "Hello! I'm your SafeGuard AI Assistant. I'm here to help you with:\n\n"
      "• Emergency guidance and procedures\n"
      "• Safety tips and precautions\n"
      "• Contact management\n"
      "• Location sharing assistance\n"
      "• Real-time emergency information\n\n"
      "How can I assist you today?",
    );
  }

  void _addAIMessage(String text) {
    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: false, timestamp: DateTime.now()),
      );
    });
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    _addUserMessage(text);
    _messageController.clear();
    _focusNode.unfocus();

    // Simulate AI response
    _simulateAIResponse(text);
  }

  void _simulateAIResponse(String userMessage) {
    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 1), () {
      setState(() => _isLoading = false);

      final response = _generateAIResponse(userMessage.toLowerCase());
      _addAIMessage(response);
    });
  }

  String _generateAIResponse(String message) {
    if (message.contains('emergency') || message.contains('sos')) {
      return "I understand this is an emergency situation. Here's what to do immediately:\n\n"
          "1. Stay calm and assess the situation\n"
          "2. Press the SOS button to alert your emergency contacts\n"
          "3. Share your location with trusted contacts\n"
          "4. Move to a safe location if possible\n"
          "5. Contact local emergency services if needed\n\n"
          "Would you like me to help you with any specific emergency procedure?";
    } else if (message.contains('safety') || message.contains('tip')) {
      return "Here are some essential safety tips:\n\n"
          "• Always share your location with trusted contacts when traveling\n"
          "• Keep emergency numbers saved and easily accessible\n"
          "• Be aware of your surroundings in unfamiliar areas\n"
          "• Trust your instincts - if something feels wrong, leave\n"
          "• Keep your phone charged and have a backup power source\n\n"
          "Would you like more specific safety advice?";
    } else if (message.contains('contact') || message.contains('number')) {
      return "I can help you manage your emergency contacts:\n\n"
          "• You can add up to 5 emergency contacts\n"
          "• Set a primary contact for immediate alerts\n"
          "• Include relationship information for each contact\n"
          "• Ensure contact numbers are current and valid\n\n"
          "You can manage your contacts in the SOS Contacts section.";
    } else if (message.contains('location') || message.contains('share')) {
      return "For location sharing:\n\n"
          "• Use the 'Share Location' feature to send your current location\n"
          "• Location updates can be shared in real-time\n"
          "• Emergency contacts will receive precise coordinates\n"
          "• You can stop sharing at any time\n\n"
          "This helps emergency services and contacts find you quickly.";
    } else if (message.contains('medical') || message.contains('health')) {
      return "For medical emergencies:\n\n"
          "• Call emergency medical services immediately\n"
          "• Describe the situation clearly\n"
          "• Share your exact location\n"
          "• Follow first aid procedures if trained\n"
          "• Stay with the person until help arrives\n\n"
          "Would you like specific first aid guidance?";
    } else {
      return "I understand you're asking about \"$message\". As your SafeGuard AI Assistant, "
          "I'm here to provide emergency guidance and safety information. "
          "Could you please rephrase your question or ask about:\n\n"
          "• Emergency procedures\n"
          "• Safety tips\n"
          "• Contact management\n"
          "• Location sharing\n"
          "• Medical guidance";
    }
  }

  void _sendQuickMessage(String message) {
    _messageController.text = message;
    _sendMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Modern Header
            _buildModernHeader(),

            // Messages List
            Expanded(child: _buildMessagesList()),

            // Quick Actions with Grey Background
            _buildGreyQuickActions(),

            // Modern Input Area
            _buildModernInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          bottom: BorderSide(color: Colors.red.withOpacity(0.2), width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Back Button - Smaller and more modern
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.red,
                  size: 16,
                ),
                padding: EdgeInsets.zero,
                splashRadius: 20,
              ),
            ),

            const SizedBox(width: 12),

            // AI Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade600, Colors.red.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),

            const SizedBox(width: 12),

            // Title and Status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SafeGuard AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Online - 24/7 Support',
                        style: TextStyle(
                          color: Colors.red.shade400,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // More options button - smaller
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: Colors.red,
                  size: 16,
                ),
                padding: EdgeInsets.zero,
                splashRadius: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return Container(
      decoration: const BoxDecoration(color: Colors.black),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        reverse: false,
        itemCount: _messages.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _messages.length && _isLoading) {
            return _buildModernTypingIndicator();
          }
          final message = _messages[index];
          return _buildModernMessageBubble(message);
        },
      ),
    );
  }

  Widget _buildModernMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser)
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade600, Colors.red.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 14,
              ),
            )
          else
            const SizedBox(width: 28),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? Colors.red.withOpacity(0.9)
                        : Colors.grey[900],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: message.isUser
                          ? const Radius.circular(16)
                          : const Radius.circular(4),
                      bottomRight: message.isUser
                          ? const Radius.circular(4)
                          : const Radius.circular(16),
                    ),
                    border: Border.all(
                      color: message.isUser
                          ? Colors.red.withOpacity(0.4)
                          : Colors.grey[800]!,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.grey[300],
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),

          if (message.isUser) const SizedBox(width: 8),

          if (message.isUser)
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModernTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade600, Colors.red.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(color: Colors.grey[800]!, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildModernTypingDot(0),
                  _buildModernTypingDot(200),
                  _buildModernTypingDot(400),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTypingDot(int delay) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
    );
  }

  Widget _buildGreyQuickActions() {
    final quickActions = [
      {
        'icon': Icons.emergency_rounded,
        'text': 'Emergency Guide',
        'color': Colors.red,
      },
      {
        'icon': Icons.security_rounded,
        'text': 'Safety Tips',
        'color': Colors.red,
      },
      {
        'icon': Icons.medical_services_rounded,
        'text': 'Medical Help',
        'color': Colors.red,
      },
      {
        'icon': Icons.location_on_rounded,
        'text': 'Location Help',
        'color': Colors.red,
      },
    ];

    return Container(
      height: 80, // Slightly bigger height
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900], // Grey background
        border: Border(
          top: BorderSide(color: Colors.red.withOpacity(0.2), width: 1),
          bottom: BorderSide(color: Colors.red.withOpacity(0.2), width: 1),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: quickActions.length,
        itemBuilder: (context, index) {
          final action = quickActions[index];
          return GestureDetector(
            onTap: () => _sendQuickMessage(action['text'] as String),
            child: Container(
              margin: const EdgeInsets.only(
                right: 10,
              ), // Slightly bigger margin
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 12,
              ), // Bigger padding
              decoration: BoxDecoration(
                color: Colors.grey[800], // Darker grey for buttons
                borderRadius: BorderRadius.circular(
                  14,
                ), // Slightly bigger radius
                border: Border.all(
                  color: Colors.red.withOpacity(0.4),
                  width: 1.5,
                ), // Thicker border
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    action['icon'] as IconData,
                    color: Colors.red,
                    size: 18, // Slightly bigger icon
                  ),
                  const SizedBox(width: 8), // Slightly bigger spacing
                  Text(
                    action['text'] as String,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13, // Slightly bigger font
                      fontWeight: FontWeight.w600, // Bolder font
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(color: Colors.red.withOpacity(0.2), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'Type your emergency question...',
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 1,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Smaller send button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 16,
              ),
              padding: EdgeInsets.zero,
              splashRadius: 20,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
