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
import 'dart:math'; // Add math import for Random
import '../utils/weather_service.dart'; // Import weather service for location data
import '../theme/app_themes.dart'; // Import app themes
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
  late Color mapBackgroundColor;
  late Color cardBackgroundColor;
  late Color accentColor;
  late Color textColor;
  late Color secondaryTextColor;
  late Color inputBackgroundColor;
  
  // Search controller
  final TextEditingController _searchController = TextEditingController();
  
  // Default initial map center (Richardson, TX as fallback)
  final LatLng _defaultCenter = const LatLng(32.9483, -96.7298);
  
  // User's current location (will be updated with actual location)
  LatLng _userLocation = const LatLng(32.9483, -96.7298);
  
  // Initial zoom level
  final double _initialZoom = 13.0;
  
  // Current zoom level - track this for zoom controls
  double _currentZoom = 13.0;
  
  // Min and max zoom levels
  final double _minZoom = 3.0;
  final double _maxZoom = 18.0;
  
  // Zoom step for buttons
  final double _zoomStep = 1.0;
  
  // Current map center (updated when search location or user location changes)
  LatLng _currentCenter = const LatLng(32.9483, -96.7298);
  
  // Current map bounds
  LatLngBounds? _currentBounds;
  
  // Flag to indicate if user location has been obtained
  bool _hasUserLocation = false;
  
  // List of markers for search results and user location
  List<Marker> _markers = [];
  
  // Route polyline (will display when a destination is selected)
  List<Polyline> _polylines = [];
  
  // MapController for programmatic control
  final MapController _mapController = MapController();
  
  // Selected destination info for the bottom sheet
  Map<String, dynamic>? _selectedDestination;
  
  // Estimated travel time (in minutes)
  int _estimatedTimeMinutes = 0;
  
  // Flag to indicate map is ready
  bool _mapInitialized = false;
  
  // Flag to show if a search has been performed
  bool _hasSearched = false;
  
  // Flag to show search results dropdown
  bool _showSearchResults = false;
  
  // List of search results with distances
  List<Map<String, dynamic>> _searchResults = [];
  
  // Waypoints for the route (will be used for actual routing)
  List<LatLng> _routeWaypoints = [];
  
  // Minimum number of search results to show
  final int _minSearchResults = 5;
  
  // Search in progress indicator
  bool _isSearching = false;
  
  @override
  void initState() {
    super.initState();
    // Get user's current location immediately
    _initializeLocationAndMap();
  }
  
  // Initialize location and map
  Future<void> _initializeLocationAndMap() async {
    // Get user's current location with a higher priority
    await _getUserLocation();
    
    // Initialize map with user location or default
    setState(() {
      _mapInitialized = true;
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  // Set theme-dependent colors
  void _updateThemeColors(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Set colors based on theme
    mapBackgroundColor = isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA);
    cardBackgroundColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    accentColor = isDark ? const Color(0xFFFF9500) : const Color(0xFF007AFF); // Orange in dark, blue in light
    textColor = theme.textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black);
    secondaryTextColor = theme.textTheme.bodySmall?.color ?? (isDark ? Colors.grey[400]! : Colors.grey[600]!);
    inputBackgroundColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
  }
  
  // Get user's current location from WeatherService
  Future<void> _getUserLocation() async {
    try {
      final position = await WeatherService.getCurrentLocation();
      
      if (position != null && mounted) {
        setState(() {
          // Update user location
          _userLocation = LatLng(position.latitude, position.longitude);
          _currentCenter = _userLocation;
          _hasUserLocation = true;
          
          print("Location obtained: ${position.latitude}, ${position.longitude}");
          
          // If map is already initialized, move to user location
          if (_mapController != null) {
            _mapController.move(_userLocation, _initialZoom);
          }
          
          // Add user location marker
          _updateUserLocationMarker();
        });
      } else {
        print("Failed to get location or position is null");
        _useDefaultLocation();
      }
    } catch (e) {
      print("Error getting user location: $e");
      _useDefaultLocation();
    }
  }
  
  // Fall back to default location
  void _useDefaultLocation() {
    if (mounted) {
      setState(() {
        _userLocation = _defaultCenter;
        _currentCenter = _defaultCenter;
        
        // Add default location marker
        _updateUserLocationMarker();
      });
    }
  }
  
  // Update the user location marker
  void _updateUserLocationMarker() {
    _updateThemeColors(context);
    List<Marker> updatedMarkers = [];
    
    // Add user location marker
    updatedMarkers.add(
      Marker(
        point: _userLocation,
        width: 60,
        height: 60,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Blue circle for user location with pulsing effect
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.3),
                shape: BoxShape.circle,
                border: Border.all(color: accentColor, width: 2),
              ),
            ),
            // Inner dot for precise location
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
    
    // If search has been performed, keep the destination marker
    if (_hasSearched && _markers.length > 1) {
      // Keep only the destination marker (the one that's not at user location)
      for (var marker in _markers) {
        if (marker.point != _userLocation) {
          updatedMarkers.add(marker);
        }
      }
    }
    
    setState(() {
      _markers = updatedMarkers;
    });
  }
  
  // Calculate distance between two coordinates in kilometers
  double _calculateDistance(LatLng start, LatLng end) {
    // Use the Distance class from latlong2 package
    final Distance distance = Distance();
    return distance.as(LengthUnit.Mile, start, end);
  }
  
  // Format distance for display
  String _formatDistance(double distanceMiles) {
    if (distanceMiles < 0.1) {
      // If less than 0.1 mile, show in feet
      return '${(distanceMiles * 5280).toStringAsFixed(0)} ft';
    } else if (distanceMiles < 1) {
      // If less than 1 mile but more than 0.1, show with one decimal place
      return '${distanceMiles.toStringAsFixed(1)} mi';
    } else {
      // Otherwise show in miles with one decimal place
      return '${distanceMiles.toStringAsFixed(1)} mi';
    }
  }
  
  // Get map bounds
  LatLngBounds _getMapBounds() {
    if (_currentBounds != null) {
      return _currentBounds!;
    }
    
    // If bounds aren't set yet, approximate them from the center and zoom
    final double widthInDegrees = 360 / pow(2, _currentZoom);
    final double heightInDegrees = widthInDegrees / 2;
    
    return LatLngBounds(
      LatLng(_currentCenter.latitude - heightInDegrees, _currentCenter.longitude - widthInDegrees),
      LatLng(_currentCenter.latitude + heightInDegrees, _currentCenter.longitude + widthInDegrees),
    );
  }
  
  // Function to search for locations and show dropdown results
  Future<void> _searchLocations() async {
    final searchText = _searchController.text.trim();
    
    if (searchText.isEmpty) {
      setState(() {
        _showSearchResults = false;
        _searchResults = [];
      });
      return;
    }
    
    // Show loading indicator
    setState(() {
      _isSearching = true;
    });
    
    // Use our reliable local search function
    final results = _searchLocalData(searchText);
    
    setState(() {
      _searchResults = results;
      _showSearchResults = results.isNotEmpty;
      _isSearching = false;
    });
  }
  
  // Search in local data (reliable fallback)
  List<Map<String, dynamic>> _searchLocalData(String query) {
    // Normalize the query
    final String cleanQuery = query.toLowerCase().trim();
    
    // Common locations in Dallas area with real coordinates
    final Map<String, Map<String, dynamic>> localPlaces = {
      'dallas': {
        'name': 'Dallas',
        'coords': LatLng(32.7767, -96.7970),
        'type': 'city'
      },
      'downtown dallas': {
        'name': 'Downtown Dallas',
        'coords': LatLng(32.7814, -96.7970),
        'type': 'neighborhood'
      },
      'uptown dallas': {
        'name': 'Uptown Dallas',
        'coords': LatLng(32.7989, -96.8011),
        'type': 'neighborhood'
      },
      'deep ellum': {
        'name': 'Deep Ellum',
        'coords': LatLng(32.7844, -96.7786),
        'type': 'neighborhood'
      },
      'bishop arts district': {
        'name': 'Bishop Arts District',
        'coords': LatLng(32.7509, -96.8264),
        'type': 'neighborhood'
      },
      'klyde warren park': {
        'name': 'Klyde Warren Park',
        'coords': LatLng(32.7894, -96.8016),
        'type': 'park'
      },
      'reunion tower': {
        'name': 'Reunion Tower',
        'coords': LatLng(32.7759, -96.8108),
        'type': 'attraction'
      },
      'dallas farmers market': {
        'name': 'Dallas Farmers Market',
        'coords': LatLng(32.7801, -96.7919),
        'type': 'market'
      },
      'white rock lake': {
        'name': 'White Rock Lake',
        'coords': LatLng(32.8343, -96.7223),
        'type': 'lake'
      },
      'fair park': {
        'name': 'Fair Park',
        'coords': LatLng(32.7809, -96.7561),
        'type': 'park'
      },
      'dallas arboretum': {
        'name': 'Dallas Arboretum',
        'coords': LatLng(32.8191, -96.7170),
        'type': 'garden'
      },
      'dallas zoo': {
        'name': 'Dallas Zoo',
        'coords': LatLng(32.7417, -96.8153),
        'type': 'zoo'
      },
      'perot museum': {
        'name': 'Perot Museum',
        'coords': LatLng(32.7868, -96.8066),
        'type': 'museum'
      },
      'dallas museum of art': {
        'name': 'Dallas Museum of Art',
        'coords': LatLng(32.7875, -96.8014),
        'type': 'museum'
      },
      'american airlines center': {
        'name': 'American Airlines Center',
        'coords': LatLng(32.7905, -96.8100),
        'type': 'stadium'
      },
      'northpark center': {
        'name': 'NorthPark Center',
        'coords': LatLng(32.8684, -96.7730),
        'type': 'mall'
      },
      'galleria dallas': {
        'name': 'Galleria Dallas',
        'coords': LatLng(32.9309, -96.8211),
        'type': 'mall'
      },
      'highland park': {
        'name': 'Highland Park',
        'coords': LatLng(32.8312, -96.8005),
        'type': 'neighborhood'
      },
      'highland park village': {
        'name': 'Highland Park Village',
        'coords': LatLng(32.8337, -96.8060),
        'type': 'shopping'
      },
      'richardson': {
        'name': 'Richardson',
        'coords': LatLng(32.9483, -96.7298),
        'type': 'city'
      },
      'plano': {
        'name': 'Plano',
        'coords': LatLng(33.0198, -96.6989),
        'type': 'city'
      },
      'frisco': {
        'name': 'Frisco',
        'coords': LatLng(33.1507, -96.8236),
        'type': 'city'
      },
      'irving': {
        'name': 'Irving',
        'coords': LatLng(32.8140, -96.9489),
        'type': 'city'
      },
      'arlington': {
        'name': 'Arlington',
        'coords': LatLng(32.7357, -97.1081),
        'type': 'city'
      },
      'fort worth': {
        'name': 'Fort Worth',
        'coords': LatLng(32.7555, -97.3308),
        'type': 'city'
      },
      'dfw airport': {
        'name': 'DFW Airport',
        'coords': LatLng(32.8998, -97.0403),
        'type': 'airport'
      },
      'dallas love field': {
        'name': 'Dallas Love Field',
        'coords': LatLng(32.8471, -96.8518),
        'type': 'airport'
      },
      'university of texas at dallas': {
        'name': 'University of Texas at Dallas',
        'coords': LatLng(32.9801, -96.7523),
        'type': 'university'
      },
      'utd': {
        'name': 'UTD',
        'coords': LatLng(32.9801, -96.7523),
        'type': 'university'
      },
      'southern methodist university': {
        'name': 'Southern Methodist University',
        'coords': LatLng(32.8412, -96.7845),
        'type': 'university'
      },
      'smu': {
        'name': 'SMU',
        'coords': LatLng(32.8412, -96.7845),
        'type': 'university'
      },
      'baylor university medical center': {
        'name': 'Baylor University Medical Center',
        'coords': LatLng(32.7885, -96.7785),
        'type': 'hospital'
      },
      'ut southwestern medical center': {
        'name': 'UT Southwestern Medical Center',
        'coords': LatLng(32.8121, -96.8407),
        'type': 'hospital'
      },
      'parkland hospital': {
        'name': 'Parkland Hospital',
        'coords': LatLng(32.8093, -96.8388),
        'type': 'hospital'
      },
      'children\'s medical center': {
        'name': 'Children\'s Medical Center',
        'coords': LatLng(32.8091, -96.8373),
        'type': 'hospital'
      },
      'mockingbird station': {
        'name': 'Mockingbird Station',
        'coords': LatLng(32.8373, -96.7686),
        'type': 'transit'
      },
      'dart': {
        'name': 'DART Rail',
        'coords': LatLng(32.7801, -96.8066),
        'type': 'transit'
      },
      'trinity groves': {
        'name': 'Trinity Groves',
        'coords': LatLng(32.7781, -96.8311),
        'type': 'dining'
      },
      'bishop arts': {
        'name': 'Bishop Arts District',
        'coords': LatLng(32.7509, -96.8264),
        'type': 'neighborhood'
      },
      'west village': {
        'name': 'West Village',
        'coords': LatLng(32.8024, -96.8006),
        'type': 'shopping'
      },
      'addison': {
        'name': 'Addison',
        'coords': LatLng(32.9612, -96.8361),
        'type': 'city'
      },
      'farmers branch': {
        'name': 'Farmers Branch',
        'coords': LatLng(32.9269, -96.8916),
        'type': 'city'
      },
      'carrollton': {
        'name': 'Carrollton',
        'coords': LatLng(32.9756, -96.8897),
        'type': 'city'
      },
      'garland': {
        'name': 'Garland',
        'coords': LatLng(32.9126, -96.6389),
        'type': 'city'
      },
      'mckinney': {
        'name': 'McKinney',
        'coords': LatLng(33.1972, -96.6397),
        'type': 'city'
      },
      'allen': {
        'name': 'Allen',
        'coords': LatLng(33.1031, -96.6789),
        'type': 'city'
      },
      'lower greenville': {
        'name': 'Lower Greenville',
        'coords': LatLng(32.8206, -96.7700),
        'type': 'nightlife'
      },
      'uptown': {
        'name': 'Uptown Dallas',
        'coords': LatLng(32.7989, -96.8011),
        'type': 'neighborhood'
      },
      'downtown': {
        'name': 'Downtown Dallas',
        'coords': LatLng(32.7814, -96.7970),
        'type': 'neighborhood'
      }
    };
    
    List<Map<String, dynamic>> results = [];
    
    // Search the local data
    localPlaces.forEach((key, data) {
      // Check if location key or name contains the search query
      if (key.contains(cleanQuery) || data['name'].toString().toLowerCase().contains(cleanQuery)) {
        // Get coordinates
        final coords = data['coords'] as LatLng;
        
        // Calculate distance from user
        final double distance = _calculateDistance(_userLocation, coords);
        
        // Calculate score based on match quality and distance
        double score = 0;
        
        // Match quality scoring
        final name = data['name'].toString().toLowerCase();
        if (name == cleanQuery || key == cleanQuery) {
          score += 100; // Exact match
        } else if (name.startsWith(cleanQuery) || key.startsWith(cleanQuery)) {
          score += 80; // Starts with query
        } else if (name.contains(cleanQuery) || key.contains(cleanQuery)) {
          int nameIndex = name.contains(cleanQuery) ? name.indexOf(cleanQuery) : key.indexOf(cleanQuery);
          double positionScore = 70 * (1 - (nameIndex / name.length));
          score += positionScore;
        }
        
        // Distance scoring (closer is better)
        double distanceScore = 50 * (1 / (1 + distance * 0.1));
        score += distanceScore;
        
        // Add to results
        results.add({
          'name': data['name'],
          'coords': coords,
          'distance': distance,
          'formattedDistance': _formatDistance(distance),
          'score': score,
          'type': data['type'],
          'id': key,
        });
      }
    });
    
    // Sort results by score (high to low)
    results.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
    
    // Take the top 10 results
    if (results.length > 10) {
      results = results.sublist(0, 10);
    }
    
    // Ensure we have at least 5 results if any were found
    if (results.isNotEmpty && results.length < _minSearchResults) {
      // Add popular destinations as additional results
      final popularDestinations = [
        'downtown dallas',
        'uptown dallas',
        'deep ellum',
        'american airlines center',
        'klyde warren park',
        'reunion tower',
        'dallas farmers market',
        'northpark center',
        'galleria dallas',
        'lower greenville'
      ];
      
      for (final key in popularDestinations) {
        // Skip if already in results
        if (results.any((r) => r['id'] == key) || !localPlaces.containsKey(key)) {
          continue;
        }
        
        final data = localPlaces[key]!;
        final coords = data['coords'] as LatLng;
        final double distance = _calculateDistance(_userLocation, coords);
        
        results.add({
          'name': data['name'],
          'coords': coords,
          'distance': distance,
          'formattedDistance': _formatDistance(distance),
          'score': 10, // Low score for supplementary results
          'type': data['type'],
          'id': key,
        });
        
        // Break if we have enough results
        if (results.length >= _minSearchResults) {
          break;
        }
      }
      
      // Re-sort by score
      results.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
    }
    
    // If still no results, add a generic search result at current location
    if (results.isEmpty) {
      results.add({
        'name': 'Search for "$query"',
        'coords': _currentCenter,
        'distance': 0.0,
        'formattedDistance': _formatDistance(0.0),
        'score': 100,
        'type': 'search',
        'id': 'search_result',
      });
    }
    
    return results;
  }
  
  // Function to select a search result
  void _selectSearchResult(Map<String, dynamic> result) {
    setState(() {
      _hasSearched = true;
      _showSearchResults = false;
      
      // Update to selected location
      final selectedCoords = result['coords'] as LatLng;
      _currentCenter = selectedCoords;
      
      // Store selected destination info for the bottom sheet
      _selectedDestination = result;
      
      // Move map to selected location
      _mapController.move(_currentCenter, _currentZoom);
      
      // Add marker for searched location
      List<Marker> updatedMarkers = [];
      
      // Keep user location marker
      updatedMarkers.add(_markers.firstWhere(
        (marker) => marker.point == _userLocation,
        orElse: () => Marker(
          point: _userLocation,
          width: 60,
          height: 60,
          child: _buildUserLocationMarkerWidget(),
        ),
      ));
      
      // Add destination marker
      updatedMarkers.add(
        Marker(
          point: _currentCenter,
          width: 70,
          height: 70,
          child: _buildDestinationMarkerWidget(result['name']),
        ),
      );
      
      _markers = updatedMarkers;
      
      // Create an actual route between user location and destination
      _fetchRoute(_userLocation, _currentCenter);
    });
  }
  
  // Fetch a route between two points using a routing API
  Future<void> _fetchRoute(LatLng origin, LatLng destination) async {
    // Reset existing route
    setState(() {
      _polylines = [];
      _routeWaypoints = [];
    });
    
    try {
      // Use OSRM public API to get actual road routes
      // Format: http://router.project-osrm.org/route/v1/{profile}/{coordinates}
      final String originCoords = "${origin.longitude},${origin.latitude}";
      final String destCoords = "${destination.longitude},${destination.latitude}";
      final String url = "https://router.project-osrm.org/route/v1/driving/$originCoords;$destCoords?overview=full&geometries=geojson";
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['code'] == 'Ok' && data['routes'] != null && data['routes'].isNotEmpty) {
          // Extract the route geometry (as GeoJSON)
          final route = data['routes'][0];
          final geometry = route['geometry'];
          
          // Extract coordinates from GeoJSON
          final List<dynamic> coords = geometry['coordinates'];
          
          // Convert to LatLng points (OSRM returns [lon, lat] format, we need to swap to [lat, lon])
          List<LatLng> waypoints = coords.map<LatLng>((coord) => 
            LatLng(coord[1], coord[0])
          ).toList();
          
          // Get duration in seconds from the route
          final double durationSeconds = route['duration'] as double;
          
          // Calculate estimated time in minutes
          final int estimatedMinutes = (durationSeconds / 60).round();
          
          setState(() {
            _routeWaypoints = waypoints;
            _estimatedTimeMinutes = estimatedMinutes;
            
            // Create the polyline with the actual road route waypoints
            _polylines = [
              Polyline(
                points: waypoints,
                strokeWidth: 4.0,
                color: accentColor,
              ),
            ];
          });
        } else {
          throw Exception('No route found');
        }
      } else {
        throw Exception('Failed to fetch route: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching route: $e');
      // Fallback to a simple straight line if route fetch fails
      _createStraightLineRoute(origin, destination);
      
      // Estimate time based on distance for the fallback
      final double distanceMiles = _calculateDistance(origin, destination);
      // Assume average speed of 30 mph
      final int estimatedMinutes = (distanceMiles / 30 * 60).round();
      
      setState(() {
        _estimatedTimeMinutes = estimatedMinutes;
      });
    }
  }
  
  // Create a simple straight line route (fallback)
  void _createStraightLineRoute(LatLng origin, LatLng destination) {
    // For a simple mock route, create a straight line
    final List<LatLng> points = [origin, destination];
    
    // Add the polyline
    setState(() {
      _polylines = [
        Polyline(
          points: points,
          strokeWidth: 4.0,
          color: accentColor,
        ),
      ];
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // Update theme colors
    _updateThemeColors(context);
    final BorderRadius mapBorderRadius = const BorderRadius.all(Radius.circular(16.0));
    
    // Get light/dark state
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ClipRRect(
      borderRadius: mapBorderRadius,
      child: Container(
        decoration: BoxDecoration(
          color: mapBackgroundColor,
          borderRadius: mapBorderRadius,
        ),
        child: Stack(
          children: [
            // Map widget fills entire container
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _hasUserLocation ? _userLocation : _defaultCenter,
                initialZoom: _initialZoom,
                minZoom: _minZoom,
                maxZoom: _maxZoom,
                onPositionChanged: (position, hasGesture) {
                  _currentZoom = position.zoom ?? _currentZoom;
                  _currentCenter = position.center ?? _currentCenter;
                  
                  // Update bounds when map position changes
                  // Re-calculate using the current center and zoom
                  final double widthInDegrees = 360 / pow(2, _currentZoom);
                  final double heightInDegrees = widthInDegrees / 2;
                  
                  _currentBounds = LatLngBounds(
                    LatLng(_currentCenter.latitude - heightInDegrees, _currentCenter.longitude - widthInDegrees),
                    LatLng(_currentCenter.latitude + heightInDegrees, _currentCenter.longitude + widthInDegrees),
                  );
                },
                onMapReady: () {
                  // When map is ready, move to user location if available
                  if (_hasUserLocation) {
                    _mapController.move(_userLocation, _initialZoom);
                  }
                },
              ),
              children: [
                // Base tile layer (OSM tiles)
                TileLayer(
                  urlTemplate: isDark
                      ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                      : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.example.lucent',
                  tileProvider: NetworkTileProvider(),
                ),
                
                // Polylines layer for routes
                PolylineLayer(
                  polylines: _polylines,
                ),
                
                // Markers layer
                MarkerLayer(
                  markers: _markers,
                ),
              ],
            ),
            
            // Search bar at the top
            Positioned(
              top: 16.0,
              left: 16.0,
              right: 16.0,
              child: Column(
                children: [
                  // Search bar
                  Container(
                    height: 48.0,
                    decoration: BoxDecoration(
                      color: cardBackgroundColor,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8.0,
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: _isSearching 
                            ? SizedBox(
                                width: 20.0,
                                height: 20.0,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  color: secondaryTextColor,
                                ),
                              )
                            : Icon(
                                Icons.search,
                                color: secondaryTextColor,
                                size: 20.0,
                              ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            showCursor: true,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14.0,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search destinations...',
                              hintStyle: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 14.0,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                            ),
                            onChanged: (value) {
                              // Debounce search as user types (delay 500ms)
                              Future.delayed(const Duration(milliseconds: 500), () {
                                // Only search if the text is still the same after delay
                                if (value == _searchController.text && value.isNotEmpty) {
                                  _searchLocations();
                                }
                              });
                            },
                            onSubmitted: (_) {
                              // Search on submit
                              _searchLocations();
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: secondaryTextColor,
                            size: 20.0,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _showSearchResults = false;
                              _searchResults = [];
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // Search results dropdown
                  if (_showSearchResults)
                    Container(
                      margin: const EdgeInsets.only(top: 4.0),
                      decoration: BoxDecoration(
                        color: cardBackgroundColor,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8.0,
                            spreadRadius: 0.5,
                          ),
                        ],
                      ),
                      constraints: BoxConstraints(
                        maxHeight: 250.0, // Limit height
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final result = _searchResults[index];
                          return ListTile(
                            dense: true,
                            title: Text(
                              // Capitalize first letter of each word
                              result['name'].split(' ').map((word) => 
                                word.length > 0 ? word[0].toUpperCase() + word.substring(1) : ''
                              ).join(' '),
                              style: TextStyle(
                                color: textColor,
                                fontSize: 14.0,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Text(
                                  result['formattedDistance'],
                                  style: TextStyle(
                                    color: secondaryTextColor,
                                    fontSize: 12.0,
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                // Show place type if available
                                if (result.containsKey('type'))
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                    decoration: BoxDecoration(
                                      color: accentColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: Text(
                                      '${result['type']}',
                                      style: TextStyle(
                                        color: accentColor,
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: secondaryTextColor,
                              size: 14.0,
                            ),
                            onTap: () {
                              _selectSearchResult(result);
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            
            // Map controls in bottom right
            Positioned(
              right: 16.0,
              bottom: 16.0, 
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMapControlButton(
                    icon: Icons.add,
                    onPressed: () {
                      if (_currentZoom < _maxZoom) {
                        setState(() {
                          _currentZoom += _zoomStep;
                          _mapController.move(_currentCenter, _currentZoom);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 8.0),
                  _buildMapControlButton(
                    icon: Icons.remove,
                    onPressed: () {
                      if (_currentZoom > _minZoom) {
                        setState(() {
                          _currentZoom -= _zoomStep;
                          _mapController.move(_currentCenter, _currentZoom);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 8.0),
                  _buildMapControlButton(
                    icon: Icons.my_location,
                    onPressed: () {
                      if (_hasUserLocation) {
                        _mapController.move(_userLocation, _initialZoom);
                      } else {
                        // Try to get location again
                        _getUserLocation();
                      }
                    },
                  ),
                ],
              ),
            ),
            
            // Google Maps style bottom sheet when route is active
            if (_selectedDestination != null && _hasSearched)
              Positioned(
                left: 16.0,
                right: 16.0,
                bottom: 16.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: cardBackgroundColor,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10.0,
                        spreadRadius: 2.0,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Destination name
                        Text(
                          _selectedDestination!['name'],
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        const SizedBox(height: 8.0),
                        
                        // Type and distance row
                        Row(
                          children: [
                            // Place type badge
                            if (_selectedDestination!.containsKey('type'))
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Text(
                                  _selectedDestination!['type'].toString().toUpperCase(),
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            
                            const SizedBox(width: 8.0),
                            
                            // Distance
                            Row(
                              children: [
                                Icon(
                                  Icons.directions_car,
                                  size: 14.0,
                                  color: secondaryTextColor,
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  _selectedDestination!['formattedDistance'],
                                  style: TextStyle(
                                    color: secondaryTextColor,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(width: 16.0),
                            
                            // Estimated time
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14.0,
                                  color: secondaryTextColor,
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  _formatTime(_estimatedTimeMinutes),
                                  style: TextStyle(
                                    color: secondaryTextColor,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16.0),
                        
                        // Start navigation button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // In a real app, this would start turn-by-turn navigation
                              // For this demo, just show a brief message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Starting navigation to ${_selectedDestination!['name']}'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(Icons.navigation, size: 18.0),
                            label: const Text('Start Navigation'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 8.0),
                        
                        // Close button to dismiss the route
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedDestination = null;
                                _hasSearched = false;
                                _polylines = [];
                                
                                // Remove destination marker, keep only user location
                                _markers = _markers.where((marker) => marker.point == _userLocation).toList();
                                
                                // If no user marker, add it
                                if (_markers.isEmpty && _hasUserLocation) {
                                  _updateUserLocationMarker();
                                }
                              });
                            },
                            child: Text(
                              'Close',
                              style: TextStyle(
                                color: secondaryTextColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  // Format time in minutes to a friendly string
  String _formatTime(int minutes) {
    if (minutes < 1) {
      return 'Less than a minute';
    } else if (minutes < 60) {
      return '$minutes mins';
    } else {
      final int hours = (minutes / 60).floor();
      final int remainingMinutes = minutes % 60;
      return '$hours h ${remainingMinutes > 0 ? '$remainingMinutes min' : ''}';
    }
  }
  
  // Helper to build map control buttons
  Widget _buildMapControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.0,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20.0),
          child: Container(
            width: 40.0,
            height: 40.0,
            child: Icon(
              icon,
              color: accentColor,
              size: 20.0,
            ),
          ),
        ),
      ),
    );
  }
  
  // Helper to build user location marker widget
  Widget _buildUserLocationMarkerWidget() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Blue circle for user location with pulsing effect
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(color: accentColor, width: 2),
          ),
        ),
        // Inner dot for precise location
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: accentColor,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
  
  // Helper to build destination marker widget
  Widget _buildDestinationMarkerWidget(String label) {
    // Just show the pin without the label
    return Icon(
      Icons.location_on,
      color: accentColor,
      size: 32.0,
    );
  }
} 