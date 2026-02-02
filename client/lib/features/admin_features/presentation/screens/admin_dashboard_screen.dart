import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/smart_dashboard_panel.dart';
import '../../data/admin_repository.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminRepository _adminRepo = AdminRepository();
  late Future<List<SupportTicket>> _ticketsFuture;

  @override
  void initState() {
    super.initState();
    _ticketsFuture = _adminRepo.getAllSupportTickets();
  }

  void _refreshTickets() {
    setState(() {
      _ticketsFuture = _adminRepo.getAllSupportTickets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.alabaster,
      appBar: const CustomAppBar(title: 'REWARD ADMIN', showSearch: false),
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
                      'Platform Overview',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.structuralBrown),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildQuickStats(),
                  const SizedBox(height: 24),
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: _buildRevenueChart(),
                  ),
                  const SizedBox(height: 24),
                  _buildSupportTicketsSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          const SmartDashboardPanel(currentRoute: '/admin-dashboard'),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(child: _StatCard(title: 'Active Users', value: '1,240', icon: Icons.people, color: Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(title: 'Total Revenue', value: 'KES 2.4M', icon: Icons.payments, color: Colors.green)),
      ],
    );
  }

  Widget _buildRevenueChart() {
    return GlassContainer(
      height: 300,
      borderRadius: BorderRadius.circular(24),
      color: Colors.white,
      opacity: 0.6,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Revenue Growth', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 3),
                        const FlSpot(2.6, 2),
                        const FlSpot(4.9, 5),
                        const FlSpot(6.8, 3.1),
                        const FlSpot(8, 4),
                        const FlSpot(9.5, 3),
                        const FlSpot(11, 4),
                      ],
                      isCurved: true,
                      color: AppColors.mutedGold,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.mutedGold.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportTicketsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Incoming Support Tickets', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            IconButton(onPressed: _refreshTickets, icon: const Icon(Icons.refresh, size: 20)),
          ],
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<SupportTicket>>(
          future: _ticketsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
            }
            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('No active tickets found.', style: TextStyle(color: Colors.grey))),
              );
            }

            final tickets = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: GlassContainer(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    opacity: 0.7,
                    child: ListTile(
                      title: Text(ticket.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(ticket.message, maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text('From: ${ticket.userEmail ?? 'Unknown'} • ${ticket.status}',
                               style: TextStyle(fontSize: 12, color: _getStatusColor(ticket.status))),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (val) async {
                          await _adminRepo.updateTicketStatus(ticket.id, val);
                          _refreshTickets();
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'OPEN', child: Text('Open')),
                          const PopupMenuItem(value: 'IN_PROGRESS', child: Text('In Progress')),
                          const PopupMenuItem(value: 'CLOSED', child: Text('Close')),
                        ],
                        icon: const Icon(Icons.more_vert),
                      ),
                      isThreeLine: true,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'OPEN': return Colors.red;
      case 'IN_PROGRESS': return Colors.orange;
      case 'CLOSED': return Colors.green;
      default: return Colors.grey;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
      opacity: 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

class _QueueItem extends StatelessWidget {
  final String name;
  final String docs;
  final String time;

  const _QueueItem({required this.name, required this.docs, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        opacity: 0.7,
        child: ListTile(
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('Docs: $docs • $time'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(icon: const Icon(Icons.check_circle, color: Colors.green), onPressed: () {}),
              IconButton(icon: const Icon(Icons.cancel, color: Colors.red), onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
