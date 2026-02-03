import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentBubble extends StatelessWidget {
  final double amount;
  final String title;
  final bool isMe;

  const PaymentBubble({super.key, required this.amount, required this.title, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.payment, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: GoogleFonts.workSans(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'KES ${amount.toStringAsFixed(0)}',
            style: GoogleFonts.workSans(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (!isMe)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: Text(AppLocalizations.of(context)!.payNow),
              ),
            ),
        ],
      ),
    );
  }
}
