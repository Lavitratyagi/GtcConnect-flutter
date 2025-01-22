import 'package:flutter/material.dart';
import 'package:gtcconnect/bottom_nav_bar.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed Page'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: const [
          PostCard(
            clubName: 'Galgotias Tech Council',
            postDate: '09th Nov, 24',
            postImage: 'assets/images/gtc_image.png',
            description:
                'Galgotias Tech Council Successfully hosted the inauguration of Tech Council in Galgotias University... more',
          ),
          PostCard(
            clubName: 'Mobile Development',
            postDate: '11th Nov, 24',
            postImage: 'assets/images/mobile_dev_image.png',
            description:
                'Active participation shown by the club leads and members during the GTC inauguration.',
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final String clubName;
  final String postDate;
  final String postImage;
  final String description;

  const PostCard({
    super.key,
    required this.clubName,
    required this.postDate,
    required this.postImage,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(postImage),
            ),
            title: Text(
              clubName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(postDate),
          ),
          Image.asset(postImage, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(description),
          ),
        ],
      ),
    );
  }
}

// Dummy Pages for Navigation
class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover Page')),
      body: const Center(child: Text('Discover Page')),
    );
  }
}

class ClubsPage extends StatelessWidget {
  const ClubsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clubs Page')),
      body: const Center(child: Text('Clubs Page')),
    );
  }
}
