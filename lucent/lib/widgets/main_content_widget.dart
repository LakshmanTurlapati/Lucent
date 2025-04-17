import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart'; // Remove old import
// import 'dart:convert'; // No longer needed for style JSON
// import 'package:flutter/services.dart' show rootBundle; // No longer needed for style JSON
// import 'dart:io' show Platform; // No longer needed for platform check
// import 'package:flutter/foundation.dart' show kIsWeb; // No longer needed for platform check

import 'package:flutter_map/flutter_map.dart'; // Import flutter_map
import 'package:latlong2/latlong.dart'; // Import latlong2
import 'package:http/http.dart' as http;
import 'dart:convert';
// placeholder_card.dart is no longer needed here

// Keep original class name
class MainContentWidget extends StatefulWidget {
  const MainContentWidget({super.key});

  @override
  State<MainContentWidget> createState() => _MainContentWidgetState();
}

// Keep original state class name
class _MainContentWidgetState extends State<MainContentWidget> {
  // No GoogleMapController or map style needed anymore
  // GoogleMapController? _mapController;
  // String? _mapStyle;

  // Define styling locally or pass via constructor if needed elsewhere
  final Color mapBackgroundColor = const Color(0xFF3A3A3C);
  final BorderRadius mapBorderRadius = const BorderRadius.all(Radius.circular(16.0));
  
  // Define orange accent color for map elements
  final Color accentColor = const Color(0xFFFF9500); // Apple-like orange accent
  
  // Search controller
  final TextEditingController _searchController = TextEditingController();
  
  // Initial map center (Richardson, TX)
  final LatLng _initialCenter = const LatLng(32.9483, -96.7298);
  final double _initialZoom = 13.0;
  
  // Current map center (updated when search location changes)
  LatLng _currentCenter = const LatLng(32.9483, -96.7298);
  
  // List of markers for search results
  List<Marker> _markers = [];
  
  // Mock route polyline (will display when a destination is selected)
  List<Polyline> _polylines = [];
  
  // MapController for programmatic control
  final MapController _mapController = MapController();
  
  // List of preset locations for demo search (to avoid needing geocoding APIs)
  final Map<String, LatLng> _presetLocations = {
    'richardson': LatLng(32.9483, -96.7298),
    'university of texas at dallas': LatLng(32.9801, -96.7523),
    'utd': LatLng(32.9801, -96.7523),
    'dallas': LatLng(32.7767, -96.7970),
    'fort worth': LatLng(32.7555, -97.3308),
    'plano': LatLng(33.0198, -96.6989),
    'frisco': LatLng(33.1507, -96.8236),
    'mckinney': LatLng(33.1972, -96.6397),
    'allen': LatLng(33.1031, -96.6789),
    'addison': LatLng(32.9312, -96.8361),
    'garland': LatLng(32.9126, -96.6389),
  };
  
  // Flag to show if a search has been performed
  bool _hasSearched = false;
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  // Function to perform search
  void _performSearch() {
    final searchText = _searchController.text.trim().toLowerCase();
    
    if (searchText.isEmpty) {
      return;
    }
    
    setState(() {
      _hasSearched = true;
      
      // Check if the search term matches any preset location
      LatLng? searchLocation;
      
      // Try exact match first
      if (_presetLocations.containsKey(searchText)) {
        searchLocation = _presetLocations[searchText];
      } else {
        // Try partial match
        for (final entry in _presetLocations.entries) {
          if (entry.key.contains(searchText) || searchText.contains(entry.key)) {
            searchLocation = entry.value;
            break;
          }
        }
      }
      
      if (searchLocation != null) {
        // Update center and create a marker
        _currentCenter = searchLocation;
        
        // Move map to the searched location
        _mapController.move(searchLocation, 14.0);
        
        // Create markers: origin (current location) and destination
        _markers = [
          // Origin marker (Richardson as default start point)
          Marker(
            point: _initialCenter,
            width: 60,
            height: 60,
            child: Icon(
              Icons.location_on,
              color: Colors.blue,
              size: 30,
            ),
          ),
          // Destination marker
          Marker(
            point: searchLocation,
            width: 60, 
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Orange circle shadow/halo
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
                // Pin icon
                Icon(
                  Icons.location_pin,
                  color: accentColor,
                  size: 30,
                ),
              ],
            ),
          ),
        ];
        
        // Get real route data from OSRM
        _getRouteFromOSRM(_initialCenter, searchLocation);
      } else {
        // Not found - reset
        _markers = [];
        _polylines = [];
      }
    });
  }
  
  // Fetch real route data from Open Source Routing Machine (OSRM)
  Future<void> _getRouteFromOSRM(LatLng origin, LatLng destination) async {
    try {
      // OSRM public API endpoint (driving profile)
      final String url = 'https://router.project-osrm.org/route/v1/driving/'
          '${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}'
          '?overview=full&geometries=geojson';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          // Extract the route coordinates (GeoJSON format)
          final route = data['routes'][0];
          final geometry = route['geometry'];
          final List<dynamic> coordinates = geometry['coordinates'];
          
          // Convert to List<LatLng>
          List<LatLng> routePoints = coordinates.map<LatLng>((coord) {
            // OSRM returns [longitude, latitude] format
            return LatLng(coord[1], coord[0]);
          }).toList();
          
          // Update the polyline
          setState(() {
            _polylines = [
              Polyline(
                points: routePoints,
                color: accentColor,
                strokeWidth: 6.0,
              ),
            ];
          });
        }
      } else {
        print('Failed to get route: ${response.statusCode}');
        // Fall back to mock route if API fails
        _createMockRoute(origin, destination);
      }
    } catch (e) {
      print('Error fetching route: $e');
      // Fall back to mock route if API fails
      _createMockRoute(origin, destination);
    }
  }
  
  // Creates a simple mock route between origin and destination
  // This will be used as a fallback if the OSRM API request fails
  void _createMockRoute(LatLng origin, LatLng destination) {
    // Create a more realistic route that simulates following road networks
    List<LatLng> routePoints = [];
    
    // Direction vectors for grid-like movement
    double latDiff = destination.latitude - origin.latitude;
    double lngDiff = destination.longitude - origin.longitude;
    
    // Add origin point
    routePoints.add(origin);
    
    // Current position
    double currentLat = origin.latitude;
    double currentLng = origin.longitude;
    
    // Decide if we move in latitude first or longitude first based on which is greater
    bool moveLatFirst = latDiff.abs() > lngDiff.abs();
    
    if (moveLatFirst) {
      // Move mostly in latitude direction first (north/south)
      
      // First segment: Move 70% of latitude distance
      currentLat += latDiff * 0.7;
      // Add small east/west movements to simulate turns
      routePoints.add(LatLng(currentLat, currentLng + lngDiff * 0.1));
      
      // Then move 40% of longitude distance (east/west)
      currentLng += lngDiff * 0.4;
      routePoints.add(LatLng(currentLat, currentLng));
      
      // Then continue remaining latitude distance
      currentLat = destination.latitude;
      routePoints.add(LatLng(currentLat, currentLng));
      
      // Finally, move to destination longitude
      currentLng = destination.longitude;
      routePoints.add(LatLng(currentLat, currentLng));
    } else {
      // Move mostly in longitude direction first (east/west)
      
      // First segment: Move 70% of longitude distance
      currentLng += lngDiff * 0.7;
      // Add small north/south movements to simulate turns
      routePoints.add(LatLng(currentLat + latDiff * 0.1, currentLng));
      
      // Then move 40% of latitude distance (north/south)
      currentLat += latDiff * 0.4;
      routePoints.add(LatLng(currentLat, currentLng));
      
      // Then continue remaining longitude distance
      currentLng = destination.longitude;
      routePoints.add(LatLng(currentLat, currentLng));
      
      // Finally, move to destination latitude
      currentLat = destination.latitude;
      routePoints.add(LatLng(currentLat, currentLng));
    }
    
    // Add some zigzags to the route to simulate following a street grid
    List<LatLng> enhancedRoutePoints = [routePoints.first];
    
    for (int i = 1; i < routePoints.length; i++) {
      LatLng start = routePoints[i-1];
      LatLng end = routePoints[i];
      
      // For longer segments, add intermediate points with slight offsets
      double segmentLat = end.latitude - start.latitude;
      double segmentLng = end.longitude - start.longitude;
      double distance = (segmentLat.abs() + segmentLng.abs()) * 111000; // rough meters
      
      if (distance > 1000) { // if segment is longer than ~1km
        // Add some intermediate points with slight offsets
        LatLng mid1 = LatLng(
          start.latitude + segmentLat * 0.33, 
          start.longitude + segmentLng * 0.33 + (segmentLng > 0 ? 0.0015 : -0.0015)
        );
        
        LatLng mid2 = LatLng(
          start.latitude + segmentLat * 0.66,
          start.longitude + segmentLng * 0.66 + (segmentLng > 0 ? -0.0015 : 0.0015)
        );
        
        enhancedRoutePoints.add(mid1);
        enhancedRoutePoints.add(mid2);
      }
      
      enhancedRoutePoints.add(end);
    }
    
    // Ensure the destination is the last point
    if (enhancedRoutePoints.last != destination) {
      enhancedRoutePoints.add(destination);
    }
    
    _polylines = [
      Polyline(
        points: enhancedRoutePoints,
        color: accentColor,
        strokeWidth: 6.0,
      ),
    ];
  }
  
  // Get filtered search suggestions based on current input
  List<MapEntry<String, LatLng>> _getSearchSuggestions() {
    final searchText = _searchController.text.trim().toLowerCase();
    if (searchText.isEmpty) {
      return [];
    }
    
    // Filter locations that match the search text
    final matches = _presetLocations.entries
        .where((entry) => entry.key.contains(searchText))
        .toList();
    
    // Sort by relevance (exact match first, then by name length for more specific matches)
    matches.sort((a, b) {
      // Exact match gets highest priority
      if (a.key == searchText) return -1;
      if (b.key == searchText) return 1;
      
      // Shorter names (more specific matches) get higher priority
      return a.key.length.compareTo(b.key.length);
    });
    
    // Limit results for better UI
    return matches.take(5).toList();
  }
  
  // Calculate mock distance from current center to destination
  String _getDistanceText(LatLng destination) {
    // Calculate rough distance in miles (very approximate)
    final latDiff = (_initialCenter.latitude - destination.latitude).abs();
    final lngDiff = (_initialCenter.longitude - destination.longitude).abs();
    
    // Very simple distance formula (not accurate for real-world use)
    final approxDistance = (latDiff + lngDiff) * 69; // ~69 miles per degree
    
    return '${approxDistance.toStringAsFixed(1)} mi';
  }
  
  @override
  Widget build(BuildContext context) {
    // No platform check needed, flutter_map works cross-platform
    // bool isSupportedPlatform = kIsWeb || (!kIsWeb && (Platform.isAndroid || Platform.isIOS));

    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: mapBackgroundColor,
        borderRadius: mapBorderRadius,
      ),
      child: Stack(
        children: [
          // Map fills the entire container
          ClipRRect(
            borderRadius: mapBorderRadius,
            child: Stack(
              children: [
                // Map base
                FlutterMap(
                  options: MapOptions(
                    initialCenter: _initialCenter,
                    initialZoom: _initialZoom,
                  ),
                  mapController: _mapController,
                  children: [
                    // Dark tile layer
                    TileLayer(
                      // Use CartoDB Dark Matter tiles (no API key required)
                      urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                      userAgentPackageName: 'com.example.lucent',
                    ),
                    // Add markers
                    MarkerLayer(markers: _markers),
                    // Add polylines
                    PolylineLayer(polylines: _polylines),
                  ],
                ),
                
                // Semi-transparent color overlay to match app theme
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      // Using a slightly darker overlay with reduced opacity
                      // This creates better contrast to make white text stand out
                      color: const Color(0xFF1A1E28).withOpacity(0.2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Search bar overlay
          Positioned(
            top: 20.0,
            left: 20.0,
            right: 20.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 50.0,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Search icon
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Icon(Icons.search, color: Colors.grey[400]),
                      ),
                      // Text field
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search for a destination...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey[500]),
                          ),
                          style: TextStyle(color: Colors.white),
                          onSubmitted: (_) => _performSearch(),
                        ),
                      ),
                      // Search button
                      Material(
                        color: Colors.transparent,
                        child: IconButton(
                          icon: Icon(Icons.arrow_forward, color: accentColor),
                          onPressed: _performSearch,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Dropdown for search results
                if (_searchController.text.isNotEmpty && !_hasSearched)
                  Container(
                    margin: EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: _getSearchSuggestions().map((suggestion) {
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              _searchController.text = suggestion.key;
                              _performSearch();
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 12.0,
                                horizontal: 16.0,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.place_outlined,
                                    color: Colors.grey[400],
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      suggestion.key,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _getDistanceText(suggestion.value),
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
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
          
          // Destination info overlay (shows when a search result is found)
          if (_hasSearched && _markers.length > 1)
            Positioned(
              bottom: 20.0,
              left: 20.0,
              right: 20.0,
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: accentColor),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            _searchController.text,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ETA: 15 minutes',
                          style: TextStyle(color: Colors.grey[300]),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            '5.2 miles',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
} 