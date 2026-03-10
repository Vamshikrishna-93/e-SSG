import 'package:flutter/material.dart';
import '../widgets/staff_header.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // ================= UI Constants =================
  static const Color primaryPurple = Color(0xFF7E49FF);
  static const Color lavenderBg = Color(0xFFF1F4FF);

  final List<Map<String, dynamic>> _chats = [
    {
      'name': 'A.Anjaneyulu',
      'message': 'Please Update attendance',
      'time': '10:43AM',
      'unread': 2,
      'initial': 'A',
    },
    {
      'name': 'Tulasi Sai Kiran',
      'message': 'That you sir!',
      'time': '9:30AM',
      'unread': 1,
      'initial': 'T',
    },
    {
      'name': 'Buuri Nanda Kishore',
      'message': 'Alright, I will take care of it',
      'time': 'Yesterday',
      'unread': 0,
      'initial': 'B',
    },
    {
      'name': 'Buuri Nanda Kishore',
      'message': 'Alright, I will take care of it',
      'time': 'Yesterday',
      'unread': 0,
      'initial': 'B',
    },
    {
      'name': 'Buuri Nanda Kishore',
      'message': 'Alright, I will take care of it',
      'time': 'Yesterday',
      'unread': 0,
      'initial': 'B',
    },
    {
      'name': 'Erugula Venkata Janaed...',
      'message': 'Ok',
      'time': 'Yesterday',
      'unread': 0,
      'initial': 'B',
    },
    {
      'name': 'Erugula Venkata Janaed...',
      'message': 'Ok',
      'time': 'Yesterday',
      'unread': 0,
      'initial': 'B',
    },
    {
      'name': 'Erugula Venkata Janaed...',
      'message': 'Ok',
      'time': 'Yesterday',
      'unread': 0,
      'initial': 'B',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              const StaffHeader(title: "Chat"),

              // ================= MAIN CONTENT =================
              Expanded(
                child: Column(
                  children: [
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: primaryPurple.withOpacity(0.4),
                          ),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            icon: Icon(
                              Icons.search,
                              color: Colors.black54,
                              size: 20,
                            ),
                            hintText: "Search Staff / Student....",
                            hintStyle: TextStyle(
                              color: Colors.black38,
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),

                    // Chat List in Lavender Container
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                        padding: const EdgeInsets.only(top: 15),
                        decoration: BoxDecoration(
                          color: lavenderBg.withOpacity(0.7),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: ListView.builder(
                          itemCount: _chats.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            final chat = _chats[index];
                            return _buildChatCard(chat);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ================= FLOATING BUTTON =================
          Positioned(
            bottom: 30,
            right: 20,
            child: GestureDetector(
              onTap: () {
                // Future: New Chat logic
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C69FF), Color(0xFFD38DFA)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C69FF).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.add, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "New Chat",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatCard(Map<String, dynamic> chat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFB59CFF),
            radius: 25,
            child: Text(
              chat['initial'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat['name'],
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  chat['message'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                chat['time'],
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              if (chat['unread'] > 0)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF5EC4B6),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "${chat['unread']}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                const SizedBox(height: 22),
            ],
          ),
        ],
      ),
    );
  }
}
