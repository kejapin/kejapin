import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/widgets/glass_container.dart';

import '../../data/models/search_result.dart';
import '../bloc/search_bloc.dart';

class SearchResultsOverlay extends StatelessWidget {
  final VoidCallback onClose;
  final double width;

  const SearchResultsOverlay({
    super.key,
    required this.onClose,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: GlassContainer(
        borderRadius: BorderRadius.circular(16),
        blur: 20,
        opacity: 0.9,
        constraints: const BoxConstraints(maxHeight: 500),
        child: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            if (state is SearchLoading) {
              return const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (state is SearchError) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(child: Text(state.message)),
              );
            }

            if (state is SearchLoaded) {
              if (state.results.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: Text("No results found")),
                );
              }

              final grouped = state.groupedResults;

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (grouped.containsKey(SearchResultType.location))
                            _buildSection(context, "Locations", grouped[SearchResultType.location]!),
                          
                          if (grouped.containsKey(SearchResultType.listing))
                            _buildSection(context, "Listings", grouped[SearchResultType.listing]!),
                          
                          if (grouped.containsKey(SearchResultType.landlord))
                            _buildSection(context, "Landlords", grouped[SearchResultType.landlord]!),
                
                          const Divider(),
                          ListTile(
                            title: const Text("View All Results", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                            trailing: const Icon(Icons.arrow_forward, color: Colors.blue),
                            onTap: () {
                              // Navigate to All Results Screen
                              context.push('/search-results');
                              onClose();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<SearchResult> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  // Navigate to category specific view
                   context.push('/search-results?category=$title');
                   onClose();
                },
                child: const Text("View All"),
              ),
            ],
          ),
        ),
        ...items.take(3).map((item) => FadeInUp(
          duration: const Duration(milliseconds: 300),
          child: _buildResultTile(context, item),
        )),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildResultTile(BuildContext context, SearchResult item) {
    IconData icon;
    switch (item.type) {
      case SearchResultType.location:
        icon = Icons.location_on;
        break;
      case SearchResultType.landlord:
        icon = Icons.person;
        break;
      case SearchResultType.listing:
        icon = Icons.home;
        break;
      default:
        icon = Icons.search;
    }

    return ListTile(
      leading: item.imageUrl != null
          ? CircleAvatar(backgroundImage: NetworkImage(item.imageUrl!))
          : CircleAvatar(child: Icon(icon)),
      title: Text(item.title),
      subtitle: Text(item.subtitle),
      onTap: () {
        onClose();
        _handleNavigation(context, item);
      },
    );
  }

  void _handleNavigation(BuildContext context, SearchResult item) {
    switch (item.type) {
      case SearchResultType.location:
      case SearchResultType.coordinate:
        context.push('/map', extra: item);
        break;
      case SearchResultType.listing:
        context.push('/listings/${item.id}', extra: item);
        break;
      case SearchResultType.landlord:
        context.push('/landlords/${item.id}', extra: item);
        break;
    }
  }
}
