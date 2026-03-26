import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../features/cattle/presentation/screens/cattle_list_screen.dart';
import '../../../../features/cattle/presentation/screens/bull_list_screen.dart';
import '../../../../features/milk_production/presentation/screens/milk_production_screen.dart';
import '../../../../features/milk_distribution/presentation/screens/distribute_milk_screen.dart';
import '../../../../features/heat_record/presentation/screens/heat_record_screen.dart';
import '../../../../features/conception/presentation/screens/conception_screen.dart';
import '../../../../features/dry_off/presentation/screens/dry_off_screen.dart';
import '../../../../features/animal_health/presentation/screens/medical_information_screen.dart';
import '../../../../features/animal_health/presentation/screens/vaccination_information_screen.dart';
import '../../../../features/reports/presentation/screens/reports_screen.dart';
import '../../../../features/reports/presentation/screens/alert_hub_screen.dart';
import '../../../../features/animal_left/presentation/screens/sell_report_screen.dart';
import '../../../../features/animal_left/presentation/screens/death_report_screen.dart';
import '../../../../features/animal_left/presentation/screens/donation_report_screen.dart';
import '../../../../features/animal_health/presentation/screens/deworming_information_screen.dart';
import '../../../../features/animal_health/presentation/screens/lab_testing_information_screen.dart';
import '../../../../features/photo_gallery/presentation/screens/photo_gallery_screen.dart';
import '../../../../features/photo_gallery/presentation/screens/video_gallery_screen.dart';
import '../../../../features/animal_health/presentation/screens/sick_animal_screen.dart';
import '../../../../features/cattle/presentation/bloc/cattle_bloc.dart';
import '../../../../features/cattle/presentation/bloc/cattle_state.dart';
import '../../../../features/cattle/presentation/bloc/cattle_event.dart';
import '../../../../features/cattle/domain/entities/cattle.dart';
import '../../../../features/cattle/data/models/cattle_model.dart';
import '../../../../features/conception/domain/entities/conception_record.dart';
import '../../../../features/heat_record/domain/entities/heat_record.dart';
import '../../../../features/milk_production/presentation/bloc/milk_production_bloc.dart';
import '../../../../features/milk_production/presentation/bloc/milk_production_state.dart';
import '../../../../features/milk_production/presentation/bloc/milk_production_event.dart';
import '../../../../features/milk_production/domain/entities/milk_production_entry.dart';
import '../../../../features/animal_health/domain/entities/health_event.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/di/injection_container.dart';

class GaushalaTab extends StatefulWidget {
  const GaushalaTab({super.key});

  @override
  State<GaushalaTab> createState() => _GaushalaTabState();
}

class _GaushalaTabState extends State<GaushalaTab> {
  final Color _oliveGreen = const Color(0xFF8DA94D);
  static const String _summaryCacheKey = 'CACHED_ANIMAL_SUMMARY';
  static const String _cattleCacheKey = 'CACHED_CATTLE_LIST';
  static const String _deliveredJourneyIdsKey =
      'LOCALLY_DELIVERED_CONCEPTION_IDS';
  Map<String, dynamic>? _summary;
  List<Cattle> _cachedCattle = [];
  int? _derivedSickAnimalCount;
  int? _heatRecordCount;
  int? _conceptionCount;
  int? _dryOffRecordCount;

  @override
  void initState() {
    super.initState();
    _loadCachedSummary();
    _loadCachedCattle();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _triggerBlocLoads();
    await _fetchSummary();
    await _fetchHealthAndReproductionCounts();
  }

  Future<void> _loadCachedSummary() async {
    try {
      final prefs = sl<SharedPreferences>();
      final cached = prefs.getString(_summaryCacheKey);
      if (cached == null || cached.isEmpty) return;
      final value = Map<String, dynamic>.from(jsonDecode(cached) as Map);
      if (value.isNotEmpty && mounted) {
        setState(() {
          _summary = value;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadCachedCattle() async {
    try {
      final prefs = sl<SharedPreferences>();
      final cached = prefs.getString(_cattleCacheKey);
      if (cached == null || cached.isEmpty) return;
      final decoded = jsonDecode(cached) as List<dynamic>;
      final cattle = decoded
          .map((item) => CattleModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      if (mounted) {
        setState(() {
          _cachedCattle = cattle;
        });
      }
    } catch (_) {}
  }

  Future<void> _triggerBlocLoads() async {
    final cattleBloc = context.read<CattleBloc>();
    final milkBloc = context.read<MilkProductionBloc>();

    cattleBloc.add(const LoadCattleList());

    List<Cattle> cattleList = [];
    final currentState = cattleBloc.state;
    if (currentState is CattleListLoaded) {
      cattleList = currentState.cattleList;
    } else {
      final loadedState = await cattleBloc.stream.firstWhere(
        (state) =>
            state is CattleListLoaded ||
            state is CattleEmpty ||
            state is CattleError,
      );

      if (loadedState is CattleListLoaded) {
        cattleList = loadedState.cattleList;
      }
    }

    milkBloc.add(
      LoadMilkProductionList(date: DateTime.now(), cattleList: cattleList),
    );

    final milkState = milkBloc.state;
    if (milkState is! MilkProductionLoaded && milkState is! MilkProductionError) {
      await milkBloc.stream.firstWhere(
        (state) => state is MilkProductionLoaded || state is MilkProductionError,
      );
    }
  }

  Future<void> _fetchSummary() async {
    try {
      final summary = await sl<ApiService>().getAnimalSummary();
      final data = Map<String, dynamic>.from(summary['data'] ?? summary);
      final prefs = sl<SharedPreferences>();
      await prefs.setString(_summaryCacheKey, jsonEncode(data));
      if (mounted) {
        setState(() {
          _summary = data;
        });
      }
    } catch (e) {
      debugPrint("Summary Error: $e");
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _fetchDerivedSickAnimalCount() async {
    if (_hasUsableSummaryValue(['sickAnimalCount', 'sickCount'])) {
      return;
    }
    try {
      final items = await sl<ApiService>().getMedicalHistory();
      final records = items
          .whereType<Map>()
          .map((e) => HealthEvent.fromJson(Map<String, dynamic>.from(e), 'Medical'))
          .toList()
        ..sort((a, b) => b.eventDate.compareTo(a.eventDate));

      final latestByAnimal = <String, HealthEvent>{};
      for (final record in records) {
        final key = [
          record.id,
          record.cowTagNumber,
          record.cowSerialNumber,
          record.cowName,
        ].firstWhere((value) => value.trim().isNotEmpty && value.trim() != '-', orElse: () => '');
        if (key.isEmpty || latestByAnimal.containsKey(key)) continue;
        latestByAnimal[key] = record;
      }

      final sickCount = latestByAnimal.values.where((record) {
        final status = (record.medicalStatus ?? record.status).toUpperCase();
        return status == 'SICK';
      }).length;

      if (mounted) {
        setState(() {
          _derivedSickAnimalCount = sickCount;
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchHealthAndReproductionCounts() async {
    final activeCattle = _getActiveCattle();
    final femaleCattle = activeCattle
        .where((c) => c.gender.toUpperCase().startsWith('F'))
        .toList();
    final registry = _DashboardAnimalRegistry.from(activeCattle);
    final prefs = sl<SharedPreferences>();
    final deliveredJourneyKeys = (prefs.getStringList(_deliveredJourneyIdsKey) ??
            const <String>[])
        .where((id) => id.trim().isNotEmpty)
        .toSet();

    int heatCount = 0;
    int conceptionCount = 0;
    int dryOffCount = 0;

    try {
      final items = await sl<ApiService>().getHeatReport(
        from: DateTime.now().subtract(const Duration(days: 30)),
        to: DateTime.now().add(const Duration(days: 1)),
      );
      final records = items
          .whereType<Map>()
          .map(
            (item) => HeatRecord.fromJson(Map<String, dynamic>.from(item)),
          )
          .where(
            (record) => registry.matches(
              animalId: record.animalId,
              tagNumber: record.cowTagNumber,
              serialNumber: record.cowSerialNumber,
              name: record.cowName,
            ),
          )
          .toList();
      heatCount = records.length;
    } catch (_) {}

    try {
      final items = await sl<ApiService>().getActiveJourneys();
      final records = items
          .whereType<Map>()
          .map(
            (item) => ConceptionRecord.fromJson(Map<String, dynamic>.from(item)),
          )
          .where((record) => !record.isDelivered)
          .where((record) => !_isLocallyDeliveredConception(record, deliveredJourneyKeys))
          .where(
            (record) => registry.matches(
              animalId: record.cowId,
              tagNumber: record.cowTagNumber,
              serialNumber: record.cowSerialNumber,
              name: record.cowName,
            ),
          )
          .toList();
      conceptionCount = records.length;
    } catch (_) {}

    try {
      dryOffCount = await _fetchDryOffCount(femaleCattle);
    } catch (_) {}

    if (mounted) {
      setState(() {
        _heatRecordCount = heatCount;
        _conceptionCount = conceptionCount;
        _dryOffRecordCount = dryOffCount;
      });
    }
  }

  Future<int> _fetchDryOffCount([List<Cattle>? cows]) async {
    final femaleCattle = cows ??
        _getActiveCattle()
            .where((c) => c.gender.toUpperCase().startsWith('F'))
            .toList();

    if (femaleCattle.isEmpty) return 0;

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final endDate = now.add(const Duration(days: 30));
    final end = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      23,
      59,
      59,
    );
    final uniqueIds = <String>{};

    for (final cow in femaleCattle) {
      try {
        final records = await sl<ApiService>().getDryOffReport(animalId: cow.id);
        for (final raw in records.whereType<Map>()) {
          final id =
              raw['id']?.toString() ??
              raw['_id']?.toString() ??
              '';
          final dateRaw = raw['date']?.toString();
          final date = dateRaw != null ? DateTime.tryParse(dateRaw) : null;

          if (id.isEmpty || date == null) continue;
          if (date.isBefore(start) || date.isAfter(end)) continue;

          uniqueIds.add(id);
        }
      } catch (_) {
        // Ignore per-animal failures so one bad record doesn't zero the dashboard.
      }
    }

    return uniqueIds.length;
  }

  List<Cattle> _getCurrentCattleList() {
    final cattleState = context.read<CattleBloc>().state;
    if (cattleState is CattleListLoaded) {
      final loadedList = cattleState.cattleList;
      final shouldUseCachedFullList =
          _cachedCattle.isNotEmpty &&
          _isFilteredGenderOnlyList(loadedList) &&
          _cachedCattle.length > loadedList.length;
      return shouldUseCachedFullList ? _cachedCattle : loadedList;
    }
    return _cachedCattle;
  }

  List<Cattle> _getActiveCattle() {
    return _getCurrentCattleList().where((c) => c.isActive).toList();
  }

  int _summaryCount(List<String> keys, {int fallback = 0}) {
    for (final key in keys) {
      final raw = _summary?[key];
      final parsed = int.tryParse(raw?.toString() ?? '');
      if (parsed != null) return parsed;
    }
    return fallback;
  }

  int _nestedSummaryCount(
    String parent,
    String child, {
    int fallback = 0,
  }) {
    final section = _summary?[parent];
    if (section is Map) {
      final parsed = int.tryParse(section[child]?.toString() ?? '');
      if (parsed != null) return parsed;
    }
    return fallback;
  }

  Future<void> _refreshDashboard() async {
    await _triggerBlocLoads();
    await _fetchSummary();
    await _fetchDerivedSickAnimalCount();
    await _fetchHealthAndReproductionCounts();
  }

  Future<void> _refreshDeferredDashboardMetrics() async {
    await _fetchDerivedSickAnimalCount();
    await _fetchHealthAndReproductionCounts();
  }

  bool _hasUsableSummaryValue(List<String> keys) {
    for (final key in keys) {
      final raw = _summary?[key];
      if (raw == null) continue;
      if (int.tryParse(raw.toString()) != null) return true;
    }
    return false;
  }

  bool _isFilteredGenderOnlyList(List<Cattle> list) {
    if (list.isEmpty) return false;
    final hasFemale = list.any((c) => c.gender.toUpperCase().startsWith('F'));
    final hasMale = list.any((c) => c.gender.toUpperCase().startsWith('M'));
    return hasFemale != hasMale;
  }

  bool _isLocallyDeliveredConception(
    ConceptionRecord record,
    Set<String> deliveredKeys,
  ) {
    final conceiveKey = record.conceiveDate.toIso8601String().split('T').first;
    final cowId = record.cowId?.trim() ?? '';
    final tag = record.cowTagNumber.trim().toLowerCase();
    final name = record.cowName.trim().toLowerCase();
    final serial = record.cowSerialNumber.trim().toLowerCase();
    final candidates = <String>{
      if (record.id.trim().isNotEmpty) record.id.trim(),
      if (cowId.isNotEmpty) 'cow:$cowId|date:$conceiveKey',
      if (tag.isNotEmpty && tag != '-') 'tag:$tag|date:$conceiveKey',
      if (serial.isNotEmpty && serial != '-') 'serial:$serial|date:$conceiveKey',
      if (name.isNotEmpty && name != 'unknown cow') 'name:$name|date:$conceiveKey',
    };
    return candidates.any(deliveredKeys.contains);
  }

  bool _isHeiferCandidate(Cattle cattle) => cattle.effectiveIsHeifer;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CattleBloc, CattleState>(
      builder: (context, cattleState) {
        return BlocBuilder<MilkProductionBloc, MilkProductionState>(
          builder: (context, milkState) {
            final cattleList = _getCurrentCattleList();
            // Removed direct Event triggers from Build to prevent UI lag/loops

            List<MilkProductionEntry> milkEntries = [];
            if (milkState is MilkProductionLoaded) {
              milkEntries = milkState.entries;
            }

            // Calculate cattle counts
            final List<Cattle> activeCattle = cattleList
                .where(
                  (c) =>
              (c.status.toUpperCase() == 'ACTIVE' ||
                  c.status.toLowerCase() == 'bull') &&
                  c.isRetired != true,
            )
                .toList();

            final int allCowCount = _summaryCount(
              ['allCowCount'],
              fallback: _nestedSummaryCount(
                'cows',
                'total',
                fallback: activeCattle
                    .where((c) => c.isFemaleGender)
                    .length,
              ),
            );

            final int allBullCount = _summaryCount(
              ['allBullCount'],
              fallback: _nestedSummaryCount(
                'bulls',
                'total',
                fallback: activeCattle
                    .where((c) => c.isMaleGender)
                    .length,
              ),
            );

            final int lactatingCount = _summaryCount(
              ['lactatingCount'],
              fallback: _nestedSummaryCount(
                'cows',
                'lactating',
                fallback: activeCattle
                    .where((c) => c.effectiveIsLactating)
                    .length,
              ),
            );

            final int heiferCount = activeCattle
                .where(_isHeiferCandidate)
                .length;

            final int calvingCount = _summaryCount(
              ['pregnantCount'],
              fallback: _nestedSummaryCount(
                'cows',
                'pregnant',
                fallback: activeCattle
                    .where((c) => c.effectiveIsPregnant)
                    .length,
              ),
            );

            final int dryCount = _summaryCount(
              ['dryOffCount'],
              fallback: _nestedSummaryCount(
                'cows',
                'dryOff',
                fallback: activeCattle
                    .where((c) => c.effectiveIsDryOff)
                    .length,
              ),
            );

            final String sickAnimalCount = _summaryCount(
              ['sickAnimalCount', 'sickCount'],
              fallback: _derivedSickAnimalCount ?? 0,
            ).toString();
            final String heatRecordCount = (_heatRecordCount ?? 0).toString();
            final String pregnancyStatusCount =
                (_conceptionCount ?? calvingCount).toString();
            final String dryOffTargetCount =
                (_dryOffRecordCount ?? dryCount).toString();

            final double totalMorningMilk = milkEntries.fold<double>(
              0.0,
                  (sum, entry) => sum + entry.morningMilk,
            );
            final double totalEveningMilk = milkEntries.fold<double>(
              0.0,
                  (sum, entry) => sum + entry.eveningMilk,
            );
            final double totalTodayMilk = totalMorningMilk + totalEveningMilk;

            String formatCount(int count) {
              return count.toString().padLeft(2, '0');
            }
            String formatAmount(double amount) => amount.toStringAsFixed(1);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'All Cow',
                          formatCount(allCowCount),
                          'assets/icons/all_cow_icon.png',
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CattleListScreen(),
                              ),
                            );
                            if (mounted) _refreshDashboard();
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSummaryCard(
                          'All Bull',
                          formatCount(allBullCount),
                          'assets/icons/all_bull_icon.png',
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BullListScreen(),
                              ),
                            );
                            if (mounted) _refreshDashboard();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Cattle Status', action: ''),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 140,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildStatusCircle(
                          formatCount(lactatingCount),
                          'Lactating',
                          Colors.green,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CattleListScreen(
                                  initialFilter: 'Lactating',
                                ),
                              ),
                            );
                          },
                        ),
                        _buildStatusCircle(
                          formatCount(heiferCount),
                          'Heifer',
                          Colors.teal,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CattleListScreen(
                                  initialFilter: 'Heifer',
                                ),
                              ),
                            );
                          },
                        ),
                        _buildStatusCircle(
                          formatCount(calvingCount),
                          'Calving',
                          Colors.orange,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CattleListScreen(
                                  initialFilter: 'Calving',
                                ),
                              ),
                            );
                          },
                        ),
                        _buildStatusCircle(
                          formatCount(dryCount),
                          'Dry',
                          Colors.brown,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CattleListScreen(
                                  initialFilter: 'Dry',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: _oliveGreen,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const MilkProductionScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.water_drop,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Today\'s Production',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: formatAmount(totalTodayMilk),
                                      style: GoogleFonts.poppins(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' Ltr',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildProductionSubCard(
                                      'Morning',
                                      '${formatAmount(totalMorningMilk)} Ltr',
                                      Icons.wb_sunny_rounded,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildProductionSubCard(
                                      'Evening',
                                      '${formatAmount(totalEveningMilk)} Ltr',
                                      Icons.nightlight_round,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Health & Reproduction'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HeatRecordScreen(),
                              ),
                            );
                            if (mounted) _fetchHealthAndReproductionCounts();
                          },
                          child: _buildListRow(
                            Icons.favorite,
                            Colors.pink,
                            'Heat Record',
                            'Total Active',
                            heatRecordCount,
                          ),
                        ),
                        const Divider(height: 24),
                        GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ConceptionScreen(),
                              ),
                            );
                            if (mounted) _fetchHealthAndReproductionCounts();
                          },
                          child: _buildListRow(
                            Icons.pregnant_woman,
                            Colors.purple,
                            'Conception',
                            'Pregnancy Status',
                            pregnancyStatusCount,
                          ),
                        ),
                        const Divider(height: 24),
                        GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DryOffScreen(),
                              ),
                            );
                            if (mounted) _fetchHealthAndReproductionCounts();
                          },
                          child: _buildListRow(
                            Icons.block,
                            Colors.grey,
                            'Dry Off Cow',
                            'Target Date',
                            dryOffTargetCount,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F8E9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green.shade100),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const DistributeMilkScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.local_shipping,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Distribute Milk',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      'Track daily delivery',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ReportsScreen(),
                              ),
                            );
                          },
                          child: _buildGridCard(
                            Icons.article,
                            Colors.blue,
                            'Reports',
                            'View Analytics',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AlertHubScreen(),
                              ),
                            );
                          },
                          child: _buildGridCard(
                            Icons.notifications_active,
                            Colors.red,
                            'Alerts',
                            'View Alerts',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Animal Left from Gaushala'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildActionRow(
                          context,
                          icon: Icons.sell_outlined,
                          color: Colors.orange,
                          title: 'Sell',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SellReportScreen(),
                              ),
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Divider(
                            height: 1,
                            color: Colors.grey.shade100,
                          ),
                        ),
                        _buildActionRow(
                          context,
                          icon: Icons.warning_amber_rounded,
                          color: Colors.blueGrey,
                          title: 'Death',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DeathReportScreen(),
                              ),
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Divider(
                            height: 1,
                            color: Colors.grey.shade100,
                          ),
                        ),
                        _buildActionRow(
                          context,
                          icon: Icons.volunteer_activism_outlined,
                          color: Colors.green,
                          title: 'Donation',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DonationReportScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Animal Health Information'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                const MedicalInformationScreen(),
                              ),
                            );
                            if (mounted) _refreshDashboard();
                          },
                          child: _buildHealthCard(
                            'Medical',
                            Icons.medical_services_outlined,
                            Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                const VaccinationInformationScreen(),
                              ),
                            );
                          },
                          child: _buildHealthCard(
                            'Vaccination',
                            Icons.colorize_outlined,
                            Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                const DewormingInformationScreen(),
                              ),
                            );
                          },
                          child: _buildHealthCard(
                            'Deworming',
                            Icons.spa_outlined,
                            Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                const LabTestingInformationScreen(),
                              ),
                            );
                          },
                          child: _buildHealthCard(
                            'Lab Testing',
                            Icons.biotech_outlined,
                            Colors.purple,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SickAnimalScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.shade100),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.sick_outlined,
                              color: Colors.brown,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sick Animal',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.red,
                                  ),
                                ),
                                Text(
                                  sickAnimalCount,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PhotoGalleryScreen(),
                              ),
                            );
                          },
                          child: _buildHealthCard(
                            'Photo Gallery',
                            Icons.image_outlined,
                            Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const VideoGalleryScreen(),
                              ),
                            );
                          },
                          child: _buildHealthCard(
                            'Video Gallery',
                            Icons.movie_outlined,
                            Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- Helper Widgets remain unchanged ---

  Widget _buildSectionHeader(String title, {String? action}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        if (action != null)
          Text(
            action,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF8DA94D),
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title,
      String count,
      String asset, {
        VoidCallback? onTap,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.arrow_drop_down, color: _oliveGreen),
                        Flexible(
                          child: Text(
                            title,
                            style: GoogleFonts.inter(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      count,
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _oliveGreen,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                bottom: -15,
                child: Opacity(
                  opacity: 0.8,
                  child: Image.asset(
                    asset,
                    width: 80,
                    height: 80,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCircle(
      String count,
      String label,
      Color color, {
        VoidCallback? onTap,
      }) {
    return Padding(
      padding: const EdgeInsets.only(right: 12, bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(25),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFA5D6A7),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    count,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF388E3C),
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductionSubCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(51),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 10),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(
      BuildContext context, {
        required IconData icon,
        required Color color,
        required String title,
        required VoidCallback onTap,
      }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withAlpha(13),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
    );
  }

  Widget _buildListRow(
      IconData icon,
      Color color,
      String title,
      String subtitle,
      String value, {
        String? assetPath,
      }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: assetPath != null
              ? Image.asset(assetPath, width: 20, height: 20, color: color)
              : Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
                ),
            ],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildGridCard(
      IconData icon,
      Color color,
      String title,
      String subtitle, {
        String? assetPath,
      }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: assetPath != null
                ? Image.asset(assetPath, width: 20, height: 20, color: color)
                : Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subtitle,
                style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
              ),
              const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthCard(
      String title,
      IconData icon,
      Color color, {
        String? assetPath,
      }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: assetPath != null
                ? Image.asset(assetPath, width: 20, height: 20, color: color)
                : Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Icon(
              Icons.chevron_right,
              size: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardAnimalRegistry {
  final Set<String> ids;
  final Set<String> tags;
  final Set<String> serials;
  final Set<String> names;

  const _DashboardAnimalRegistry({
    required this.ids,
    required this.tags,
    required this.serials,
    required this.names,
  });

  factory _DashboardAnimalRegistry.from(List<Cattle> cattleList) {
    String normalize(String? value) => value?.trim().toLowerCase() ?? '';

    return _DashboardAnimalRegistry(
      ids: cattleList
          .map((c) => normalize(c.id))
          .where((v) => v.isNotEmpty)
          .toSet(),
      tags: cattleList
          .map((c) => normalize(c.tagNumber))
          .where((v) => v.isNotEmpty && v != '-')
          .toSet(),
      serials: cattleList
          .map((c) => normalize(c.serialNumber))
          .where((v) => v.isNotEmpty && v != '-')
          .toSet(),
      names: cattleList
          .map((c) => normalize(c.name))
          .where((v) => v.isNotEmpty && v != 'unknown')
          .toSet(),
    );
  }

  bool matches({
    String? animalId,
    String? tagNumber,
    String? serialNumber,
    String? name,
  }) {
    String normalize(String? value) => value?.trim().toLowerCase() ?? '';

    final normalizedId = normalize(animalId);
    if (normalizedId.isNotEmpty && ids.contains(normalizedId)) return true;

    final normalizedTag = normalize(tagNumber);
    if (normalizedTag.isNotEmpty && tags.contains(normalizedTag)) return true;

    final normalizedSerial = normalize(serialNumber);
    if (normalizedSerial.isNotEmpty && serials.contains(normalizedSerial)) {
      return true;
    }

    final normalizedName = normalize(name);
    if (normalizedName.isNotEmpty && names.contains(normalizedName)) return true;

    return false;
  }
}
