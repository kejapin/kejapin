import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/smart_dashboard_panel.dart';

class TenantDashboardScreen extends StatefulWidget {
  const TenantDashboardScreen({super.key});

  @override
  State<TenantDashboardScreen> createState() => _TenantDashboardScreenState();
}

class _TenantDashboardScreenState extends State<TenantDashboardScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.alabaster,
      appBar: const CustomAppBar(title: 'MY LIFE-HUB', showSearch: false),
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
                    child: const Text(
                      'Spatial Activity',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.structuralBrown),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildEfficiencySummary(),
                  const SizedBox(height: 24),
                  _buildTimelineSection(),
                  const SizedBox(height: 24),
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: _buildBudgetChart(),
                  ),
                  const SizedBox(height: 100), // Padding for the bottom nav
                ],
              ),
            ),
          ),
          const SmartDashboardPanel(currentRoute: '/tenant-dashboard'),
        ],
      ),
    );
  }

  Widget _buildEfficiencySummary() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(24),
      color: AppColors.structuralBrown,
      opacity: 0.1,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Avg. Life-Pulse', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.sageGreen, borderRadius: BorderRadius.circular(20)),
                child: const Text('Top 10%', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildPulseRadar(),
        ],
      ),
    );
  }

  Widget _buildPulseRadar() {
    return SizedBox(
      height: 150,
      child: RadarChart(
        RadarChartData(
          dataSets: [
            RadarDataSet(
              fillColor: AppColors.mutedGold.withOpacity(0.4),
              borderColor: AppColors.mutedGold,
              entryRadius: 3,
              dataEntries: [
                const RadarEntry(value: 80),
                const RadarEntry(value: 70),
                const RadarEntry(value: 90),
                const RadarEntry(value: 40),
                const RadarEntry(value: 60),
                const RadarEntry(value: 85),
              ],
            ),
          ],
          radarBorderData: const BorderSide(color: Colors.transparent),
          tickBorderData: const BorderSide(color: Colors.transparent),
          gridBorderData: BorderSide(color: Colors.grey.withOpacity(0.2)),
          // Prevent the chart from stealing scroll gestures
          getTitle: (index, angle) => const RadarChartTitle(text: ''),
        ),
      ),
    );
  }

  Widget _buildTimelineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Life-Path Journey', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _TimelineItem(
          title: 'Viewing: Skyline Terrace',
          subtitle: 'Scheduled: Tomorrow, 10:00 AM',
          icon: Icons.calendar_today,
          color: AppColors.mutedGold,
          isCurrent: true,
        ),
        _TimelineItem(
          title: 'Application: Silver Oak',
          subtitle: 'Status: Pending Landlord Review',
          icon: Icons.hourglass_empty,
          color: Colors.orange,
          isCurrent: false,
        ),
        _TimelineItem(
          title: 'Stay: Oakwood Studio',
          subtitle: 'Completed: Jan 2024 - Dec 2024',
          icon: Icons.history,
          color: Colors.grey,
          isCurrent: false,
          showReviewButton: true,
        ),
        _TimelineItem(
          title: 'Review: Urban Residency',
          subtitle: 'Rating: 4.8 - Shared on Pulse Network',
          icon: Icons.rate_review_outlined,
          color: AppColors.sageGreen,
          isCurrent: false,
        ),
      ],
    );
  }

  Widget _buildBudgetChart() {
    return GlassContainer(
      height: 200,
      borderRadius: BorderRadius.circular(24),
      color: Colors.white,
      opacity: 0.6,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Spatial Savings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            Expanded(
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 5, color: AppColors.structuralBrown.withOpacity(0.3))]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 8, color: AppColors.structuralBrown.withOpacity(0.3))]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 15, color: AppColors.sageGreen)]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isCurrent;
  final bool showReviewButton;

  const _TimelineItem({
    required this.title, 
    required this.subtitle, 
    required this.icon, 
    required this.color, 
    required this.isCurrent,
    this.showReviewButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 18),
              ),
              if (!isCurrent) Container(width: 2, height: 40, color: Colors.grey.shade300),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GlassContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              opacity: 0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  if (showReviewButton) ...[
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        context.push('/review/oakwood-studio?name=Oakwood Studio');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mutedGold,
                        foregroundColor: AppColors.structuralBrown,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Rate Performance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
