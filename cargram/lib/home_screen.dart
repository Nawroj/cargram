import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:timeago/timeago.dart' as timeago; // Import if you want to show time ago

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    print('Bottom navigation item tapped: $index');
    // TODO: Implement navigation to different screens based on index
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
            icon: const Icon(Icons.search, size: 28, color: Colors.black),
            onPressed: () {
              print('Search tapped');
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications,
              size: 28,
              color: Colors.black,
            ),
            onPressed: () {
              print('Notifications tapped');
            },
          ),
        ],
      ),
      body: _getBody(
        _currentIndex,
      ), // Show different content based on selected tab
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 28, color: Colors.black),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 28, color: Colors.black),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add, size: 28, color: Colors.black),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite, size: 28, color: Colors.black),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 28, color: Colors.black),
            label: '',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Function to return different widgets for different tabs
  Widget _getBody(int index) {
    switch (index) {
      case 0:
        return StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('posts')
                  //.orderBy('timestamp', descending: true) // Uncomment if you have timestamp
                  .snapshots(),
          builder: (context, postSnapshot) {
            if (postSnapshot.hasError) {
              return const Center(
                child: Text('Something went wrong loading posts'),
              );
            }

            if (postSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!postSnapshot.hasData || postSnapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No posts yet.'));
            }

            return ListView.builder(
              itemCount: postSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final postDoc = postSnapshot.data!.docs[index];
                final postData = postDoc.data() as Map<String, dynamic>;
                final userIdRef = postData['userId'] as DocumentReference?;
                final carIdRef = postData['carId'] as DocumentReference?;

                return FutureBuilder<DocumentSnapshot>(
                  future: userIdRef?.get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.hasError) {
                      return const SizedBox.shrink(); // Or some error indicator
                    }
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return _buildLoadingPostCard();
                    }
                    final userData =
                        userSnapshot.data?.data() as Map<String, dynamic>?;

                    return FutureBuilder<DocumentSnapshot>(
                      future: carIdRef?.get(),
                      builder: (context, carSnapshot) {
                        if (carSnapshot.hasError) {
                          return const SizedBox.shrink(); // Or some error indicator
                        }
                        if (carSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return _buildLoadingPostCard();
                        }
                        final carData =
                            carSnapshot.data?.data() as Map<String, dynamic>?;

                        return _buildPostCard(
                          postData: postData,
                          userData: userData,
                          carData: carData,
                          postId: postDoc.id,
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      case 1:
        return const Center(child: Text('Search Screen'));
      case 2:
        return const Center(child: Text('Add Screen'));
      case 3:
        return const Center(child: Text('Likes Screen'));
      case 4:
        return const Center(child: Text('Profile Screen'));
      default:
        return const Center(child: Text('Unknown Screen'));
    }
  }

  Widget _buildLoadingPostCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildPostCard({
    required Map<String, dynamic> postData,
    Map<String, dynamic>? userData,
    Map<String, dynamic>? carData,
    required String postId,
  }) {
    final imageUrl = carData?['carImage'] as String?;
    final caption = postData['caption'] as String?;
    final username = userData?['username'] as String?;
    final profileImageUrl = userData?['profileImage'] as String?;
    final likeCount = postData['likeCount'] as int? ?? 0;
    final commentCount = postData['commentCount'] as int? ?? 0;
    final make = carData?['make'] as String?;
    final model = carData?['model'] as String?;
    // final timestamp = postData['timestamp'] as Timestamp?; // If you have timestamp

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Post Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 16.0,
                  backgroundImage:
                      profileImageUrl != null && profileImageUrl.isNotEmpty
                          ? NetworkImage(profileImageUrl)
                          : const AssetImage('assets/default_profile.png')
                              as ImageProvider<Object>,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username ?? 'User',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (make != null && model != null)
                        Text(
                          '$make $model',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
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

          // Post Image
          if (imageUrl != null)
            SizedBox(
              width: double.infinity,
              child: AspectRatio(
                aspectRatio: 1, // Adjust as needed
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text('Failed to load image'));
                  },
                ),
              ),
            )
          else
            const SizedBox(
              height: 300.0,
              child: Center(child: Text('No image available')),
            ),
          // Post Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(Icons.favorite_outline_rounded),
                    const SizedBox(width: 4.0),
                    //Text('$likeCount'),
                    const SizedBox(width: 12.0),
                    const Icon(Icons.chat_bubble_outline_rounded),
                    const SizedBox(width: 4.0),
                    //Text('$commentCount'),
                    const SizedBox(width: 12.0),
                    const Icon(Icons.send, color: Colors.black),
                  ],
                ),
                const Icon(Icons.bookmark_border),
              ],
            ),
          ),
          // Likes Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '$likeCount likes',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          // Caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${username ?? 'User'} ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  TextSpan(
                    text: caption ?? '',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
            ),
          ),

          // View All Comments
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: InkWell(
              onTap: () {
                // TODO: Navigate to view all comments
                print('View all $commentCount comments on post $postId');
              },
              child: Text(
                'View all $commentCount comments',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
          // Timestamp (If you have it in your data)
          // if (timestamp != null)
          //   Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          //     child: Text(
          //       timeago.format(timestamp.toDate()), // Example using timeago package
          //       style: const TextStyle(color: Colors.grey, fontSize: 12.0),
          //     ),
          //   ),
          const SizedBox(height: 8.0),
        ],
      ),
    );
  }
}
