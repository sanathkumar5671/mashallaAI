import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  String? _errorMessage;

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;
    setState(() {
      _messages.add({"role": "user", "content": _controller.text});
    });
    _scrollToBottom();
    try {
      final response = await _getResponse(_controller.text);
      setState(() {
        _messages.add({"role": "bot", "content": response});
        _errorMessage = null; // Clear any previous error messages
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
    _controller.clear();
    _scrollToBottom();
  }

  Future<String> _getResponse(String prompt) async {
    final apiKey = dotenv.env['CHATGPT_API_KEY']; // Add your API key here
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'system', 'content': 'You are an expert on Islam. Please answer questions only related to Islam.'},
          {'role': 'user', 'content': prompt}
        ],
        'max_tokens': 150,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['message']['content'].trim();
    } else {
      throw Exception('Failed to load response: ${response.reasonPhrase}');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _messages.add({"role": "Bot", "content": "I am an Islamic Expert. Please ask questions only related to Islam."});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_errorMessage != null)
          Container(
            color: Colors.red,
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _errorMessage = null;
                    });
                  },
                ),
              ],
            ),
          ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color.fromARGB(255, 255, 255, 255)),
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: EdgeInsets.all(8.0),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                bool isUserMessage = _messages[index]['role'] == "user";
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 5.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage(isUserMessage ? 'assets/user.png' : 'assets/islam.png'),
                        radius: 40.0,
                      ),
                      SizedBox(width: 30.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isUserMessage ? "You" : "Bot",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isUserMessage ? Colors.blue : Colors.green,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 253, 253, 253),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Text(
                                _messages[index]['content']!,
                                style: TextStyle(
                                  color: isUserMessage ?  Color.fromARGB(255, 0, 0, 0) : const Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
Padding(
  padding: const EdgeInsets.all(8.0),
  child: Row(
    children: [
      Expanded(
        child: TextField(
          controller: _controller,
          style: TextStyle(color: Colors.white), // Set the text color to white
          decoration: InputDecoration(
            hintText: 'Type a message',
            hintStyle: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)), // Set the hint text color to a lighter shade of white
            filled: true,
            fillColor: const Color.fromARGB(255, 73, 36, 107), // Optional: Change the background color of the text field for better contrast
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.white), // Border color
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.white), // Border color when the text field is not focused
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.white), // Border color when the text field is focused
            ),
          ),
          onSubmitted: (value) => _sendMessage(),
        ),
      ),
      SizedBox(width: 8.0),
      FloatingActionButton(
        onPressed: _sendMessage,
        child: Icon(Icons.send, color: Colors.black), // Set the icon color to black for contrast
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
      ),
    ],
  ),
)
,
      ],
    );
  }
}
