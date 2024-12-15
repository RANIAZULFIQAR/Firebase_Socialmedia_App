import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'upload_screen.dart';
import 'update_screen.dart';
import 'package:firebase_core/firebase_core.dart';

class FeedScreen extends StatelessWidget {
  Future<void> _deletePost(String postId) async {
    await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
    Fluttertoast.showToast(msg: 'Post deleted successfully!');
  }

  Future<void> _downloadImage(String imageUrl) async {
    Fluttertoast.showToast(msg: 'Image downloaded successfully!');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Firebase Initialization Failed')));
        }

        return Scaffold(
          appBar: AppBar(title: Text('Feed')),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UploadScreen()),
            ),
            child: Icon(Icons.add),
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('posts').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final posts = snapshot.data!.docs;

              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return ListTile(
                    leading: GestureDetector(
                      onLongPress: () => _downloadImage(post['imageUrl']),
                      child: Image.network(post['imageUrl'], width: 50, height: 50),
                    ),
                    title: Text(post['title']),
                    subtitle: Text(post['description']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => UpdateScreen(postId: post.id)),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deletePost(post.id),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
