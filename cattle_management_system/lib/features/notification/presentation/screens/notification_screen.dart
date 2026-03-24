import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/api_service.dart';
import '../../../cattle/domain/entities/cattle.dart';
import '../../../cattle/presentation/bloc/cattle_bloc.dart';
import '../../../cattle/presentation/bloc/cattle_event.dart';
import '../../../cattle/presentation/bloc/cattle_state.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int _pregnancyCheckCount = 0;
  int _heatEligibleCount = 0;

  @override
  void initState() {
    super.initState();
    context.read<CattleBloc>().add(const LoadCattleList());
    _loadBreedingCounts();
  }

  Future<void> _loadBreedingCounts() async {
    try {
      final journeys = await sl<ApiService>().getActiveJourneys();
      final heatEligible = await sl<ApiService>().getHeatEligibleAnimals();
      final now = DateTime.now();
      final pendingChecks = journeys.whereType<Map>().where((journey) {
        final conceiveDate = DateTime.tryParse((journey['conceiveDate'] ?? '').toString());
        if (conceiveDate == null) return false;
        final days = now.difference(conceiveDate).inDays;
        return days >= 30 && days <= 90;
      }).length;
      if (mounted) {
        setState(() {
          _pregnancyCheckCount = pendingChecks;
          _heatEligibleCount = heatEligible.length;
        });
      }
    } catch (_) {}
  }

  List<_NotificationItem> _buildItems(List<Cattle> cattleList) {
    final activeAnimals = cattleList.where((c) {
      return c.status.toUpperCase() == 'ACTIVE' && c.isRetired != true;
    }).toList();
    final noTagCount = activeAnimals
        .where((animal) => animal.tagNumber.trim().isEmpty || animal.tagNumber.trim() == '-')
        .length;
    final adultCount = activeAnimals.where((animal) {
      return animal.dateOfAdult != null && !animal.dateOfAdult!.isAfter(DateTime.now());
    }).length;
    final missingParityCount = activeAnimals.where((animal) {
      return animal.gender.toUpperCase().startsWith('F') && (animal.parity == null);
    }).length;

    final items = <_NotificationItem>[
      if (noTagCount > 0)
        _NotificationItem(
          title: 'Ear Tag Alert',
          description: '$noTagCount animal${noTagCount == 1 ? ' is' : 's are'} pending for ear tagging.',
          icon: Icons.local_offer,
          color: Colors.grey,
          bgColor: Colors.grey.shade100,
        ),
      if (adultCount > 0)
        _NotificationItem(
          title: 'Adult Alert',
          description: '$adultCount animal${adultCount == 1 ? ' has' : 's have'} reached adult age.',
          icon: Icons.pets,
          color: const Color(0xFFA4C639),
          bgColor: const Color(0xFFF9FBE7),
        ),
      if (_pregnancyCheckCount > 0)
        _NotificationItem(
          title: 'Pregnancy Check',
          description: '$_pregnancyCheckCount cow${_pregnancyCheckCount == 1 ? '' : 's'} need pregnancy checking.',
          icon: Icons.pregnant_woman,
          color: Colors.green,
          bgColor: Colors.green.shade50,
        ),
      if (_heatEligibleCount > 0)
        _NotificationItem(
          title: 'Heat Alert',
          description: '$_heatEligibleCount animal${_heatEligibleCount == 1 ? ' is' : 's are'} eligible for heat action.',
          icon: Icons.favorite,
          color: Colors.pink,
          bgColor: Colors.pink.shade50,
        ),
      if (missingParityCount > 0)
        _NotificationItem(
          title: 'Missing Parity Info',
          description: '$missingParityCount cow${missingParityCount == 1 ? '' : 's'} have no parity info entered.',
          icon: Icons.assignment_late_outlined,
          color: Colors.orange,
          bgColor: Colors.orange.shade50,
        ),
    ];

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFA4C639)),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFA4C639), size: 20),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
          ),
        ),
        title: Text(
          'Notification',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
      ),
      body: BlocBuilder<CattleBloc, CattleState>(
        builder: (context, state) {
          final cattleList = state is CattleListLoaded ? state.cattleList : <Cattle>[];
          final notifications = _buildItems(cattleList);

          if (state is CattleLoading && notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (notifications.isEmpty) {
            return Center(
              child: Text(
                'No notifications',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final item = notifications[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: item.bgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item.icon, color: item.color, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.description,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _NotificationItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}
