import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../search/data/models/search_result.dart';

class LandlordDetailsScreen extends StatelessWidget {
  final String id;
  final SearchResult? extra;

  const LandlordDetailsScreen({super.key, required this.id, this.extra});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Landlord Profile', showSearch: false),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),
            CircleAvatar(
              radius: 60,
              backgroundImage: extra?.imageUrl != null ? NetworkImage(extra!.imageUrl!) : null,
              child: extra?.imageUrl == null ? const Icon(Icons.person, size: 60) : null,
            ),
            const SizedBox(height: 16),
            Text(
              extra?.title ?? 'Landlord Name',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              extra?.subtitle ?? 'Rating',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            // Listings by this landlord
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Listings by this landlord"),
            ),
            // Placeholder list
          ],
        ),
      ),
    );
  }
}
