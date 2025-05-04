import 'package:borktok/screens/buy%20and%20sell/doglistingmodel.dart';
import 'package:borktok/screens/buy%20and%20sell/doglistingservice.dart';
import 'package:borktok/screens/buy%20and%20sell/sellyourdog.dart';
import 'package:flutter/material.dart';

class DogListingsScreen extends StatefulWidget {
  const DogListingsScreen({Key? key}) : super(key: key);

  @override
  _DogListingsScreenState createState() => _DogListingsScreenState();
}

class _DogListingsScreenState extends State<DogListingsScreen> {
  final _dogListingService = DogListingService();
  List<DogListing> _dogListings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDogListings();
  }

  Future<void> _fetchDogListings() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final listings = await _dogListingService.getAllDogListings();

      setState(() {
        _dogListings = listings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load dog listings: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0), // Warm beige background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5D4A0), // Soft golden background
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/logo.png', 
            height: 30, 
            width: 30,
            fit: BoxFit.contain,
          ),
        ),
        title: Text(
          'Dog Listings',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.brown[800],
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.brown[800]),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SellDogScreen()),
              ).then(
                (_) => _fetchDogListings(),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDogListings,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF5D4A0)),
                ),
              )
            : _dogListings.isEmpty
                ? Center(
                    child: Text(
                      'No dog listings available',
                      style: TextStyle(color: Colors.brown[700]),
                    ),
                  )
                : ListView.builder(
                    itemCount: _dogListings.length,
                    itemBuilder: (context, index) {
                      final listing = _dogListings[index];
                      return DogListingCard(dogListing: listing);
                    },
                  ),
      ),
    );
  }
}

class DogListingCard extends StatelessWidget {
  final DogListing dogListing;

  const DogListingCard({Key? key, required this.dogListing}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dog Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                dogListing.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dog Name and Breed
                Text(
                  '${dogListing.name} - ${dogListing.breed}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[800],
                  ),
                ),
                const SizedBox(height: 8),

                // Dog Details
                Row(
                  children: [
                    Icon(Icons.pets, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Text('${dogListing.age} years old • ${dogListing.gender}'),
                  ],
                ),
                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(dogListing.location),
                  ],
                ),
                const SizedBox(height: 8),

                // Price and Description
                Text(
                  '\$${dogListing.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.brown[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dogListing.description,
                  style: TextStyle(color: Colors.brown[700]),
                ),
                const SizedBox(height: 8),

                // Owner Info
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      child: Icon(Icons.person, color: Colors.brown[800]),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Listed by ${dogListing.ownerName}',
                      style: TextStyle(color: Colors.brown[600]),
                    ),
                    const Spacer(),
                    Text(
                      '${_getTimeAgo(dogListing.datePosted)}',
                      style: TextStyle(
                        color: Colors.grey[600], 
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                
                // Vaccination status indicator (if certificate exists)
                if (dogListing.vaccinationCertificateUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.verified, 
                          color: Colors.green[700], 
                          size: 16
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Vaccination verified',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month(s) ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day(s) ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s) ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute(s) ago';
    } else {
      return 'Just now';
    }
  }
}