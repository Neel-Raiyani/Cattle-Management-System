import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../cattle/domain/entities/cattle.dart';
import '../../../cattle/presentation/bloc/cattle_bloc.dart';
import '../../../cattle/presentation/bloc/cattle_event.dart';
import '../../../cattle/presentation/bloc/cattle_state.dart';

// ---------------------------------------------------------------------------
// Mock cow data shared across all sub-screens
// ---------------------------------------------------------------------------
// Mock data removed. Using CattleBloc.

// ---------------------------------------------------------------------------
// CowReportScreen – main screen matching iPhone 16 - 195.png design
// ---------------------------------------------------------------------------
class CowReportScreen extends StatefulWidget {
  const CowReportScreen({super.key});

  @override
  State<CowReportScreen> createState() => _CowReportScreenState();
}

class _CowReportScreenState extends State<CowReportScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CattleBloc>().add(const LoadCattleList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        title: Text(
          'Cow Report',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: BlocBuilder<CattleBloc, CattleState>(
        builder: (context, state) {
          List<Cattle> allCattle = [];
          if (state is CattleListLoaded) {
            allCattle = state.cattleList;
          } else if (state is CattleDetailLoaded) {
            allCattle = [state.cattle];
          }

          final cows = allCattle
              .where(
                (c) =>
                    c.isFemaleGender && c.isActive,
              )
              .toList();

          final heifer = cows.where((c) => c.effectiveIsHeifer).length;
          final pregnant = cows.where((c) => c.effectiveIsPregnant).length;
          final lactating = cows.where((c) => c.effectiveIsLactating).length;
          final dryOff = cows.where((c) => c.effectiveIsDryOff).length;
          final retired = allCattle
              .where(
                (c) =>
                    c.isFemaleGender && c.effectiveIsRetired,
              )
              .length;
          final total = cows.length + retired;

          // bar heights
          final counts = [heifer, pregnant, lactating, dryOff, retired];
          final maxCount = counts.reduce((a, b) => a > b ? a : b);

          final barColors = [
            Colors.blue,
            Colors.amber,
            const Color(0xFFE8A0C0),
            Colors.red,
            const Color(0xFF99AA5A),
          ];
          final labels = [
            'Heifer',
            'Pregnant',
            'Lactating',
            'Dry Off',
            'Retired Cow',
          ];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Status Summary Card ─────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.18)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Summary',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Bar chart ────────────────────────────────────────────
                    SizedBox(
                      height: 200,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Y-axis labels
                          SizedBox(
                            width: 38,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '100%',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  '50%',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  '25%',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  '0%',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Bars area
                          Expanded(
                            child: Stack(
                              children: [
                                // Horizontal grid lines
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _GridLine(),
                                    _GridLine(),
                                    _GridLine(),
                                    _GridLine(),
                                  ],
                                ),
                                // Bars
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: List.generate(5, (i) {
                                    final count = counts[i];
                                    final pct = total == 0
                                        ? 0.0
                                        : count / total;
                                    final barH = maxCount == 0
                                        ? 0.0
                                        : (count / maxCount) * 132.0;
                                    final pctLabel =
                                        '${(pct * 100).toStringAsFixed(1)}%';
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          pctLabel,
                                          style: GoogleFonts.inter(
                                            fontSize: 9,
                                            color: barColors[i],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 600,
                                          ),
                                          width: 38,
                                          height: barH,
                                          decoration: BoxDecoration(
                                            color: barColors[i],
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                  top: Radius.circular(6),
                                                ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 14),

                    // ── Tappable Legend rows ─────────────────────────────────
                    ...List.generate(5, (i) {
                      final statusKeys = [
                        'heifer',
                        'pregnant',
                        'lactating',
                        'dry',
                        'retired',
                      ];
                      return _LegendRow(
                        color: barColors[i],
                        label: labels[i],
                        count: counts[i],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CowStatusListScreen(
                              status: statusKeys[i],
                              title: labels[i],
                              cows: cows,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Handicapped Cow tile ─────────────────────────────────────────
              _NavTile(
                assetPath: 'assets/icons/mother_cow.png',
                label: 'Handicapped Cow',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SimpleStatusScreen(
                      title: 'Handicapped Cow',
                      status: 'handicapped',
                      showAdd: false,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Uddar Close Cow tile ──────────────────────────────────────────
              _NavTile(
                assetPath: 'assets/icons/mother_cow.png',
                label: 'Uddar Close Cow',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UddarCloseCowScreen(),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _GridLine
// ---------------------------------------------------------------------------
class _GridLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: Colors.grey.withOpacity(0.15));
  }
}

// ---------------------------------------------------------------------------
// _LegendRow – tappable row in the chart legend
// ---------------------------------------------------------------------------
class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final int count;
  final VoidCallback onTap;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: GoogleFonts.poppins(fontSize: 14)),
            ),
            Text(
              '$count',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF99AA5A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _NavTile – for Handicapped Cow / Uddar Close Cow
// ---------------------------------------------------------------------------
class _NavTile extends StatelessWidget {
  final String assetPath;
  final String label;
  final VoidCallback onTap;

  const _NavTile({
    required this.assetPath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                assetPath,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.pets, color: Colors.brown),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right,
                size: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// CowStatusListScreen
// Used for: Heifer, Pregnant, Lactating, Dry Off, Retired Cow
// ===========================================================================
class CowStatusListScreen extends StatefulWidget {
  final String status;
  final String title;
  final List<Cattle> cows;

  const CowStatusListScreen({
    super.key,
    required this.status,
    required this.title,
    required this.cows,
  });

  @override
  State<CowStatusListScreen> createState() => _CowStatusListScreenState();
}

class _CowStatusListScreenState extends State<CowStatusListScreen> {
  bool _searchOpen = false;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();
  late List<Cattle> _localCows;

  @override
  void initState() {
    super.initState();
    _localCows = widget.cows.where((c) => c.status == widget.status).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Cattle> get _filtered {
    if (_searchQuery.isEmpty) return _localCows;
    final q = _searchQuery.toLowerCase();
    return _localCows
        .where(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              c.tagNumber.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final isRetired = widget.status == 'retired';
    final allCowNames = widget.cows.map((c) => c.name).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          if (isRetired)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                height: 38,
                width: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFF99AA5A),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.file_download_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => setState(() {
                _searchOpen = !_searchOpen;
                if (!_searchOpen) {
                  _searchCtrl.clear();
                  _searchQuery = '';
                }
              }),
              child: Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: _searchOpen
                      ? Colors.grey.shade300
                      : const Color(0xFF99AA5A),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _searchOpen ? Icons.close : Icons.search,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
        bottom: _searchOpen
            ? PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6F7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            autofocus: true,
                            onChanged: (v) => setState(() => _searchQuery = v),
                            style: GoogleFonts.inter(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Search here...',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_searchOpen) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Text(
                'Total ${filtered.length} Cow',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ] else
            const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) =>
                        _CowDetailCard(cow: filtered[i], status: widget.status),
                  ),
          ),
        ],
      ),
      floatingActionButton: isRetired
          ? FloatingActionButton.extended(
              onPressed: () => _showAddRetiredSheet(context, allCowNames),
              backgroundColor: const Color(0xFF99AA5A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'Add Retired Cow',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            )
          : null,
    );
  }

  void _showAddRetiredSheet(BuildContext context, List<String> cowNames) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AddRetiredCowSheet(
        cowNames: cowNames,
        onSubmit: (name, date) {
          // In a real app, persist. For now create a mock Cattle entry.
          setState(() {
            _localCows.add(
              Cattle(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                tagNumber: '${200 + _localCows.length}',
                name: name,
                breed: 'Unknown',
                gender: 'Female',
                dateOfBirth: DateTime.now().subtract(
                  const Duration(days: 1500),
                ),
                weight: 300.0,
                status: 'retired',
                parity: 0,
                serialNumber: '00${10 + _localCows.length}',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            );
          });
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _EmptyState
// ---------------------------------------------------------------------------
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/no_data_found.png',
            width: 180,
            height: 180,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.search_off_rounded,
              size: 100,
              color: Color(0xFFB5C97A),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No data found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF8DA94D),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _CowDetailCard – matches all the mockup designs (194, 40, 41, 42, 43)
// ---------------------------------------------------------------------------
class _CowDetailCard extends StatelessWidget {
  final Cattle cow;
  final String status;

  const _CowDetailCard({required this.cow, required this.status});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM, yyyy');
    final isLactating = status == 'lactating';
    final isPregnant = status == 'pregnant';
    final isDryOff = status == 'dry';

    // Compute pregnancy age (rough: from last delivery + 9 months estimate)
    String pregnancyAge = '-';
    if (isPregnant && cow.lastDeliveryDate == null) {
      // mock: random pregnancy duration
      pregnancyAge = '1 Month, 17 Day';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top section: image + info ─────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cow image
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/icons/mother_cow.png',
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 110,
                          height: 110,
                          color: const Color(0xFFF5F5F5),
                          child: const Icon(
                            Icons.pets,
                            color: Colors.brown,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                    // Status badge on image
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(status),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _statusLabel(status),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Right side info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + Parity
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              cow.name,
                              style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            'Parity: ${cow.parity ?? 0}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9C4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_offer,
                              size: 11,
                              color: Colors.brown,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Tag No.: ${cow.tagNumber}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.brown[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'No.: ${cow.serialNumber ?? '-'}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Divider ──────────────────────────────────────────────
          const Divider(height: 1, indent: 12, endIndent: 12),

          // ── Bottom stats ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              children: [
                // Birthday + Age row
                Row(
                  children: [
                    Expanded(
                      child: _InfoCell(
                        icon: Icons.cake_outlined,
                        label: 'Birthday',
                        value: fmt.format(cow.dateOfBirth),
                        bold: true,
                      ),
                    ),
                    Expanded(
                      child: _InfoCell(
                        icon: Icons.pets,
                        label: 'Age',
                        value: cow.displayAge,
                        bold: true,
                      ),
                    ),
                  ],
                ),

                // Pregnant-specific: Pregnancy Age + Parity Milk
                if (isPregnant || isDryOff) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCell(
                          icon: Icons.pregnant_woman,
                          label: 'Pregnancy Age',
                          value: pregnancyAge,
                          bold: true,
                        ),
                      ),
                      Expanded(
                        child: _InfoCell(
                          icon: Icons.opacity,
                          label: 'Parity Milk',
                          value: '-',
                          bold: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _InfoCell(
                    icon: Icons.calendar_today,
                    label: 'Last Delivery',
                    value: cow.lastDeliveryDate != null
                        ? fmt.format(cow.lastDeliveryDate!)
                        : 'Detail not available',
                    bold: true,
                  ),
                ],

                // Lactating-specific: Parity Milk + Last Delivery
                if (isLactating) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCell(
                          icon: Icons.opacity,
                          label: 'Parity Milk',
                          value: cow.dailyMilkProduction != null
                              ? '${cow.dailyMilkProduction!.toStringAsFixed(2)} L/day'
                              : '-',
                          bold: true,
                        ),
                      ),
                      Expanded(
                        child: _InfoCell(
                          icon: Icons.calendar_today,
                          label: 'Last Delivery',
                          value: cow.lastDeliveryDate != null
                              ? fmt.format(cow.lastDeliveryDate!)
                              : 'Detail not available',
                          bold: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool bold;

  const _InfoCell({
    required this.icon,
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _AddRetiredCowSheet – bottom sheet matching iPhone 16 - 44.png
// ---------------------------------------------------------------------------
class _AddRetiredCowSheet extends StatefulWidget {
  final List<String> cowNames;
  final void Function(String name, DateTime date) onSubmit;

  const _AddRetiredCowSheet({required this.cowNames, required this.onSubmit});

  @override
  State<_AddRetiredCowSheet> createState() => _AddRetiredCowSheetState();
}

class _AddRetiredCowSheetState extends State<_AddRetiredCowSheet> {
  String? _selectedCow;
  DateTime? _selectedDate;
  bool _showSearch = false;
  String _searchQ = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<String> get _filteredNames {
    if (_searchQ.isEmpty) return widget.cowNames;
    return widget.cowNames
        .where((n) => n.toLowerCase().contains(_searchQ.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM, yyyy');

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Retired Cow',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFF99AA5A),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Name field
            Text(
              'Name',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                setState(() => _showSearch = !_showSearch);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedCow ?? 'Select cow name',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: _selectedCow == null
                              ? Colors.grey
                              : Colors.black87,
                        ),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  ],
                ),
              ),
            ),

            // Searchable dropdown list
            if (_showSearch) ...[
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Search box
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6F7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchCtrl,
                                autofocus: true,
                                onChanged: (v) => setState(() => _searchQ = v),
                                style: GoogleFonts.inter(fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'Search here...',
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    // Cow list
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView(
                        shrinkWrap: true,
                        children: _filteredNames
                            .map(
                              (name) => ListTile(
                                dense: true,
                                title: Text(
                                  name,
                                  style: GoogleFonts.poppins(fontSize: 14),
                                ),
                                onTap: () {
                                  setState(() {
                                    _selectedCow = name;
                                    _showSearch = false;
                                    _searchCtrl.clear();
                                    _searchQ = '';
                                  });
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Retired Date
            Text(
              'Retired Date',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2015),
                  lastDate: DateTime(2030),
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF99AA5A),
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: Colors.black87,
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? 'Select dry off date'
                            : dateFmt.format(_selectedDate!),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: _selectedDate == null
                              ? Colors.grey
                              : Colors.black87,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Submit
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedCow == null || _selectedDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF99AA5A),
                        content: Text(
                          'Please fill all fields',
                          style: GoogleFonts.inter(color: Colors.white),
                        ),
                      ),
                    );
                    return;
                  }
                  widget.onSubmit(_selectedCow!, _selectedDate!);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF99AA5A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: Text(
                  'Submit',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// SimpleStatusScreen – for Handicapped Cow (no data initially)
// ===========================================================================
class SimpleStatusScreen extends StatefulWidget {
  final String title;
  final String status;
  final bool showAdd;

  const SimpleStatusScreen({
    super.key,
    required this.title,
    required this.status,
    this.showAdd = false,
  });

  @override
  State<SimpleStatusScreen> createState() => _SimpleStatusScreenState();
}

class _SimpleStatusScreenState extends State<SimpleStatusScreen> {
  final List<Cattle> _cows = [];
  bool _searchOpen = false;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _searchQuery.isEmpty
        ? _cows
        : _cows
              .where(
                (c) =>
                    c.name.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
              .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => setState(() {
                _searchOpen = !_searchOpen;
                if (!_searchOpen) {
                  _searchCtrl.clear();
                  _searchQuery = '';
                }
              }),
              child: Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: _searchOpen
                      ? Colors.grey.shade300
                      : const Color(0xFF99AA5A),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _searchOpen ? Icons.close : Icons.search,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
      body: filtered.isEmpty ? _EmptyState() : const Center(),
    );
  }
}

// ===========================================================================
// UddarCloseCowScreen – with Uddar Filter dropdown
// ===========================================================================
class UddarCloseCowScreen extends StatefulWidget {
  const UddarCloseCowScreen({super.key});

  @override
  State<UddarCloseCowScreen> createState() => _UddarCloseCowScreenState();
}

class _UddarCloseCowScreenState extends State<UddarCloseCowScreen> {
  final List<Cattle> _cows = []; // starts empty – no data
  String _uddarFilter = 'All Cows';
  bool _searchOpen = false;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  final _uddarOptions = [
    'All Cows',
    '1 Uddar Close',
    '2 Uddar Close',
    '3 Uddar Close',
    '4 Uddar Close',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Cattle> get _filtered {
    if (_searchQuery.isEmpty) return _cows;
    final q = _searchQuery.toLowerCase();
    return _cows
        .where(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              c.tagNumber.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        title: Text(
          'Uddar Close Cow',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => setState(() {
                _searchOpen = !_searchOpen;
                if (!_searchOpen) {
                  _searchCtrl.clear();
                  _searchQuery = '';
                }
              }),
              child: Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: _searchOpen
                      ? Colors.grey.shade300
                      : const Color(0xFF99AA5A),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _searchOpen ? Icons.close : Icons.search,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Uddar Filter dropdown ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _uddarFilter,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
                  hint: Text(
                    'Uddar Filter',
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
                  ),
                  items: _uddarOptions
                      .map(
                        (o) => DropdownMenuItem(
                          value: o,
                          child: Text(
                            o,
                            style: GoogleFonts.inter(fontSize: 14),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _uddarFilter = v ?? 'All Cows'),
                ),
              ),
            ),
          ),

          // Search bar
          if (_searchOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        autofocus: true,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        style: GoogleFonts.inter(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search here...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Content
          Expanded(child: filtered.isEmpty ? _EmptyState() : const Center()),
        ],
      ),
    );
  }
}

// ── Status helpers ────────────────────────────────────────────────────────────
Color _statusColor(String s) {
  switch (s) {
    case 'lactating':
      return const Color(0xFF99AA5A);
    case 'pregnant':
      return Colors.blue;
    case 'dry':
      return Colors.orange;
    case 'heifer':
      return Colors.blue;
    case 'retired':
      return const Color(0xFF99AA5A);
    case 'sick':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

String _statusLabel(String s) {
  switch (s) {
    case 'lactating':
      return 'Lactating';
    case 'pregnant':
      return 'Pregnant';
    case 'dry':
      return 'Dry Off';
    case 'heifer':
      return 'Heifer';
    case 'retired':
      return 'Retired';
    case 'sick':
      return 'Sick';
    default:
      return s;
  }
}
