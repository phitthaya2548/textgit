import 'package:flutter/material.dart';
import '../../controllers/gemini_controller.dart';

class ChatgeminiView extends StatefulWidget {
  const ChatgeminiView({Key? key}) : super(key: key);

  @override
  State<ChatgeminiView> createState() => _ChatgeminiViewState();
}

class _ChatgeminiViewState extends State<ChatgeminiView> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;
  
  Future<void> _sendMessage(String text) async {
  if(text.trim().isEmpty) return;

  setState(() {
    _messages.add(_ChatMessage(text: text, isUser: true));
    _isLoading = true;
  });

  try {
    final reply = await GeminiController.sendMessage(text);
    setState(() {
      _messages.add(_ChatMessage(text: reply, isUser: false));
    });
  } catch (e) {
    setState(() {
      _messages.add(_ChatMessage(text: 'เกิดข้อผิดพลาดในการพิมพ์', isUser: false));
    });
  } finally {
    setState(() {
      _isLoading = false;
      _controller.clear();
    });
  }
}

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.orange,
        title: const Text('ผู้ช่วยแนะนำอาหาร', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment:
                      msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(16),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    decoration: BoxDecoration(
                      color: msg.isUser ? Colors.orange : Colors.grey[200],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(msg.isUser ? 16 : 0),
                        topRight: Radius.circular(msg.isUser ? 0 : 16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        color: msg.isUser ? Colors.white : Colors.black87,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _ChatInputField(
            controller: _controller,
            onSend: _isLoading ? null : _sendMessage,
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({required this.text, required this.isUser});
}

class _ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String)? onSend;

  const _ChatInputField({
    Key? key,
    required this.controller,
    required this.onSend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'พิมพ์สิ่งที่อยากถามผู้ช่วย AI...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.send, color: Colors.orange),
              onPressed: onSend != null
                  ? () => onSend!(controller.text)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}