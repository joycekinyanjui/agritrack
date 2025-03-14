import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final TextEditingController _nameController = TextEditingController();
  File? _imageFile;
  String? _downloadUrl;
  String? _userRole;
  String? _location;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _getUserLocation();
  }

  /// ✅ FETCH USER DATA FROM FIREBASE FIRESTORE
  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection("users").doc(user.uid).get();

      if (userDoc.exists) {
        setState(() {
          _nameController.text = userDoc["name"] ?? "No Name";
          _downloadUrl = userDoc["profilePic"];
          _userRole = userDoc["role"] ?? "Farmer";
          _location = userDoc["location"] ?? "Unknown";
        });
      }
    }
  }

  /// ✅ GET USER GPS LOCATION
  Future<void> _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _location = "${position.latitude}, ${position.longitude}";
    });

    // ✅ Save location to Firestore
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection("users").doc(user.uid).update({
        "location": _location,
      });
    }
  }

  /// ✅ PICK IMAGE FROM GALLERY
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      // ✅ Upload Image to Firebase Storage
      await _uploadProfilePicture();
    }
  }

  /// ✅ UPLOAD PROFILE PICTURE TO FIREBASE STORAGE
  Future<void> _uploadProfilePicture() async {
    if (_imageFile == null) return;
    User? user = _auth.currentUser;
    if (user != null) {
      String filePath = "profile_pics/${user.uid}.jpg";
      Reference storageRef = _storage.ref().child(filePath);
      await storageRef.putFile(_imageFile!);
      String downloadURL = await storageRef.getDownloadURL();

      setState(() {
        _downloadUrl = downloadURL;
      });

      // ✅ Update Firestore with new profile picture URL
      await _firestore.collection("users").doc(user.uid).update({
        "profilePic": downloadURL,
      });
    }
  }

  /// ✅ UPDATE USER PROFILE DETAILS
  Future<void> _updateProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection("users").doc(user.uid).update({
        "name": _nameController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    }
  }

  /// ✅ LOGOUT FUNCTION
  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            /// ✅ DISPLAY PROFILE IMAGE
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _downloadUrl != null
                    ? NetworkImage(_downloadUrl!)
                    : const AssetImage("assets/default_profile.png")
                        as ImageProvider,
              ),
            ),
            const SizedBox(height: 10),
            const Text("Tap to change photo"),

            const SizedBox(height: 20),

            /// ✅ DISPLAY NAME INPUT
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            /// ✅ DISPLAY USER ROLE
            Text("Role: $_userRole", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),

            /// ✅ DISPLAY USER LOCATION
            Text("Location: $_location", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),

            /// ✅ UPDATE PROFILE BUTTON
            ElevatedButton(
              onPressed: _updateProfile,
              child: const Text("Update Profile"),
            ),

            const SizedBox(height: 20),

            /// ✅ DISPLAY EMAIL
            Text("Email: ${user?.email ?? 'No Email'}",
                style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 40),

            /// ✅ LOGOUT BUTTON
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
