import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../profile/data/life_pin_repository.dart';
import '../../../profile/domain/life_pin_model.dart';
import '../../../../core/widgets/smart_dashboard_panel.dart';
import '../../../search/data/models/search_result.dart';
import '../../../../core/widgets/animated_indicators.dart';
import 'package:client/features/messages/data/notifications_repository.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/services/map_service.dart';

class LifePinsScreen extends StatefulWidget {
  const LifePinsScreen({super.key});

  @override
  State<LifePinsScreen> createState() => _LifePinsScreenState();
}

class _LifePinsScreenState extends State<LifePinsScreen> with TickerProviderStateMixin {
  final LifePinRepository _repository = LifePinRepository();
  final NavigationService _navService = NavigationService();
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  List<LifePin> _pins = [];
  List<dynamic> _searchResults = [];
  bool _isLoading = true;
  bool _isSearching = false;
  bool _userInteracted = false;
  bool _isCardsMinimized = false;
  LatLng? _userLocation;
  LifePin? _selectedPin;
  TileProvider? _cachedTileProvider;
  int _activePageIndex = 0;
  final PageController _pageController = PageController(viewportFraction: 0.85);

  Timer? _debounce;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _loadPins();
    _initLocation();
    _initMap();
  }

  Future<void> _initMap() async {
    final tp = await MapService.getCachedTileProvider();
    if (mounted) setState(() => _cachedTileProvider = tp);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _debounce?.cancel();
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    try {
      final pos = await _navService.getCurrentLocation();
      setState(() {
        _userLocation = LatLng(pos.latitude, pos.longitude);
      });
    } catch (e) {
      print('Location error: $e');
    }
  }

  Future<void> _loadPins() async {
    setState(() => _isLoading = true);
    try {
      final pins = await _repository.getLifePins();
      if (mounted) {
        setState(() {
          _pins = pins;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading pins: $e')),
        );
      }
    }
  }

  Future<void> _onSearchChanged(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        setState(() => _searchResults = []);
        return;
      }
      setState(() => _isSearching = true);
      try {
        // NOMINATIM REQUIRES A USER-AGENT or it will return 403 Forbidden
        final response = await http.get(
          Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5&addressdetails=1'),
          headers: {'User-Agent': ApiEndpoints.osmUserAgent},
        );
        
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          setState(() {
            _searchResults = data.map((item) => {
              'name': item['display_name'].split(',')[0],
              'category': item['type'] ?? 'Place',
              'lat': double.parse(item['lat']),
              'lon': double.parse(item['lon']),
              'full_name': item['display_name'],
            }).toList();
            _isSearching = false;
          });
        }
      } catch (e) {
        setState(() => _isSearching = false);
      }
    });
  }

  void _moveToLocation(double lat, double lon, {double zoom = 15.0}) {
    _mapController.move(LatLng(lat, lon), zoom);
  }

  Future<void> _deletePin(String id) async {
    try {
      await _repository.deleteLifePin(id);
      _loadPins();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: const CustomAppBar(title: 'Life Path', showSearch: false),
      body: Stack(
        children: [
          // 1. Immersive Map Layer
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _pins.isNotEmpty 
                ? LatLng(_pins[0].latitude, _pins[0].longitude)
                : const LatLng(-1.2921, 36.8219),
              initialZoom: 13.0,
              onTap: (tapPosition, point) {
                setState(() => _userInteracted = true);
                _showAddQuickPinBottomSheet(point);
              },
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture && !_userInteracted) {
                  setState(() => _userInteracted = true);
                }
              },
            ),
            children: [
               TileLayer(
                 urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                 tileProvider: _cachedTileProvider ?? NetworkTileProvider(
                   headers: {'User-Agent': ApiEndpoints.osmUserAgent},
                 ),
               ),
              MarkerLayer(
                markers: [
                  if (_userLocation != null)
                    Marker(
                      point: _userLocation!,
                      width: 80,
                      height: 80,
                      child: LifePathPin(),
                    ),
                  ..._pins.asMap().entries.map((entry) {
                    final index = entry.key;
                    final pin = entry.value;
                    final isActive = _activePageIndex == index;
                    return Marker(
                      point: LatLng(pin.latitude, pin.longitude),
                      width: isActive ? 60 : 40,
                      height: isActive ? 60 : 40,
                      child: GestureDetector(
                        onTap: () {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                          _moveToLocation(pin.latitude, pin.longitude);
                        },
                        child: _buildPinMarker(pin, isActive),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),


          // 3. Life Pin Cards (Bottom)
          if (_pins.isNotEmpty)
            Positioned(
              bottom: 110,
              left: 0,
              right: 0,
              height: _isCardsMinimized ? 30 : 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _isCardsMinimized = !_isCardsMinimized),
                    child: Container(
                      width: 80,
                      height: 24,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppColors.structuralBrown.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.champagne.withOpacity(0.3)),
                      ),
                      child: Icon(
                         _isCardsMinimized ? Icons.expand_less : Icons.expand_more, 
                         color: AppColors.champagne, size: 20
                      ),
                    ),
                  ),
                  if (!_isCardsMinimized)
                    SizedBox(
                      height: 168,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _pins.length,
                        onPageChanged: (index) {
                          setState(() => _activePageIndex = index);
                          _moveToLocation(_pins[index].latitude, _pins[index].longitude);
                        },
                        itemBuilder: (context, index) {
                          return _buildLifePinCard(_pins[index]);
                        },
                      ),
                    ),
                ],
              ),
            ),
          
          if (_pins.isEmpty && !_isLoading && _searchController.text.isEmpty && !_userInteracted)
             _buildEmptyState(),
             
          // 2. Floating Search Overlay (Moved to end for Z-Index)
          Positioned(
            top: kToolbarHeight + 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                _buildSearchBar(),
                if (_searchResults.isNotEmpty) _buildSearchResultsList(),
              ],
            ),
          ),
          const SmartDashboardPanel(currentRoute: '/life-pins'),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: 'add_pin',
              onPressed: () => _showAddQuickPinBottomSheet(_userLocation ?? const LatLng(-1.2921, 36.8219)),
              backgroundColor: AppColors.structuralBrown,
              child: const Icon(Icons.add_location_alt, color: AppColors.champagne),
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              heroTag: 'my_location',
              onPressed: () async {
                try {
                  final pos = await _navService.getCurrentLocation();
                  setState(() => _userLocation = LatLng(pos.latitude, pos.longitude));
                  _moveToLocation(pos.latitude, pos.longitude);
                } catch (e) {
                  // If permissions are permanently denied, open settings
                  if (e.toString().contains('permanently denied')) {
                     Geolocator.openAppSettings();
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Location error: $e')),
                  );
                }
              },
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: AppColors.structuralBrown),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPulseMarker(Color color) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.2 * (1 - _pulseController.value)),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withOpacity(0.5 * (1 - _pulseController.value)),
              width: 4 * _pulseController.value,
            ),
          ),
          child: Center(
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.8),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPinMarker(LifePin pin, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(isActive ? 8 : 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.champagne : AppColors.structuralBrown.withOpacity(0.8),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(
        _getIconForMode(pin.transportMode),
        color: isActive ? AppColors.structuralBrown : AppColors.champagne,
        size: isActive ? 30 : 20,
      ),
    );
  }

  Widget _buildSearchBar() {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 60,
      borderRadius: 30,
      blur: 20,
      alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(
        colors: [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.8)],
      ),
      borderGradient: LinearGradient(
        colors: [AppColors.structuralBrown.withOpacity(0.5), AppColors.structuralBrown.withOpacity(0.1)],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: const TextStyle(color: AppColors.structuralBrown),
        decoration: InputDecoration(
          hintText: 'Search for a place...',
          hintStyle: TextStyle(color: AppColors.structuralBrown.withOpacity(0.5)),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search, color: AppColors.structuralBrown),
          suffixIcon: _isSearching 
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.structuralBrown),
              )
            : _searchController.text.isNotEmpty 
                ? IconButton(
                    icon: const Icon(Icons.close, color: AppColors.structuralBrown),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchResults = []);
                    },
                  )
                : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildSearchResultsList() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      height: 250,
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 250,
        borderRadius: 20,
        blur: 20,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          colors: [Colors.black.withOpacity(0.8), Colors.black.withOpacity(0.6)],
        ),
        borderGradient: LinearGradient(
          colors: [AppColors.champagne.withOpacity(0.3), Colors.transparent],
        ),
        child: ListView.builder(
          itemCount: _searchResults.length,
          itemBuilder: (context, index) {
            final result = _searchResults[index];
            return ListTile(
              leading: const Icon(Icons.location_on, color: AppColors.champagne),
              title: Text(result['name'] ?? 'Unknown', style: const TextStyle(color: Colors.white)),
              subtitle: Text(result['category'] ?? '', style: TextStyle(color: Colors.white.withOpacity(0.5))),
              onTap: () {
                final lat = result['lat'] as double;
                final lon = result['lon'] as double;
                _moveToLocation(lat, lon);
                setState(() => _searchResults = []);
                _searchController.text = result['name'] ?? '';
                _showAddQuickPinBottomSheet(LatLng(lat, lon), label: result['name']);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildLifePinCard(LifePin pin) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 160,
        borderRadius: 24,
        blur: 15,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          colors: [AppColors.structuralBrown.withOpacity(0.9), AppColors.structuralBrown.withOpacity(0.8)],
        ),
        borderGradient: LinearGradient(
          colors: [AppColors.champagne.withOpacity(0.3), Colors.transparent],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pin.label,
                          style: const TextStyle(color: AppColors.champagne, fontSize: 20, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          pin.transportMode,
                          style: TextStyle(color: AppColors.champagne.withOpacity(0.6), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _deletePin(pin.id),
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  _buildActionChip(
                    icon: Icons.navigation_rounded,
                    label: 'Navigate',
                    onTap: () {
                      context.push('/map', extra: SearchResult(
                        id: pin.id,
                        title: pin.label,
                        subtitle: 'Saved Life Pin',
                        type: SearchResultType.location,
                        metadata: {'lat': pin.latitude, 'lon': pin.longitude},
                      ));
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionChip({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.champagne.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.champagne.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.champagne, size: 16),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: AppColors.champagne, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
     return Center(
       child: GlassmorphicContainer(
         width: 280,
         height: 300,
         borderRadius: 30,
         blur: 20,
         alignment: Alignment.center,
         border: 2,
         linearGradient: LinearGradient(
           colors: [AppColors.structuralBrown.withOpacity(0.95), AppColors.structuralBrown.withOpacity(0.9)],
         ),
         borderGradient: LinearGradient(colors: [AppColors.champagne, Colors.transparent]),
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             const Icon(Icons.add_location_alt_rounded, size: 80, color: AppColors.champagne),
             const SizedBox(height: 20),
             const Text('No Life Paths set', style: TextStyle(color: AppColors.champagne, fontSize: 20, fontWeight: FontWeight.bold)),
             const SizedBox(height: 10),
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 20),
               child: Text(
                 'Tap the map to pin a place you frequent, or use the search bar.',
                 textAlign: TextAlign.center,
                 style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
               ),
             ),
           ],
         ),
       ),
     );
  }

  void _showAddQuickPinBottomSheet(LatLng point, {String? label}) {
     showModalBottomSheet(
       context: context,
       backgroundColor: Colors.transparent,
       isScrollControlled: true,
       builder: (context) => _QuickAddPinPanel(
         point: point,
         initialLabel: label,
         onSave: (pin) async {
            try {
              await _repository.createLifePin(pin);
              _loadPins();
              NotificationsRepository().createNotification(
                title: 'Life Path Expanded! ⚡',
                message: 'New pin "${pin.label}" added. Your efficiency scores are being recalibrated.',
                type: 'EFFICIENCY',
                route: '/life-pins',
              );
              if (mounted) Navigator.pop(context);
            } catch (e) {
               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
            }
         },
       ),
     );
  }

  String _formatCoord(double coord) => coord.toStringAsFixed(4);

  IconData _getIconForMode(String mode) {
    switch (mode) {
      case 'DRIVE': return Icons.directions_car;
      case 'WALK': return Icons.directions_walk;
      case 'CYCLE': return Icons.directions_bike;
      case 'PUBLIC_TRANSPORT': return Icons.directions_bus;
      default: return Icons.location_on;
    }
  }
  
  Color _getColorForMode(String mode) {
    switch (mode) {
      case 'DRIVE': return Colors.blueAccent;
      case 'WALK': return Colors.green;
      case 'CYCLE': return Colors.orange;
      case 'PUBLIC_TRANSPORT': return Colors.purple;
      default: return AppColors.structuralBrown;
    }
  }
}

class _QuickAddPinPanel extends StatefulWidget {
  final LatLng point;
  final String? initialLabel;
  final Function(LifePin) onSave;

  const _QuickAddPinPanel({required this.point, this.initialLabel, required this.onSave});

  @override
  State<_QuickAddPinPanel> createState() => _QuickAddPinPanelState();
}

class _QuickAddPinPanelState extends State<_QuickAddPinPanel> {
  final _labelController = TextEditingController();
  String _transportMode = 'DRIVE';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _labelController.text = widget.initialLabel ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 480, // Increased height to show location info
        borderRadius: 40,
        blur: 30,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.structuralBrown.withOpacity(0.98), Colors.black.withOpacity(0.95)],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.champagne.withOpacity(0.5), Colors.transparent],
        ),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add Life Path',
                    style: TextStyle(color: AppColors.champagne, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.champagne),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.champagne.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_pin, color: AppColors.champagne, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Location: ${widget.point.latitude.toStringAsFixed(6)}, ${widget.point.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _labelController,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                cursorColor: AppColors.champagne,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Label (e.g. Office, Gym)',
                  labelStyle: const TextStyle(color: AppColors.champagne, fontSize: 14),
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  hintText: 'Enter a name for this place',
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.3),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.champagne),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const Text('Commute Mode', style: TextStyle(color: AppColors.champagne, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['DRIVE', 'WALK', 'CYCLE', 'PUBLIC_TRANSPORT'].map((mode) {
                    final selected = _transportMode == mode;
                    return GestureDetector(
                      onTap: () => setState(() => _transportMode = mode),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.champagne : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: selected ? AppColors.champagne : Colors.white.withOpacity(0.2)),
                        ),
                        child: Text(
                          mode,
                          style: TextStyle(
                            color: selected ? AppColors.structuralBrown : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : () async {
                    if (_labelController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a label')));
                      return;
                    }
                    setState(() => _isSaving = true);
                    widget.onSave(LifePin(
                      id: '',
                      label: _labelController.text,
                      latitude: widget.point.latitude,
                      longitude: widget.point.longitude,
                      transportMode: _transportMode,
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.champagne,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isSaving 
                    ? const CircularProgressIndicator(color: AppColors.structuralBrown)
                    : const Text('Save Life Path', style: TextStyle(color: AppColors.structuralBrown, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
