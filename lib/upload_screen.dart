import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb; // Add this import

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _selectedImage = pickedImage;
    });
  }

  Future<void> _uploadPost() async {
    if (_selectedImage == null || _titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('All fields are required!')));
      return;
    }

    // Upload Image to Firebase Storage
    final imageRef = FirebaseStorage.instance.ref().child('posts/${DateTime.now().toString()}');
    await imageRef.putFile(File(_selectedImage!.path));
    final imageUrl = await imageRef.getDownloadURL();

    // Save post to Firestore
    await FirebaseFirestore.instance.collection('posts').add({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'imageUrl': imageUrl,
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Post uploaded successfully!')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Post')),
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
            // Check if the platform is web
            _selectedImage == null
                ? Text('No image selected')
                : kIsWeb
                ? Image.network(_selectedImage!.path) // Use network image for web
                : Image.file(File(_selectedImage!.path), height: 150), // Use file image for mobile
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _uploadPost,
              child: Text('Upload Post'),
            ),
          ],
        ),
      ),
    );
  }
}
