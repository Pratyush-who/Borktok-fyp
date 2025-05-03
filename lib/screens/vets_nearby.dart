import 'package:flutter/material.dart';

class VetsNearby extends StatefulWidget {
  const VetsNearby({super.key});

  @override
  State<VetsNearby> createState() => _VetsNearbyState();
}

class _VetsNearbyState extends State<VetsNearby> {
  // Search controller
  final TextEditingController _searchController = TextEditingController();
  
  // Selected location filter
  String _selectedLocation = 'All';
  final List<String> _locations = ['All', 'Delhi', 'Noida', 'Ghaziabad'];
  
  // Define colors to match the existing app theme
  final Color _primaryGreen = const Color(0xFF5C8D89);
  final Color _lightBeige = const Color(0xFFF5F5DC);
  final Color _darkBeige = const Color(0xFFE6E6C9);
  final Color _accentColor = const Color(0xFF93B5B3);
  
  // List of veterinary hospitals
  final List<Map<String, dynamic>> _allVets = [
    {
      'name': 'PetCare Veterinary Hospital',
      'location': 'Delhi',
      'address': '123 Connaught Place, New Delhi',
      'rating': 4.8,
      'specialization': 'General, Surgery, Dental',
      'distance': '2.5 km',
      'image': 'assets/images/vet1.png',
      'contact': '+91 98765 43210',
      'availability': 'Open 24/7',
      'facilities': ['Emergency Care', 'Surgery', 'Pet Pharmacy', 'Boarding'],
    },
    {
      'name': 'Happy Paws Clinic',
      'location': 'Delhi',
      'address': '456 Vasant Kunj, New Delhi',
      'rating': 4.5,
      'specialization': 'Surgery, Grooming',
      'distance': '5.1 km',
      'image': 'assets/images/vet2.png',
      'contact': '+91 98765 12345',
      'availability': 'Mon-Sat: 9am-8pm',
      'facilities': ['Pet Grooming', 'Vaccination', 'Nutritional Counseling'],
    },
    {
      'name': 'Delhi Veterinary Center',
      'location': 'Delhi',
      'address': '789 Dwarka, New Delhi',
      'rating': 4.7,
      'specialization': 'Orthopedics, Neurology',
      'distance': '7.3 km',
      'image': 'assets/images/vet3.png',
      'contact': '+91 98123 45678',
      'availability': 'Mon-Sun: 8am-10pm',
      'facilities': ['Advanced Diagnostics', 'Pet Insurance', 'Rehabilitation'],
    },
    {
      'name': 'Noida Pet Hospital',
      'location': 'Noida',
      'address': '101 Sector 18, Noida',
      'rating': 4.6,
      'specialization': 'Cardiology, Dermatology',
      'distance': '4.2 km',
      'image': 'assets/images/vet4.png',
      'contact': '+91 97654 32109',
      'availability': 'Mon-Sun: 9am-9pm',
      'facilities': ['Pet Boarding', 'Emergency Care', 'Pet Dental Care'],
    },
    {
      'name': 'Paws & Claws Clinic',
      'location': 'Noida',
      'address': '202 Sector 62, Noida',
      'rating': 4.4,
      'specialization': 'Preventive Care, Nutrition',
      'distance': '6.7 km',
      'image': 'assets/images/vet5.png',
      'contact': '+91 98765 98765',
      'availability': 'Mon-Sat: 10am-7pm',
      'facilities': ['Vaccination', 'Pet Grooming', 'Pet Training'],
    },
    {
      'name': 'Ghaziabad Animal Hospital',
      'location': 'Ghaziabad',
      'address': '303 Indirapuram, Ghaziabad',
      'rating': 4.9,
      'specialization': 'Surgery, Emergency Care',
      'distance': '8.5 km',
      'image': 'assets/images/vet6.png',
      'contact': '+91 99876 54321',
      'availability': 'Open 24/7',
      'facilities': ['ICU', 'Surgery', 'Lab Services', 'Pet Pharmacy'],
    },
    {
      'name': 'Pet Health Center',
      'location': 'Ghaziabad',
      'address': '404 Vaishali, Ghaziabad',
      'rating': 4.7,
      'specialization': 'Geriatric Care, Ophthalmology',
      'distance': '9.3 km',
      'image': 'assets/images/vet7.png',
      'contact': '+91 98123 87654',
      'availability': 'Mon-Sun: 8am-8pm',
      'facilities': ['Eye Treatments', 'Senior Pet Care', 'Pet Pharmacy'],
    },
    {
      'name': 'Max Veterinary Care',
      'location': 'Delhi',
      'address': '505 Rohini, New Delhi',
      'rating': 4.5,
      'specialization': 'Dentistry, Internal Medicine',
      'distance': '11.2 km',
      'image': 'assets/images/vet8.png',
      'contact': '+91 99123 45678',
      'availability': 'Mon-Sun: 9am-10pm',
      'facilities': ['Dental Services', 'Ultrasound', 'X-Ray'],
    },
  ];
  
  // Filtered list of vets
  List<Map<String, dynamic>> _filteredVets = [];
  
  @override
  void initState() {
    super.initState();
    _filteredVets = _allVets;
    
    // Add listener to search field
    _searchController.addListener(_filterVets);
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  // Filter vets based on search text and selected location
  void _filterVets() {
    setState(() {
      final String searchText = _searchController.text.toLowerCase();
      
      _filteredVets = _allVets.where((vet) {
        final bool matchesLocation = _selectedLocation == 'All' || 
                                   vet['location'] == _selectedLocation;
        
        final bool matchesSearch = searchText.isEmpty ||
                                vet['name'].toLowerCase().contains(searchText) ||
                                vet['specialization'].toLowerCase().contains(searchText) ||
                                vet['address'].toLowerCase().contains(searchText);
        
        return matchesLocation && matchesSearch;
      }).toList();
    });
  }
  
  // Change location filter
  void _changeLocation(String? location) {
    if (location != null && location != _selectedLocation) {
      setState(() {
        _selectedLocation = location;
        _filterVets();
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Veterinary Clinics Nearby',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header with curved background and search
          Container(
            padding: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: _primaryGreen,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by name, specialization, or location',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        prefixIcon: Icon(Icons.search, color: _primaryGreen),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ),
                
                // Location filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: _locations.map((location) {
                      final bool isSelected = location == _selectedLocation;
                      return GestureDetector(
                        onTap: () => _changeLocation(location),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? _primaryGreen : Colors.transparent,
                              width: isSelected ? 2 : 0,
                            ),
                          ),
                          child: Text(
                            location,
                            style: TextStyle(
                              color: isSelected ? _primaryGreen : Colors.white,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          // Results count
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  'Found ${_filteredVets.length} veterinary clinics',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Vet listings
          Expanded(
            child: _filteredVets.isEmpty 
            ? _buildNoResultsFound()
            : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: _filteredVets.length,
              itemBuilder: (context, index) {
                final vet = _filteredVets[index];
                return _buildVetCard(vet, context);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNoResultsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: _primaryGreen.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No veterinary clinics found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try changing your search or filters',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildVetCard(Map<String, dynamic> vet, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Clinic image with rating overlay
          Stack(
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.asset(
                  vet['image'],
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Placeholder when image is not available
                    return Container(
                      height: 150,
                      width: double.infinity,
                      color: _lightBeige,
                      child: Icon(
                        Icons.pets,
                        size: 60,
                        color: _primaryGreen.withOpacity(0.5),
                      ),
                    );
                  },
                ),
              ),
              
              // Rating badge
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${vet['rating']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Location badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _primaryGreen,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        vet['location'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Distance badge
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.directions,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        vet['distance'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Clinic details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Clinic name
                Text(
                  vet['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Address
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        vet['address'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 6),
                
                // Contact number
                Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      vet['contact'],
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 6),
                
                // Availability
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      vet['availability'],
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Specialization chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: vet['specialization'].split(', ').map<Widget>((specialization) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _primaryGreen.withOpacity(0.3)),
                      ),
                      child: Text(
                        specialization,
                        style: TextStyle(
                          fontSize: 12,
                          color: _primaryGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 16),
                
                // Facilities
                Text(
                  'Facilities',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _primaryGreen,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Facility list
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (vet['facilities'] as List).map<Widget>((facility) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: _primaryGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          facility,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                      ],
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 16),
                
                // Action buttons
                Row(
                  children: [
                    // Call button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Call functionality would go here
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Calling ${vet['name']}...'),
                              backgroundColor: _primaryGreen,
                            ),
                          );
                        },
                        icon: const Icon(Icons.phone),
                        label: const Text('Call'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _primaryGreen,
                          side: BorderSide(color: _primaryGreen),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Book appointment button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to book appointment page
                          Navigator.pushNamed(context, '/bookavet');
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Book'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}