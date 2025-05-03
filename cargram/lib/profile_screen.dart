import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.userId});

  final String userId;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _userFuture;
  late Stream<QuerySnapshot> _postsStream;

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUserData();
    _postsStream = _fetchUserPosts();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchUserData() async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
  }

  Stream<QuerySnapshot> _fetchUserPosts() {
    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId);
    return FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: userDocRef)
        .snapshots();
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      print('User signed out');
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      print('Error signing out: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Something went wrong: ${snapshot.error}'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User not found'));
          }

          final userData = snapshot.data!.data()!;
          final username = userData['username'] as String? ?? 'No Username';
          final bio = userData['bio'] as String? ?? '';
          final profileImage = userData['profileImage'] as String?;
          final followers = userData['followers'] as int? ?? 0;
          final following = userData['following'] as int? ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  radius: 60.0,
                  backgroundImage:
                      profileImage != null
                          ? NetworkImage(profileImage)
                          : const AssetImage('assets/default_profile.png')
                              as ImageProvider,
                ),
                const SizedBox(height: 16.0),
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                if (bio.isNotEmpty)
                  Text(
                    bio,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16.0, color: Colors.grey),
                  ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _buildStatColumn(
                      countStream: _postsStream.map(
                        (snapshot) => snapshot.docs.length,
                      ),
                      label: 'Posts',
                      numberStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    _buildStatColumn(
                      count: followers,
                      label: 'Followers',
                      numberStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    _buildStatColumn(
                      count: following,
                      label: 'Following',
                      numberStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                StreamBuilder<QuerySnapshot>(
                  stream: _postsStream,
                  builder: (context, postSnapshot) {
                    if (postSnapshot.hasError) {
                      return const Center(child: Text('Failed to load posts'));
                    }
                    if (postSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!postSnapshot.hasData ||
                        postSnapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No posts yet.'));
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 4.0,
                            mainAxisSpacing: 4.0,
                          ),
                      itemCount: postSnapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final postDoc = postSnapshot.data!.docs[index];
                        final carIdRef = postDoc['carId'] as DocumentReference?;

                        return FutureBuilder<DocumentSnapshot>(
                          future: carIdRef?.get(),
                          builder: (context, carSnapshot) {
                            if (carSnapshot.hasError || !carSnapshot.hasData) {
                              return Container(color: Colors.grey[300]);
                            }
                            final carData =
                                carSnapshot.data!.data()
                                    as Map<String, dynamic>?;
                            final imageUrl = carData?['carImage'] as String?;

                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: Colors.grey[300],
                              ),
                              child:
                                  imageUrl != null
                                      ? ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                        child: Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Center(
                                                    child: Icon(
                                                      Icons.error_outline,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                        ),
                                      )
                                      : const Center(
                                        child: Icon(
                                          Icons.image,
                                          color: Colors.grey,
                                        ),
                                      ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 80.0),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () => _logout(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Text('Logout', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildStatColumn({
    Stream<int>? countStream,
    int? count,
    required String label,
    TextStyle? numberStyle,
  }) {
    final defaultNumberStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16.0,
    );
    final appliedNumberStyle = numberStyle ?? defaultNumberStyle;

    return Column(
      children: <Widget>[
        if (countStream != null)
          StreamBuilder<int>(
            stream: countStream,
            builder: (context, snapshot) {
              final value = snapshot.data ?? 0;
              return Text('$value', style: appliedNumberStyle);
            },
          )
        else if (count != null)
          Text('$count', style: appliedNumberStyle),
        const SizedBox(height: 2.0),
        Text(label, style: const TextStyle(fontSize: 12.0)),
      ],
    );
  }
}
