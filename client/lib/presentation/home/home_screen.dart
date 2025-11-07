// home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:trekka/config/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedMood = 'Peaceful';
  final List<Map<String, dynamic>> _recommendations = [
    {
      'id': 1,
      'name': 'Tranquil Café',
      'icon': '☕',
      'rating': 4.8,
      'distance': 500,
      'tags': ['Indoor', 'Quiet'],
      'price': '40–60k VND',
      'image': 'assets/images/cafe.jpg',
    },
    {
      'id': 2,
      'name': 'Art Museum',
      'icon': '🖼',
      'rating': 4.6,
      'distance': 1200,
      'tags': ['Cultural', 'Indoor'],
      'price': '100k VND',
      'image': 'assets/images/museum.jpg',
    },
    {
      'id': 3,
      'name': 'Noodle Street',
      'icon': '🍜',
      'rating': 4.7,
      'distance': 800,
      'tags': ['Food', 'Popular'],
      'price': '30–50k VND',
      'image': 'assets/images/noodle_street.jpg',
    },
  ];

  int _currentBottomNavIndex = 0;

  void _onViewDetails(int poiId) {
    Navigator.pushNamed(context, AppRoutes.poiDetail, arguments: poiId);
  }

  void _onSave(int poiId) {
    // Handle save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved POI $poiId')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
        ),
        title: Row(
          children: [
            const Icon(Icons.wb_sunny, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            const Text(
              '28°C • Hanoi',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.black),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mood Selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text(
                  'Current Mood:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedMood,
                      icon: const Icon(Icons.arrow_drop_down, size: 20),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedMood = newValue!;
                        });
                      },
                      items: <String>['Peaceful', 'Adventurous', 'Cultural', 'Foodie', 'Social']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Recommendations Header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '✨ Recommended For You',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Recommendations List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _recommendations.length,
              itemBuilder: (context, index) {
                final poi = _recommendations[index];
                return _buildRecommendationCard(poi);
              },
            ),
          ),

          // Load More Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Load More ↓'),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> poi) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  poi['icon'],
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    poi['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                Text(' ${poi['rating']}'),
                const SizedBox(width: 8),
                const Icon(Icons.location_on, size: 16),
                Text(' ${poi['distance']}m away'),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: poi['tags'].map<Widget>((tag) {
                return Chip(
                  label: Text(
                    tag,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.grey[100],
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              '💰 ${poi['price']}',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _onSave(poi['id']),
                  icon: const Icon(Icons.bookmark_border, size: 18),
                  label: const Text('Save'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => _onViewDetails(poi['id']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F6EF7),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('View Details →'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentBottomNavIndex,
      onTap: (index) {
        setState(() {
          _currentBottomNavIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF4F6EF7),
      unselectedItemColor: Colors.grey[600],
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.airplanemode_active),
          label: 'Trip',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}