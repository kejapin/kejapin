import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/models/search_result.dart';
import '../bloc/search_bloc.dart';

class AllResultsScreen extends StatelessWidget {
  final String? category;

  const AllResultsScreen({super.key, this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: category ?? 'All Results', showSearch: true),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state is SearchLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SearchLoaded) {
            final results = state.results;
            // Filter if category is provided (simple string match for now)
            final filtered = category != null 
                ? results.where((r) => _matchesCategory(r, category!)).toList()
                : results;

            if (filtered.isEmpty) {
              return const Center(child: Text("No results found."));
            }

            return ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: item.imageUrl != null ? NetworkImage(item.imageUrl!) : null,
                    child: item.imageUrl == null ? const Icon(Icons.search) : null,
                  ),
                  title: Text(item.title),
                  subtitle: Text(item.subtitle),
                  onTap: () {
                     // Handle navigation similar to overlay
                     _handleNavigation(context, item);
                  },
                );
              },
            );
          }
          return const Center(child: Text("Search for something..."));
        },
      ),
    );
  }

  bool _matchesCategory(SearchResult item, String category) {
    switch (category) {
      case 'Locations': return item.type == SearchResultType.location;
      case 'Listings': return item.type == SearchResultType.listing;
      case 'Landlords': return item.type == SearchResultType.landlord;
      default: return true;
    }
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
