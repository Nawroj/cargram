import 'package:flutter/material.dart';

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
        return const Center(child: Text('Feed Screen'));
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
}
