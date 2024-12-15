import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateScreen extends StatefulWidget {
  final String postId;

  UpdateScreen({required this.postId});

  @override
  _UpdateScreenState createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  XFile? _newImage;
  String? _currentImageUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchPostData();
  }

  Future<void> _fetchPostData() async {
    final doc = await FirebaseFirestore.instance.collection('posts').doc(widget.postId).get();
    if (doc.exists) {
      setState(() {
        _titleController.text = doc['title'];
        _descriptionController.text = doc['description'];
        _currentImageUrl = doc['imageUrl'];
      });
    }
  }

  Future<void> _pickNewImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _newImage = pickedImage;
    });
  }

  Future<void> _updatePost() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Title and description cannot be empty!')));
      return;
    }

    String? updatedImageUrl = _currentImageUrl;

    if (_newImage != null) {
      // Upload new image if selected
      final imageRef = FirebaseStorage.instance.ref().child('posts/${DateTime.now().toString()}');
      await imageRef.putFile(File(_newImage!.path));
      updatedImageUrl = await imageRef.getDownloadURL();
    }

    // Update Firestore document
    await FirebaseFirestore.instance.collection('posts').doc(widget.postId).update({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'imageUrl': updatedImageUrl,
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Post updated successfully!')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 16),
            _newImage == null
                ? _currentImageUrl == null
                    ? Text('No image available')
                    : Image.network(_currentImageUrl!, height: 150)
                : Image.file(File(_newImage!.path), height: 150),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickNewImage,
              child: Text('Change Image'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _updatePost,
              child: Text('Update Post'),
            ),
          ],
        ),
      ),
    );
  }
}
