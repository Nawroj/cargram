import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_screen.dart';

// You can create these screens separately later
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Search Screen'));
}

class AddScreen extends StatelessWidget {
  const AddScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Add Screen'));
}

class LikesScreen extends StatelessWidget {
  const LikesScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Likes Screen'));
}

/*class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Profile Screen'));
}*/

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens; // Declare _screens as late

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeFeedScreen(),
      const SearchScreen(),
      const AddScreen(),
      const LikesScreen(),
      ProfileScreen(userId: FirebaseAuth.instance.currentUser?.uid ?? ''),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'cargram',
          style: TextStyle(fontSize: 40, fontFamily: 'Geo'),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.notifications,
              size: 28,
              color: Colors.black,
            ),
            onPressed: () => print('Notifications tapped'),
          ),
          IconButton(
            icon: const Icon(Icons.settings, size: 28, color: Colors.black),
            onPressed: () => print('Settings tapped'),
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        ],
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        iconSize: 28,
      ),
    );
  }
}

class HomeFeedScreen extends StatelessWidget {
  const HomeFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('posts').snapshots(),
      builder: (context, postSnapshot) {
        if (postSnapshot.hasError) {
          return const Center(child: Text('Failed to load posts'));
        }
        if (postSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!postSnapshot.hasData || postSnapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No posts available'));
        }
        return ListView.builder(
          itemCount: postSnapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final post = postSnapshot.data!.docs[index];
            return _PostCard(
              postId: post.id,
              postData: post.data() as Map<String, dynamic>,
            );
          },
        );
      },
    );
  }
}

class _PostCard extends StatefulWidget {
  const _PostCard({required this.postId, required this.postData});

  final String postId;
  final Map<String, dynamic> postData;

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  late int _likeCount;
  bool _isLiked = false; // You'll likely want to fetch this from the database

  @override
  void initState() {
    super.initState();
    _likeCount = widget.postData['likeCount'] as int? ?? 0;
    // TODO: Implement logic to check if the current user has liked this post
  }

  Future<void> _toggleLike() async {
    final postRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId);
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserUid != null) {
      setState(() {
        _isLiked = !_isLiked;
        _likeCount = _isLiked ? _likeCount + 1 : _likeCount - 1;
      });

      try {
        if (_isLiked) {
          // Add user's ID to the 'likes' array in the post document
          await postRef.update({
            'likes': FieldValue.arrayUnion([currentUserUid]),
            'likeCount': FieldValue.increment(1),
          });
        } else {
          // Remove user's ID from the 'likes' array
          await postRef.update({
            'likes': FieldValue.arrayRemove([currentUserUid]),
            'likeCount': FieldValue.increment(-1),
          });
        }
      } catch (e) {
        print('Error toggling like: $e');
        // Revert the UI change if the database update fails
        setState(() {
          _isLiked = !_isLiked;
          _likeCount = _isLiked ? _likeCount - 1 : _likeCount + 1;
        });
        // Optionally show an error message to the user
      }
    } else {
      // Handle the case where the user is not logged in
      print('User not logged in, cannot like post.');
      // Optionally show a message asking the user to log in
    }
  }

  @override
  Widget build(BuildContext context) {
    final userIdRef = widget.postData['userId'] as DocumentReference?;
    final carIdRef = widget.postData['carId'] as DocumentReference?;
    final caption = widget.postData['caption'] as String?;
    final commentCount = widget.postData['commentCount'] as int? ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<DocumentSnapshot>(
            future: userIdRef?.get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.hasError || !userSnapshot.hasData) {
                return const SizedBox.shrink();
              }
              final userData =
                  userSnapshot.data!.data() as Map<String, dynamic>?;
              final username = userData?['username'] as String? ?? 'User';
              final profileImageUrl = userData?['profileImage'] as String?;

              return FutureBuilder<DocumentSnapshot>(
                future: carIdRef?.get(),
                builder: (context, carSnapshot) {
                  if (carSnapshot.hasError || !carSnapshot.hasData) {
                    return const SizedBox.shrink();
                  }
                  final carData =
                      carSnapshot.data!.data() as Map<String, dynamic>?;
                  final imageUrl = carData?['carImage'] as String?;
                  final make = carData?['make'] as String?;
                  final model = carData?['model'] as String?;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 8.0,
                        ),
                        child: Row(
                          children: <Widget>[
                            CircleAvatar(
                              radius: 16.0,
                              backgroundImage:
                                  profileImageUrl != null
                                      ? NetworkImage(profileImageUrl)
                                      : const AssetImage(
                                            'assets/default_profile.png',
                                          )
                                          as ImageProvider,
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    username,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (make != null && model != null)
                                    Text(
                                      '$make $model',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Icon(Icons.more_vert),
                          ],
                        ),
                      ),
                      if (imageUrl != null)
                        SizedBox(
                          width: double.infinity,
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => const Center(
                                    child: Text('Failed to load image'),
                                  ),
                            ),
                          ),
                        )
                      else
                        const SizedBox(
                          height: 300.0,
                          child: Center(child: Text('No image available')),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: _toggleLike,
                              child: Icon(
                                _isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_outline_rounded,
                                color: _isLiked ? Colors.red : null,
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            const Icon(Icons.chat_bubble_outline_rounded),
                            const SizedBox(width: 12.0),
                            const Icon(Icons.send),
                            const Spacer(),
                            const Icon(Icons.bookmark_border),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          '$_likeCount likes',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '$username ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(text: caption ?? ''),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        child: InkWell(
                          onTap:
                              () => print(
                                'View all $commentCount comments on post ${widget.postId}',
                              ),
                          child: Text(
                            'View all $commentCount comments',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
