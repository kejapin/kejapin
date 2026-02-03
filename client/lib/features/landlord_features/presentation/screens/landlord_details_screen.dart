import 'package:flutter/material.dart';
import 'package:client/l10n/app_localizations.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../search/data/models/search_result.dart';

class LandlordDetailsScreen extends StatelessWidget {
  final String id;
  final SearchResult? extra;

  const LandlordDetailsScreen({super.key, required this.id, this.extra});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppLocalizations.of(context)!.landlordProfile, showSearch: false),
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
              extra?.title ?? AppLocalizations.of(context)!.landlordName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              extra?.subtitle ?? 'Rating',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            // Listings by this landlord
            const Divider(),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(AppLocalizations.of(context)!.listingsByLandlord),
            ),
            // Placeholder list
          ],
        ),
      ),
    );
  }
}
