import 'package:flutter/material.dart';
import 'package:generative_ai/message_widget.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class Chatroom extends StatefulWidget {
  const Chatroom({super.key});

  @override
  State<Chatroom> createState() => _ChatroomState();
}

class _ChatroomState extends State<Chatroom> {
  List<String> chatbotHistory = [
    'Hi there!',
    'How cna I assist you today?',
    'Sure, I can help with that!',
    'Here is the information you requested.',
    'Hi there!',
    'How cna I assist you today?',
    'Sure, I can help with that!',
    'Here is the information you requested.',
    'Hi there!',
    'How cna I assist you today?',
    'Sure, I can help with that!',
    'Here is the information you requested.',
  ];

  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollControler = ScrollController();
  bool isLoading = false;

  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  final String _apiKey = const String.fromEnvironment('API_KEY');

  @override
  void initState() {
    super.initState();
    // print(_apiKey);
    _model = GenerativeModel(model: "gemini-pro", apiKey: _apiKey);
    _chatSession = _model.startChat();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemBuilder: (context, index) {
              final content = _chatSession.history.toList()[index];
              final text = content.parts
                  .whereType<TextPart>()
                  .map((part) => part.text)
                  .join();

              return MessageWidget(
                isUserMessage: content.role == 'user',
                message: text,
              );
            },
            itemCount: _chatSession.history.length,
            controller: _scrollControler,
          ),
        ),
        if (isLoading) const LinearProgressIndicator(),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                onSubmitted: (value) {
                  if (!isLoading) _sendMessage(value);
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Type a message',
                ),
              ),
            ),
            IconButton(
              onPressed: isLoading
                  ? null
                  : () {
                      if (!isLoading) {
                        _sendMessage(_textController.text);
                      }
                    },
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ],
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _scrollControler.animateTo(
        _scrollControler.position.maxScrollExtent, // max로 스크롤
        duration: const Duration(milliseconds: 700), // 스크롤 애니메이션 시간
        curve: Curves.easeInCirc,
      );
    });
  }

  Future<void> _sendMessage(String value) async {
    if (value.isEmpty) {
      return;
    }

    setState(() {
      isLoading = true;
      _textController.clear();
    });
    _scrollToBottom();

    final response = await _chatSession.sendMessage(Content.text(value));

    setState(() {
      isLoading = false;
    });

    _scrollToBottom();
    _focusNode.requestFocus();

    // setState(() {
    //   isLoading = true;
    //   chatbotHistory.add(value);
    //   _textController.clear();
    // });
    // _scrollToBottom();

    // Future.delayed(
    //   const Duration(seconds: 1),
    //   () {
    //     setState(() {
    //       isLoading = false;
    //       chatbotHistory.add("I am a chatbot");
    //     });
    //     _scrollToBottom();
    //     _focusNode.requestFocus();
    //   },
    // );
  }
}
