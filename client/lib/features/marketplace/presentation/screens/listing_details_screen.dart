import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../search/data/models/search_result.dart';

class ListingDetailsScreen extends StatelessWidget {
  final String id;
  final SearchResult? extra;

  const ListingDetailsScreen({super.key, required this.id, this.extra});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Listing Details', showSearch: false),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (extra?.imageUrl != null)
              Hero(
                tag: 'listing-${extra!.id}',
                child: Image.network(
                  extra!.imageUrl!,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(height: 300, color: Colors.grey[300]),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    extra?.title ?? 'Listing #$id',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    extra?.subtitle ?? 'Address',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Description",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "This is a beautiful apartment located in a prime area. It features modern amenities, spacious rooms, and a great view. Perfect for families or professionals.",
                  ),
                  // Add more details here
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
