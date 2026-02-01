import 'dart:math';
import 'package:latlong2/latlong.dart';
import '../../features/marketplace/domain/listing_entity.dart';

/// Represents the analyzed lifestyle value of a property coordinate.
class EfficiencyScore {
  final double totalScore; // 0.0 to 100.0
  final Map<String, double> categories; // Normalized 0.0 to 1.0
  final String efficiencyLabel;
  final double percentileComparedToMarket;

  EfficiencyScore({
    required this.totalScore,
    required this.categories,
    required this.efficiencyLabel,
    this.percentileComparedToMarket = 0.5,
  });
}

class EfficiencyService {
  static final EfficiencyService _instance = EfficiencyService._internal();
  factory EfficiencyService() => _instance;
  EfficiencyService._internal();

  /// Calculates a granular score by combining REAL DB spatial data, 
  /// Dynamic user pins, and Market context.
  EfficiencyScore calculateScore(ListingEntity listing, {Map<String, LatLng>? userPins, List<ListingEntity>? marketContext}) {
    final propertyLoc = LatLng(listing.latitude, listing.longitude);
    
    // 1. DYNAMIC: Life-Path Fit (Calculated locally based on user's current pins)
    final double lifePathFit = _calculateLifePathFit(propertyLoc, userPins);

    // 2. REAL: Infrastructure Stats (Fetched directly from Supabase/DB Spatial Engine)
    // Map keys from DB (snake_case) to UI Display keys
    final dbStats = listing.infrastructureStats;
    
    final categories = {
      'Life-Path Fit': lifePathFit,
      'Stage Radar': dbStats['stage_radar'] ?? _simulateFallback(propertyLoc, 310),
      'Network Strength': dbStats['network_strength'] ?? _simulateFallback(propertyLoc, 450),
      'Water Reliability': dbStats['water_reliability'] ?? _simulateFallback(propertyLoc, 80),
      'Power Stability': dbStats['power_stability'] ?? _simulateFallback(propertyLoc, 190),
      'Security': dbStats['security'] ?? _simulateFallback(propertyLoc, 100),
      'Retail Density': dbStats['retail_density'] ?? _simulateFallback(propertyLoc, 250),
      'Healthcare': dbStats['healthcare'] ?? _simulateFallback(propertyLoc, 150),
      'Wellness': dbStats['wellness'] ?? _simulateFallback(propertyLoc, 120),
      'Vibe Match': dbStats['vibe_match'] ?? _simulateFallback(propertyLoc, 500),
    };

    // Weighted Calculation (Nairobi Context Priority)
    double weightedTotal = 
        (categories['Life-Path Fit']! * 0.25) +  // Personal context is king
        (categories['Stage Radar']! * 0.15) +    // Matatu access
        (categories['Network Strength']! * 0.12) + // Fiber/5G
        (categories['Security']! * 0.10) +
        (categories['Water Reliability']! * 0.10) +
        (categories['Power Stability']! * 0.08) +
        (categories['Retail Density']! * 0.05) +
        (categories['Healthcare']! * 0.05) +
        (categories['Wellness']! * 0.05) +
        (categories['Vibe Match']! * 0.05);

    double finalScore = (weightedTotal * 100).clamp(0, 100);

    // 3. COMPARATIVE: Market Analysis
    double percentile = 0.5;
    if (marketContext != null && marketContext.length > 1) {
      int countLower = 0;
      int competitors = 0;
      for (final other in marketContext) {
        if (other.id == listing.id) continue;
        competitors++;
        if (finalScore >= _calculateRawTotalScore(other, userPins)) {
          countLower++;
        }
      }
      percentile = competitors > 0 ? (countLower / competitors) : 0.5;
    }

    return EfficiencyScore(
      totalScore: finalScore,
      categories: categories,
      efficiencyLabel: _getLabel(categories, finalScore, lifePathFit),
      percentileComparedToMarket: percentile,
    );
  }

  /// New method for real-time preview based on coordinates
  EfficiencyScore calculateScoreFromCoords(double lat, double lon, Map<String, LatLng>? userPins) {
    final propertyLoc = LatLng(lat, lon);
    final lifePath = _calculateLifePathFit(propertyLoc, userPins);
    
    final cats = {
      'Life-Path Fit': lifePath,
      'Stage Radar': _simulateFallback(propertyLoc, 310),
      'Network Strength': _simulateFallback(propertyLoc, 450),
      'Water Reliability': _simulateFallback(propertyLoc, 80),
      'Power Stability': _simulateFallback(propertyLoc, 190),
      'Security': _simulateFallback(propertyLoc, 100),
      'Retail Density': _simulateFallback(propertyLoc, 250),
      'Healthcare': _simulateFallback(propertyLoc, 150),
      'Wellness': _simulateFallback(propertyLoc, 120),
      'Vibe Match': _simulateFallback(propertyLoc, 500),
    };

    double weightedTotal = 
        (cats['Life-Path Fit']! * 0.25) +
        (cats['Stage Radar']! * 0.15) +
        (cats['Network Strength']! * 0.12) +
        (cats['Security']! * 0.10) +
        (cats['Water Reliability']! * 0.10) +
        (cats['Power Stability']! * 0.08) +
        (cats['Retail Density']! * 0.05) +
        (cats['Healthcare']! * 0.05) +
        (cats['Wellness']! * 0.05) +
        (cats['Vibe Match']! * 0.05);

    double finalScore = (weightedTotal * 100).clamp(0, 100);

    return EfficiencyScore(
      totalScore: finalScore,
      categories: cats,
      efficiencyLabel: _getLabel(cats, finalScore, lifePath),
    );
  }

  /// Internal helper to calculate raw score for comparison without side effects
  double _calculateRawTotalScore(ListingEntity listing, Map<String, LatLng>? userPins) {
    final propertyLoc = LatLng(listing.latitude, listing.longitude);
    final lifePath = _calculateLifePathFit(propertyLoc, userPins);
    final dbStats = listing.infrastructureStats;
    
    final cats = {
      'Life-Path Fit': lifePath,
      'Stage Radar': dbStats['stage_radar'] ?? _simulateFallback(propertyLoc, 310),
      'Network Strength': dbStats['network_strength'] ?? _simulateFallback(propertyLoc, 450),
      'Water Reliability': dbStats['water_reliability'] ?? _simulateFallback(propertyLoc, 80),
      'Power Stability': dbStats['power_stability'] ?? _simulateFallback(propertyLoc, 190),
      'Security': dbStats['security'] ?? _simulateFallback(propertyLoc, 100),
      'Retail Density': dbStats['retail_density'] ?? _simulateFallback(propertyLoc, 250),
      'Healthcare': dbStats['healthcare'] ?? _simulateFallback(propertyLoc, 150),
      'Wellness': dbStats['wellness'] ?? _simulateFallback(propertyLoc, 120),
      'Vibe Match': dbStats['vibe_match'] ?? _simulateFallback(propertyLoc, 500),
    };

    return ((cats['Life-Path Fit']! * 0.25) +
           (cats['Stage Radar']! * 0.15) +
           (cats['Network Strength']! * 0.12) +
           (cats['Security']! * 0.10) +
           (cats['Water Reliability']! * 0.10) +
           (cats['Power Stability']! * 0.08) +
           (cats['Retail Density']! * 0.05) +
           (cats['Healthcare']! * 0.05) +
           (cats['Wellness']! * 0.05) +
           (cats['Vibe Match']! * 0.05)) * 100;
  }

  double _calculateLifePathFit(LatLng propertyLoc, Map<String, LatLng>? userPins) {
    if (userPins == null || userPins.isEmpty) return 0.5;
    double totalDistance = 0;
    userPins.forEach((_, pinLoc) => totalDistance += _haversine(propertyLoc, pinLoc));
    double avgDistanceKm = totalDistance / userPins.length;
    return (1.0 - (avgDistanceKm / 20.0)).clamp(0.1, 1.0); // 20km limit
  }

  // Fallback simulation if DB data is missing (Graceful degradation)
  double _simulateFallback(LatLng loc, double seed) {
    // Add location-based jitter so nearby properties don't have identical scores
    final jitter = (sin(loc.latitude * 1000) * cos(loc.longitude * 1000)).abs() * 0.1;
    return (((sin(loc.latitude * seed) + cos(loc.longitude * seed)).abs() / 2) + jitter).clamp(0.4, 0.95);
  }

  double _haversine(LatLng p1, LatLng p2) {
    const r = 6371; 
    double dLat = (p2.latitude - p1.latitude) * pi / 180;
    double dLon = (p2.longitude - p1.longitude) * pi / 180;
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(p1.latitude * pi / 180) * cos(p2.latitude * pi / 180) *
        sin(dLon / 2) * sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  String _getLabel(Map<String, double> categories, double score, double fit) {
    if (fit > 0.85) return "Strategic Gem";
    
    // Find highest category (excluding Life-Path Fit as it's personal)
    String highestCategory = '';
    double highestScore = -1;
    
    categories.forEach((key, val) {
      if (key != 'Life-Path Fit' && val > highestScore) {
        highestScore = val;
        highestCategory = key;
      }
    });

    if (highestScore > 0.8) {
      // Mapping categories to nice adjectives
      final adjectives = {
        'Stage Radar': 'Commute',
        'Network Strength': 'Tech',
        'Water Reliability': 'Hydrated',
        'Power Stability': 'Stable',
        'Security': 'Secure',
        'Retail Density': 'Lifestyle',
        'Healthcare': 'Wellness',
        'Wellness': 'Zen',
        'Vibe Match': 'Social',
      };
      
      final adj = adjectives[highestCategory] ?? highestCategory;
      return "$adj Focused";
    }

    if (score > 85) return "Prime Tech Hub";
    if (score > 70) return "High Value";
    if (score > 50) return "Balanced Urban";
    return "Value Focused";
  }
}
