import 'package:flutter/material.dart';
import 'package:client/l10n/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/smart_dashboard_panel.dart';

class LandlordDashboardScreen extends StatefulWidget {
  const LandlordDashboardScreen({super.key});

  @override
  State<LandlordDashboardScreen> createState() => _LandlordDashboardScreenState();
}

class _LandlordDashboardScreenState extends State<LandlordDashboardScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.alabaster,
      appBar: CustomAppBar(title: AppLocalizations.of(context)!.partnerPortal, showSearch: false),
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(
                    child: Text(
                      AppLocalizations.of(context)!.businessInsights,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.structuralBrown),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildActionCards(context),
                  const SizedBox(height: 24),
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: _buildOccupancyChart(),
                  ),
                  const SizedBox(height: 24),
                  Text(AppLocalizations.of(context)!.propertyPerformance, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildPropertyPerformanceItem(name: 'Skyline Terrace', views: '2.4k', leads: '12'),
                  _buildPropertyPerformanceItem(name: 'Oakwood Studio', views: '1.2k', leads: '5'),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          const SmartDashboardPanel(currentRoute: '/landlord-dashboard'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/create-listing');
        },
        backgroundColor: AppColors.structuralBrown,
        icon: const Icon(Icons.add, color: AppColors.champagne),
        label: Text(AppLocalizations.of(context)!.addListing, style: const TextStyle(color: AppColors.champagne)),
      ),
    );
  }

  Widget _buildActionCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            title: AppLocalizations.of(context)!.leads,
            count: '14',
            icon: Icons.chat_bubble_outline,
            color: AppColors.mutedGold,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            title: AppLocalizations.of(context)!.revenue,
            count: 'KES 85k',
            icon: Icons.trending_up,
            color: AppColors.sageGreen,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildOccupancyChart() {
    return GlassContainer(
      height: 250,
      borderRadius: BorderRadius.circular(24),
      color: Colors.white,
      opacity: 0.6,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.portfolioHealth, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            Expanded(
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: AppColors.structuralBrown, width: 16)]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 10, color: AppColors.mutedGold, width: 16)]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 14, color: AppColors.sageGreen, width: 16)]),
                    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 15, color: AppColors.brickRed, width: 16)]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyPerformanceItem({required String name, required String views, required String leads}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        opacity: 0.7,
        child: ListTile(
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${AppLocalizations.of(context)!.pulseViews}: $views • ${AppLocalizations.of(context)!.qualifiedLeads}: $leads'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () {},
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({required this.title, required this.count, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        opacity: 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(count, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
