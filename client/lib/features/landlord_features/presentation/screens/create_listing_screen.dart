import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:geolocator/geolocator.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/smart_dashboard_panel.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/keja_state_view.dart';
import '../../../../core/services/efficiency_service.dart';
import '../../../../core/globals.dart';
import '../../../marketplace/data/listings_repository.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _repository = ListingsRepository();
  final _efficiencyService = EfficiencyService();
  final _mapController = MapController();
  
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Form Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _searchLocationController = TextEditingController();
  
  // Data
  String _propertyType = '1BHK';
  String _listingType = 'RENT';
  int _bedrooms = 1;
  int _bathrooms = 1;
  LatLng _selectedLocation = const LatLng(-1.286389, 36.817223); // Default Nairobi
  String _locationName = 'Nairobi, Kenya';
  String _city = 'Nairobi';
  String _county = 'Nairobi';
  List<String> _selectedAmenities = [];

  // Map & Search state
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;
  bool _mapTapped = false;

  final List<String> _amenityOptions = [
    'WiFi', 'Parking', 'Gym', 'Pool', 'Security', 'Borehole', 'Lift', 'Balcony'
  ];

  final List<String> _propertyTypes = [
    'BEDSITTER', '1BHK', '2BHK', 'SQ', 'BUNGALOW'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _searchLocationController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _onSearchChanged(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.length < 3) {
        setState(() => _searchResults = []);
        return;
      }
      setState(() => _isSearching = true);
      try {
        final response = await http.get(
          Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5&addressdetails=1'),
          headers: {'User-Agent': 'Kejapin_App_v1'},
        );
        if (response.statusCode == 200) {
          setState(() {
            _searchResults = jsonDecode(response.body);
            _isSearching = false;
          });
        }
      } catch (e) {
        setState(() => _isSearching = false);
      }
    });
  }

  Future<void> _reverseGeocode(LatLng point) async {
    try {
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=${point.latitude}&lon=${point.longitude}&format=json&addressdetails=1'),
        headers: {'User-Agent': 'Kejapin_App_v1'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['address'] ?? {};
        setState(() {
          _selectedLocation = point;
          _locationName = data['display_name'] ?? 'Custom Location';
          _city = address['city'] ?? address['town'] ?? address['village'] ?? address['suburb'] ?? 'Nairobi';
          _county = address['county'] ?? address['state'] ?? 'Nairobi';
          _mapTapped = true;
          _searchResults = [];
        });
        _mapController.move(point, 16);
      }
    } catch (e) {
      setState(() {
        _selectedLocation = point;
        _mapTapped = true;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      _reverseGeocode(LatLng(position.latitude, position.longitude));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not get location: $e')));
    }
  }

  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      if (_titleController.text.trim().isEmpty) return _showError('Please enter a title');
      if (_descriptionController.text.trim().isEmpty) return _showError('Please enter a description');
      if (_priceController.text.isEmpty) return _showError('Please enter a price');
    }
    if (_currentStep == 2 && !_mapTapped) {
      return _showError('Please pin the property location on the map');
    }
    return true;
  }

  bool _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
    return false;
  }

  Future<void> _submitListing() async {
    setState(() => _isSubmitting = true);
    final efficiency = _efficiencyService.calculateScoreFromCoords(_selectedLocation.latitude, _selectedLocation.longitude, {});
    
    try {
      await _repository.createListing({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'price_amount': double.tryParse(_priceController.text) ?? 0,
        'property_type': _propertyType,
        'listing_type': _listingType,
        'bedrooms': _bedrooms,
        'bathrooms': _bathrooms,
        'latitude': _selectedLocation.latitude,
        'longitude': _selectedLocation.longitude,
        'city': _city,
        'county': _county,
        'address_line_1': _locationName.split(',')[0],
        'amenities': _selectedAmenities.join(','),
        'photos': 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800', // Placeholder
        'status': 'AVAILABLE',
        'efficiency_stats': jsonEncode(efficiency.categories),
      });
      if (mounted) {
        context.go('/landlord-dashboard');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Property pinned successfully! 🚀')));
      }
    } catch (e) {
      if (mounted) {
        context.showErrorDialog(
          message: e.toString(),
          onRetry: _submitListing,
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.alabaster,
      drawer: const AppDrawer(),
      appBar: CustomAppBar(
        title: 'POST PROPERTY', 
        showSearch: false,
        onMenuPressed: () => rootScaffoldKey.currentState?.openDrawer(),
      ),
      body: Stack(
        children: [
          Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: AppColors.structuralBrown),
            ),
            child: Stepper(
              type: StepperType.horizontal,
              currentStep: _currentStep,
              onStepTapped: (index) {
                if (index < _currentStep) setState(() => _currentStep = index);
              },
              onStepContinue: () {
                if (_validateCurrentStep()) {
                  if (_currentStep < 3) {
                    setState(() => _currentStep++);
                  } else {
                    _submitListing();
                  }
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) setState(() => _currentStep--);
              },
              controlsBuilder: (context, controls) {
                return Padding(
                  padding: const EdgeInsets.only(top: 32, bottom: 80),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : controls.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.structuralBrown,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _isSubmitting 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(
                                _currentStep == 3 ? 'PUBLISH NOW' : 'CONTINUE', 
                                style: GoogleFonts.workSans(fontWeight: FontWeight.bold, letterSpacing: 1),
                              ),
                        ),
                      ),
                      if (_currentStep > 0) ...[
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: controls.onStepCancel,
                          icon: const Icon(Icons.arrow_back),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
              steps: [
                _buildBasicInfoStep(),
                _buildSpecsStep(),
                _buildLocationStep(),
                _buildPulsePreviewStep(),
              ],
            ),
          ),
          const SmartDashboardPanel(currentRoute: '/create-listing'),
        ],
      ),
    );
  }

  Step _buildBasicInfoStep() {
    return Step(
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      title: const Text('INFO'),
      content: FadeInUp(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(_titleController, 'Title', 'e.g. Elegant 1BHK in Kilimani', Icons.title),
              const SizedBox(height: 16),
              _buildTextField(_descriptionController, 'Detailed Description', 'Mention key highlights...', Icons.description, maxLines: 4),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField(_priceController, 'Price (KES)', '0', Icons.payments, keyboardType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _listingType,
                        items: ['RENT', 'SALE'].map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
                        onChanged: (v) => setState(() => _listingType = v!),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildPropertyTypeSelector(),
            ],
          ),
        ),
      ),
    );
  }

  Step _buildSpecsStep() {
    return Step(
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      title: const Text('SPECS'),
      content: FadeInUp(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PROPERTY SIZE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 12)),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildCounter('Bedrooms', _bedrooms, (v) => setState(() => _bedrooms = v), Icons.bed),
                const SizedBox(width: 24),
                _buildCounter('Bathrooms', _bathrooms, (v) => setState(() => _bathrooms = v), Icons.bathtub),
              ],
            ),
            const SizedBox(height: 32),
            const Text('AMENITIES', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 12)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _amenityOptions.map((amenity) {
                final selected = _selectedAmenities.contains(amenity);
                return FilterChip(
                  label: Text(amenity),
                  selected: selected,
                  selectedColor: AppColors.mutedGold.withOpacity(0.2),
                  checkmarkColor: AppColors.structuralBrown,
                  labelStyle: TextStyle(
                    color: selected ? AppColors.structuralBrown : Colors.black54,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (v) {
                    setState(() {
                      if (v) _selectedAmenities.add(amenity);
                      else _selectedAmenities.remove(amenity);
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Step _buildLocationStep() {
    return Step(
      isActive: _currentStep >= 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      title: const Text('MAP'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PIN PRECISE LOCATION', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 12)),
          const SizedBox(height: 16),
          // Search & Locate Row
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: TextField(
                    controller: _searchLocationController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search city or area...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.structuralBrown),
                      suffixIcon: _isSearching ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))) : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.my_location, color: AppColors.structuralBrown),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.all(14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          
          if (_searchResults.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(12), 
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final res = _searchResults[index];
                  return ListTile(
                    leading: const Icon(Icons.location_on_outlined, size: 18),
                    title: Text(res['display_name'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                    onTap: () {
                      final lat = double.parse(res['lat']);
                      final lon = double.parse(res['lon']);
                      _reverseGeocode(LatLng(lat, lon));
                    },
                  );
                },
              ),
            ),
            
          const SizedBox(height: 16),
          
          Container(
            height: 350,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _selectedLocation,
                  initialZoom: 13.0,
                  onTap: (tapPos, point) => _reverseGeocode(point),
                ),
                children: [
                  TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedLocation,
                        width: 60,
                        height: 60,
                        child: BounceInDown(
                          child: const Icon(Icons.location_on, color: Colors.red, size: 45),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_mapTapped)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.structuralBrown.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _locationName,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            )
          else
            const Center(child: Text('👇 Tap map to pin property', style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic))),
        ],
      ),
    );
  }

  Step _buildPulsePreviewStep() {
    final efficiency = _efficiencyService.calculateScoreFromCoords(_selectedLocation.latitude, _selectedLocation.longitude, {});
    return Step(
      isActive: _currentStep >= 3,
      title: const Text('PULSE'),
      content: FadeInUp(
        child: Column(
          children: [
            const Text('MARKET PULSE GENERATED', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 12)),
            const SizedBox(height: 20),
            GlassContainer(
              padding: const EdgeInsets.all(32),
              borderRadius: BorderRadius.circular(30),
              color: AppColors.structuralBrown,
              opacity: 0.05,
              child: Column(
                children: [
                  Text(
                    efficiency.efficiencyLabel.toUpperCase(), 
                    style: GoogleFonts.workSans(fontWeight: FontWeight.w900, color: AppColors.mutedGold, fontSize: 24),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: efficiency.categories.values.map((v) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 10,
                        height: 20 + (v * 80),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [AppColors.structuralBrown, AppColors.mutedGold.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Publishing will make this visible to all tenants in your area.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, IconData icon, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.structuralBrown.withOpacity(0.5), size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade100)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade100)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.structuralBrown)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPropertyTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PROPERTY CATEGORY', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 12)),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _propertyTypes.map((type) {
              final selected = _propertyType == type;
              return GestureDetector(
                onTap: () => setState(() => _propertyType = type),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.structuralBrown : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: selected ? Colors.transparent : Colors.grey.shade200),
                    boxShadow: selected ? [BoxShadow(color: AppColors.structuralBrown.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : null,
                  ),
                  child: Text(
                    type, 
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.black87, 
                      fontSize: 12, 
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal
                    )
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCounter(String label, int value, Function(int) onChanged, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.structuralBrown.withOpacity(0.4), size: 24),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade100)),
          child: Row(
            children: [
              IconButton(onPressed: value > 0 ? () => onChanged(value - 1) : null, icon: const Icon(Icons.remove, size: 18)),
              Text('$value', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => onChanged(value + 1), icon: const Icon(Icons.add, size: 18)),
            ],
          ),
        ),
      ],
    );
  }
}
