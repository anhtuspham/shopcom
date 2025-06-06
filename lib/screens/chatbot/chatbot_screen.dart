import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_com/data/config/app_config.dart';
import 'package:shop_com/providers/dialogflow_provider.dart';
import 'package:shop_com/utils/color_value_key.dart';

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {'sender': 'bot', 'text': 'Xin chào! Tôi là Shopcom Assistant. Hôm nay tôi có thể giúp gì cho bạn?'},
  ];
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage(String text) async {
    if (text.isEmpty) return;
    if (app_config.user == null) {
      setState(() {
        _messages.add({'sender': 'bot', 'text': 'Vui lòng đăng nhập để sử dụng chatbot!'});
      });
      context.push('/login');
      return;
    }

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isLoading = true;
    });
    _controller.clear();

    final dialogFlowtterAsync = ref.read(dialogFlowtterProvider);
    dialogFlowtterAsync.when(
      data: (dialogFlowtter) async {
        try {
          final response = await dialogFlowtter.detectIntent(
            queryInput: QueryInput(
              text: TextInput(text: text, languageCode: 'vi'),
            ),
          );
          final botMessage = response.text ?? 'Xin lỗi, tôi không hiểu. Vui lòng thử lại!';
          setState(() {
            _messages.add({'sender': 'bot', 'text': botMessage});
            _isLoading = false;
          });
        } catch (e) {
          if (kDebugMode) {
            print('Chatbot error: $e');
          }
          print('error ${e}');
          String errorMessage = 'Đã có lỗi xảy ra. Vui lòng thử lại sau!';
          if (e.toString().contains('PERMISSION_DENIED')) {
            errorMessage = 'Không có quyền truy cập chatbot. Vui lòng kiểm tra cấu hình!';
          }
          setState(() {
            _messages.add({'sender': 'bot', 'text': errorMessage});
            _isLoading = false;
          });
        }
      },
      error: (error, stack) {
        if (kDebugMode) {
          print('Dialogflow provider error: $error');
        }
        setState(() {
          _messages.add({'sender': 'bot', 'text': 'Không thể kết nối với chatbot. Vui lòng thử lại sau!'});
          _isLoading = false;
        });
      },
      loading: () {
        setState(() {
          _isLoading = true;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: ColorValueKey.textColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Shopcom Assistant',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ColorValueKey.textColor,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: ColorValueKey.textColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: ColorValueKey.lineBorder),
            // Chat Area
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isLoading && index == _messages.length) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final message = _messages[index];
                  final isUser = message['sender'] == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser ? ColorValueKey.textColor.withOpacity(0.1) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        message['text']!,
                        style: TextStyle(color: ColorValueKey.textColor),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Input Field
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Nhập tin nhắn...',
                        hintStyle: TextStyle(color: ColorValueKey.textColor.withOpacity(0.4)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: ColorValueKey.lineBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: ColorValueKey.lineBorder),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.send, color: ColorValueKey.textColor),
                    onPressed: () => _sendMessage(_controller.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}