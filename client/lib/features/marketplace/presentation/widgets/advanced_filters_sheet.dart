import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import 'package:google_fonts/google_fonts.dart';

class AdvancedFiltersSheet extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const AdvancedFiltersSheet({
    super.key,
    required this.currentFilters,
    required this.onApplyFilters,
  });

  @override
  State<AdvancedFiltersSheet> createState() => _AdvancedFiltersSheetState();
}

class _AdvancedFiltersSheetState extends State<AdvancedFiltersSheet> {
  late Map<String, dynamic> _filters;
  
  // Price range
  RangeValues _priceRange = const RangeValues(1000, 50000);
  
  // Property types
  final List<String> _propertyTypes = ['BEDSITTER', '1BHK', '2BHK', 'SQ', 'BUNGALOW'];
  Set<String> _selectedPropertyTypes = {};
  
  // Amenities
  final List<String> _amenities = [
    'WiFi',
    'Parking',
    'Security',
    'Water 24/7',
    'Generator',
    'Gym',
    'Swimming Pool',
    'Garden',
  ];
  Set<String> _selectedAmenities = {};
  
  // Furnishing
  String? _furnishing;
  final List<String> _furnishingOptions = ['Furnished', 'Semi-Furnished', 'Unfurnished'];
  
  // Availability
  bool _availableNow = false;

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
    _loadFilters();
  }

  void _loadFilters() {
    if (_filters['minPrice'] != null && _filters['maxPrice'] != null) {
      _priceRange = RangeValues(
        (_filters['minPrice'] as num).toDouble(),
        (_filters['maxPrice'] as num).toDouble(),
      );
    }
    if (_filters['propertyTypes'] != null) {
      _selectedPropertyTypes = Set<String>.from(_filters['propertyTypes']);
    }
    if (_filters['amenities'] != null) {
      _selectedAmenities = Set<String>.from(_filters['amenities']);
    }
    _furnishing = _filters['furnishing'];
    _availableNow = _filters['availableNow'] ?? false;
  }

  void _applyFilters() {
    final filters = {
      'minPrice': _priceRange.start.round(),
      'maxPrice': _priceRange.end.round(),
      'propertyTypes': _selectedPropertyTypes.toList(),
      'amenities': _selectedAmenities.toList(),
      'furnishing': _furnishing,
      'availableNow': _availableNow,
    };
    widget.onApplyFilters(filters);
    Navigator.pop(context);
  }

  void _resetFilters() {
    setState(() {
      _priceRange = const RangeValues(1000, 50000);
      _selectedPropertyTypes.clear();
      _selectedAmenities.clear();
      _furnishing = null;
      _availableNow = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb || MediaQuery.of(context).size.width > 600;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.alabaster,
            AppColors.alabaster.withOpacity(0.95),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GlassContainer(
                    borderRadius: BorderRadius.circular(12),
                    blur: 10,
                    opacity: 0.2,
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.tune,
                      color: AppColors.structuralBrown,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Advanced Filters',
                          style: GoogleFonts.montserrat(
                            fontSize: isWeb ? 24 : 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.structuralBrown,
                          ),
                        ),
                        Text(
                          'Refine your search',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.structuralBrown.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: AppColors.structuralBrown,
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Price Range'),
                    _buildPriceRangeSlider(),
                    const SizedBox(height: 24),
                    
                    _buildSectionTitle('Property Type'),
                    _buildPropertyTypeChips(),
                    const SizedBox(height: 24),
                    
                    _buildSectionTitle('Amenities'),
                    _buildAmenitiesGrid(),
                    const SizedBox(height: 24),
                    
                    _buildSectionTitle('Furnishing'),
                    _buildFurnishingOptions(),
                    const SizedBox(height: 24),
                    
                    _buildAvailabilityToggle(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            
            // Bottom action buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 30,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _resetFilters,
                      child: GlassContainer(
                        borderRadius: BorderRadius.circular(16),
                        blur: 10,
                        opacity: 0.1,
                        color: AppColors.structuralBrown,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            'Reset',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.structuralBrown,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _applyFilters,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.structuralBrown,
                              AppColors.structuralBrown.withOpacity(0.85),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.structuralBrown.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Apply Filters',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.structuralBrown,
        ),
      ),
    );
  }

  Widget _buildPriceRangeSlider() {
    return GlassContainer(
      borderRadius: BorderRadius.circular(16),
      blur: 10,
      opacity: 0.6,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'KSh ${_priceRange.start.round().toString()}',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.structuralBrown,
                ),
              ),
              Text(
                'KSh ${_priceRange.end.round().toString()}',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.structuralBrown,
                ),
              ),
            ],
          ),
          RangeSlider(
            values: _priceRange,
            min: 1000,
            max: 100000,
            divisions: 99,
            activeColor: AppColors.mutedGold,
            inactiveColor: AppColors.mutedGold.withOpacity(0.2),
            onChanged: (values) {
              setState(() {
                _priceRange = values;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyTypeChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _propertyTypes.map((type) {
        final isSelected = _selectedPropertyTypes.contains(type);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedPropertyTypes.remove(type);
              } else {
                _selectedPropertyTypes.add(type);
              }
            });
          },
          child: GlassContainer(
            borderRadius: BorderRadius.circular(12),
            blur: 10,
            opacity: isSelected ? 0.9 : 0.3,
            color: isSelected ? AppColors.structuralBrown : Colors.white,
            borderColor: isSelected 
                ? AppColors.mutedGold.withOpacity(0.5)
                : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              type,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.structuralBrown,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAmenitiesGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _amenities.map((amenity) {
        final isSelected = _selectedAmenities.contains(amenity);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedAmenities.remove(amenity);
              } else {
                _selectedAmenities.add(amenity);
              }
            });
          },
          child: GlassContainer(
            borderRadius: BorderRadius.circular(12),
            blur: 10,
            opacity: isSelected ? 0.9 : 0.3,
            color: isSelected ? AppColors.mutedGold : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  size: 18,
                  color: isSelected ? Colors.white : AppColors.structuralBrown.withOpacity(0.5),
                ),
                const SizedBox(width: 8),
                Text(
                  amenity,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.structuralBrown,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFurnishingOptions() {
    return Row(
      children: _furnishingOptions.map((option) {
        final isSelected = _furnishing == option;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _furnishing = isSelected ? null : option;
                });
              },
              child: GlassContainer(
                borderRadius: BorderRadius.circular(12),
                blur: 10,
                opacity: isSelected ? 0.9 : 0.3,
                color: isSelected ? AppColors.structuralBrown : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    option,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.structuralBrown,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAvailabilityToggle() {
    return GlassContainer(
      borderRadius: BorderRadius.circular(16),
      blur: 10,
      opacity: 0.6,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.event_available,
            color: AppColors.structuralBrown,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Now',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.structuralBrown,
                  ),
                ),
                Text(
                  'Show only immediately available properties',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.structuralBrown.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _availableNow,
            onChanged: (value) {
              setState(() {
                _availableNow = value;
              });
            },
            activeColor: AppColors.mutedGold,
            activeTrackColor: AppColors.mutedGold.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}
