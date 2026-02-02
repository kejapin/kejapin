import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/smart_dashboard_panel.dart';
import '../../../../core/widgets/keja_state_view.dart';
import '../../../marketplace/data/listings_repository.dart';
import '../../../marketplace/domain/listing_entity.dart';

class ManageListingsScreen extends StatefulWidget {
  const ManageListingsScreen({super.key});

  @override
  State<ManageListingsScreen> createState() => _ManageListingsScreenState();
}

class _ManageListingsScreenState extends State<ManageListingsScreen> {
  final _repository = ListingsRepository();
  bool _isLoading = true;
  List<ListingEntity> _listings = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final listings = await _repository.fetchMyListings();
      setState(() {
        _listings = listings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleStatus(ListingEntity listing) async {
    try {
      await _repository.toggleListingStatus(listing.id, listing.status);
      _loadListings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Listing is now ${listing.status == 'AVAILABLE' ? 'Hidden' : 'Visible'}')),
        );
      }
    } catch (e) {
      if (mounted) context.showErrorDialog(message: e.toString());
    }
  }

  Future<void> _deleteListing(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Listing?'),
        content: const Text('This action cannot be undone. Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _repository.deleteListing(id);
        _loadListings();
      } catch (e) {
        if (mounted) context.showErrorDialog(message: e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.alabaster,
      appBar: const CustomAppBar(title: 'MANAGE LISTINGS', showSearch: false),
      body: Stack(
        children: [
          _buildBody(),
          const SmartDashboardPanel(currentRoute: '/manage-listings'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-listing'),
        backgroundColor: AppColors.structuralBrown,
        child: const Icon(Icons.add, color: AppColors.champagne),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const KejaStateView(type: KejaStateType.loading, title: "Loading Listings");
    }
    if (_error != null) {
      return KejaStateView(
        type: KejaStateType.error, 
        title: "Error", 
        message: _error, 
        onRetry: _loadListings
      );
    }
    if (_listings.isEmpty) {
      return KejaStateView(
        type: KejaStateType.empty, 
        title: "No Listings", 
        message: "You haven't posted any properties yet.",
        onRetry: _loadListings,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _listings.length,
      itemBuilder: (context, index) {
        final listing = _listings[index];
        final isAvailable = listing.status == 'AVAILABLE';

        return FadeInUp(
          delay: Duration(milliseconds: index * 50),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: GlassContainer(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              opacity: 0.8,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(listing.photos.isNotEmpty ? listing.photos.first : 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    title: Text(listing.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('KES ${listing.priceAmount.toInt()} • ${listing.propertyType}'),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isAvailable ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            listing.status, 
                            style: TextStyle(
                              fontSize: 10, 
                              fontWeight: FontWeight.bold,
                              color: isAvailable ? Colors.green : Colors.grey
                            )
                          ),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (val) {
                        if (val == 'edit') {
                          context.push('/create-listing', extra: listing);
                        } else if (val == 'delete') {
                          _deleteListing(listing.id);
                        } else if (val == 'toggle') {
                          _toggleStatus(listing);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
                        PopupMenuItem(
                          value: 'toggle', 
                          child: Row(children: [Icon(isAvailable ? Icons.visibility_off : Icons.visibility, size: 18), const SizedBox(width: 8), Text(isAvailable ? 'Deactivate' : 'Activate')])
                        ),
                        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
