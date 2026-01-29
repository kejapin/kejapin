import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../data/listings_repository.dart';
import '../blocs/listing_feed_cubit.dart';
import '../widgets/listing_card.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import 'marketplace_map.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/widgets/web_layout_wrapper.dart';
import '../widgets/animated_marketplace_hero.dart';
import '../widgets/advanced_filters_sheet.dart';
import 'dart:async';
import '../../../search/presentation/widgets/marketplace_search_bar.dart';

class MarketplaceFeed extends StatefulWidget {
  final String? initialSearchQuery;
  final String? initialPropertyType;

  const MarketplaceFeed({
    super.key,
    this.initialSearchQuery,
    this.initialPropertyType,
  });

  @override
  State<MarketplaceFeed> createState() => _MarketplaceFeedState();
}

class _MarketplaceFeedState extends State<MarketplaceFeed> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isMapView = false;
  late String _selectedCategory;
  Map<String, dynamic> _activeFilters = {};
  late ListingFeedCubit _cubit;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialPropertyType ?? 'All';
    _cubit = ListingFeedCubit(ListingsRepository())
      ..loadListings(
        searchQuery: widget.initialSearchQuery,
        propertyType: _selectedCategory == 'All' ? null : _selectedCategory,
      );
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => AdvancedFiltersSheet(
          currentFilters: _activeFilters,
          onApplyFilters: (filters) {
            setState(() {
              _activeFilters = filters;
            });
            _cubit.loadListings(
              propertyType: _selectedCategory == 'All' ? null : _selectedCategory,
              filters: filters,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.alabaster,
        drawer: const AppDrawer(),
        drawerScrimColor: Colors.transparent,
        appBar: CustomAppBar(
          onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        body: _isMapView
            ? BlocBuilder<ListingFeedCubit, ListingFeedState>(
                builder: (context, state) {
                  if (state is ListingFeedLoaded) {
                    return MarketplaceMap(listings: state.listings);
                  }
                  return const MarketplaceMap(listings: []);
                },
              )
            : RefreshIndicator(
                onRefresh: () async {
                  await context.read<ListingFeedCubit>().loadListings(
                        propertyType: _selectedCategory == 'All' ? null : _selectedCategory,
                        isRefresh: true,
                      );
                },
                color: AppColors.structuralBrown,
                child: CustomScrollView(
                  slivers: [
                    const SliverToBoxAdapter(
                      child: AnimatedMarketplaceHero(),
                    ),
                    SliverToBoxAdapter(
                      child: GlassContainer(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                        blur: 20,
                        opacity: 0.6,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: MarketplaceSearchBar(
                                          isMapView: _isMapView,
                                          onToggleView: (isMap) {
                                            setState(() => _isMapView = isMap);
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: _showAdvancedFilters,
                                        child: Container(
                                          height: 56,
                                          width: 56,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                AppColors.mutedGold,
                                                AppColors.mutedGold.withOpacity(0.8),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.mutedGold.withOpacity(0.3),
                                                blurRadius: 8,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              const Icon(Icons.tune, color: Colors.white, size: 24),
                                              if (_activeFilters.isNotEmpty)
                                                Positioned(
                                                  right: 12,
                                                  top: 12,
                                                  child: Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: const BoxDecoration(
                                                      color: Colors.red,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (widget.initialSearchQuery != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Results for "${widget.initialSearchQuery}"',
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: AppColors.structuralBrown,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () => context.go('/marketplace'),
                                            child: const Icon(Icons.cancel, size: 16, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 50,
                              margin: const EdgeInsets.only(bottom: 16),
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                children: [
                                  'All',
                                  'BEDSITTER',
                                  '1BHK',
                                  '2BHK',
                                  'SQ',
                                  'BUNGALOW'
                                ].map((category) {
                                  return _CategoryChip(
                                    label: category,
                                    isSelected: _selectedCategory == category,
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() => _selectedCategory = category);
                                        context.read<ListingFeedCubit>().loadListings(
                                              propertyType: category == 'All' ? null : category,
                                            );
                                      }
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    BlocBuilder<ListingFeedCubit, ListingFeedState>(
                      builder: (context, state) {
                        if (state is ListingFeedLoading) {
                          return const SliverFillRemaining(
                            child: Center(child: CircularProgressIndicator()),
                          );
                        } else if (state is ListingFeedError) {
                          return SliverFillRemaining(
                            child: Center(child: Text('Error: ${state.message}')),
                          );
                        } else if (state is ListingFeedLoaded) {
                          if (state.listings.isEmpty) {
                            return const SliverFillRemaining(
                              child: Center(child: Text('No listings found.')),
                            );
                          }
                          return SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                            sliver: SliverGrid(
                              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 400,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final listing = state.listings[index];
                                  return ListingCard(listing: listing);
                                },
                                childCount: state.listings.length,
                              ),
                            ),
                          );
                        }
                        return const SliverToBoxAdapter(child: SizedBox.shrink());
                      },
                    ),
                    if (kIsWeb)
                      const SliverToBoxAdapter(
                        child: WebFooter(),
                      ),
                  ],
                ),
              ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: kIsWeb ? 30 : 90),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isMapView = !_isMapView;
              });
            },
            child: GlassContainer(
              borderRadius: BorderRadius.circular(30),
              blur: 10,
              opacity: 0.85,
              color: AppColors.structuralBrown,
              borderColor: Colors.white.withOpacity(0.2),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_isMapView ? Icons.list : Icons.map_outlined, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    _isMapView ? "List View" : "Map View",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const _CategoryChip({
    required this.label,
    this.isSelected = false,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelected(!isSelected),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        child: GlassContainer(
          borderRadius: BorderRadius.circular(20),
          blur: 10,
          opacity: isSelected ? 0.9 : 0.3,
          color: isSelected ? AppColors.structuralBrown : Colors.white,
          borderColor: isSelected ? Colors.transparent : Colors.white.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.structuralBrown,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
