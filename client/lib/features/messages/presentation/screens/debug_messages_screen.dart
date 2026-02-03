import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/messages_repository.dart';

class DebugMessagesScreen extends StatefulWidget {
  const DebugMessagesScreen({super.key});

  @override
  State<DebugMessagesScreen> createState() => _DebugMessagesScreenState();
}

class _DebugMessagesScreenState extends State<DebugMessagesScreen> {
  final MessagesRepository _repo = MessagesRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DEBUG CHAT LOGS'),
        backgroundColor: Colors.red,
      ),
      body: StreamBuilder<List<MessageEntity>>(
        stream: _repo.getMessagesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('❌ DEBUG SCREEN: Stream Error: ${snapshot.error}');
            return Center(child: Text('Stream Error: ${snapshot.error}'));
          }
          
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final msgs = snapshot.data!;
          final uniqueUsers = <String, MessageEntity>{};
          for(var m in msgs) {
             if(!uniqueUsers.containsKey(m.otherUserId)) uniqueUsers[m.otherUserId] = m;
          }
          final users = uniqueUsers.values.toList();

          if (users.isEmpty) return const Center(child: Text('No conversations found'));

          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (_,__) => const Divider(),
            itemBuilder: (context, index) {
              final msg = users[index];
              final avatarUrl = msg.otherUserAvatar;
              
              debugPrint('--------------------------------------------------');
              debugPrint('🔍 DEBUG: Processing User: ${msg.otherUserName}');
              debugPrint('🔍 DEBUG: User ID: ${msg.otherUserId}');
              debugPrint('🔍 DEBUG: Avatar URL: "$avatarUrl"');

              return ListTile(
                leading: SizedBox(
                   width: 60, height: 60,
                   child: avatarUrl != null && avatarUrl.isNotEmpty
                     ? CachedNetworkImage(
                         imageUrl: avatarUrl,
                         progressIndicatorBuilder: (context, url, progress) => const CircularProgressIndicator(),
                         errorWidget: (ctx, url, error) {
                            debugPrint('❌ DEBUG: IMAGE ERROR for URL: $url');
                            debugPrint('❌ DEBUG: Error Detail: $error');
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error, color: Colors.red, size: 20),
                                Text('ERR', style: TextStyle(fontSize: 8, color: Colors.red)),
                              ],
                            );
                         },
                         imageBuilder: (context, imageProvider) {
                           debugPrint('✅ DEBUG: IMAGE SUCCESS for URL: $url');
                           return CircleAvatar(backgroundImage: imageProvider);
                         },
                       )
                     : const CircleAvatar(child: Icon(Icons.person)),
                ),
                title: Text('${msg.otherUserName} (ID: ${msg.otherUserId.substring(0,4)}...)'),
                subtitle: col(
                  children: [
                    Text(msg.content, maxLines: 1),
                    if (avatarUrl != null) 
                      Text(avatarUrl, style: const TextStyle(fontSize: 10, color: Colors.blue)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  Widget col({required List<Widget> children}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
}
