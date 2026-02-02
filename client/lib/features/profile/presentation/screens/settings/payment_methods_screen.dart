import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/features/profile/data/profile_repository.dart';
import 'package:client/core/constants/app_colors.dart';
import 'package:client/core/widgets/custom_app_bar.dart';
import 'package:dotted_border/dotted_border.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final _profileRepo = ProfileRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.alabaster,
      appBar: CustomAppBar(title: 'PAYMENT METHODS', showSearch: false),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _profileRepo.getPaymentMethods(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final cards = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (cards.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No payment methods added yet.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                ),
              
              ...cards.map((card) {
                return Column(
                  children: [
                    _buildPaymentCard(
                      type: card['type'] ?? 'CARD',
                      details: card['details'] ?? '****',
                      isDefault: card['is_default'] ?? false,
                      color: card['type'] == 'MPESA' ? Colors.green.shade600 : const Color(0xFF1A1F71),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),

              const SizedBox(height: 8),
          
              // Add New Button
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add Payment Method requires a payment gateway integration.')),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 80,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                    color: Colors.transparent,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Add New Method',
                        style: GoogleFonts.workSans(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildPaymentCard({required String type, required String details, required bool isDefault, required Color color}) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              type == 'MPESA' ? Icons.phone_android : Icons.credit_card,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  type,
                  style: GoogleFonts.workSans(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Text(
                  details,
                  style: GoogleFonts.workSans(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (isDefault)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'DEFAULT',
                style: GoogleFonts.workSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  color: color,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
