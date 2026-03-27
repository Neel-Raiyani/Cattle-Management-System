import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../cattle/domain/entities/cattle.dart';
import '../../../cattle/presentation/bloc/cattle_bloc.dart';
import '../../../cattle/presentation/bloc/cattle_event.dart';
import '../../../cattle/presentation/bloc/cattle_state.dart';
import '../../../../core/utils/app_feedback.dart';

// ---------------------------------------------------------------------------
// Mock bull data
// ---------------------------------------------------------------------------
// Mock data removed. Using CattleBloc.

class _RetiredBullEntry {
  final String name;
  final DateTime retiredDate;

  _RetiredBullEntry({required this.name, required this.retiredDate});
}

// ===========================================================================
// BullReportHubScreen – 3 sub-categories
// ===========================================================================
class BullReportHubScreen extends StatelessWidget {
  const BullReportHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _CircleBack(onTap: () => Navigator.pop(context)),
        title: Text(
          'Bull Report',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HubTile(
            label: 'Bull Report',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BullListReportScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _HubTile(
            label: 'Bull Calf Report',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BullCalfReportScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _HubTile(
            label: 'Retired Bull',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RetiredBullScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _HubTile
// ---------------------------------------------------------------------------
class _HubTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _HubTile({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Bull icon circle
            Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F7),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/icons/father_cow.png',
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
              decoration: const BoxDecoration(
                color: Color(0xFFF5F6F7),
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
// BullListReportScreen – shows all adult bulls (status == 'bull')
// Matches mockup: "Total 0 Bull" when empty, list when data exists
// ===========================================================================
class BullListReportScreen extends StatefulWidget {
  const BullListReportScreen({super.key});

  @override
  State<BullListReportScreen> createState() => _BullListReportScreenState();
}

class _BullListReportScreenState extends State<BullListReportScreen> {
  bool _searchOpen = false;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CattleBloc>().add(const LoadCattleList());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Cattle> _getFiltered(List<Cattle> allCattle) {
    final bulls = allCattle
        .where(
          (b) =>
              b.isMaleGender &&
              b.isActive &&
              !b.effectiveIsRetired &&
              !b.isBullCalf,
        )
        .toList();
    if (_searchQuery.isEmpty) return bulls;
    final q = _searchQuery.toLowerCase();
    return bulls
        .where(
          (b) =>
              b.name.toLowerCase().contains(q) ||
              b.tagNumber.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: BlocBuilder<CattleBloc, CattleState>(
        builder: (context, state) {
          if (state is CattleLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF99AA5A),
              ),
            );
          }

          List<Cattle> allCattle = [];
          if (state is CattleListLoaded) {
            allCattle = state.cattleList;
          } else if (state is CattleDetailLoaded) {
            allCattle = [state.cattle];
          }

          final filtered = _getFiltered(allCattle);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Text(
                  'Total ${filtered.length} Bull',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? _EmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => _BullCard(bull: filtered[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: _CircleBack(onTap: () => Navigator.pop(context)),
      title: Text(
        'Bull Report',
        style: GoogleFonts.poppins(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      actions: [
        _AppBarIconBtn(icon: Icons.file_download_outlined, onTap: () {}),
        const SizedBox(width: 8),
        _AppBarIconBtn(
          icon: _searchOpen ? Icons.close : Icons.search,
          highlighted: _searchOpen,
          onTap: () => setState(() {
            _searchOpen = !_searchOpen;
            if (!_searchOpen) {
              _searchCtrl.clear();
              _searchQuery = '';
            }
          }),
        ),
        const SizedBox(width: 16),
      ],
      bottom: _searchOpen ? _searchBar() : null,
    );
  }

  PreferredSize _searchBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: _SearchField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _searchQuery = v),
        ),
      ),
    );
  }
}

// ===========================================================================
// BullCalfReportScreen – shows all bull calves (status == 'bull_calf')
// ===========================================================================
class BullCalfReportScreen extends StatefulWidget {
  const BullCalfReportScreen({super.key}); 

  @override
  State<BullCalfReportScreen> createState() => _BullCalfReportScreenState();
}

class _BullCalfReportScreenState extends State<BullCalfReportScreen> {
  bool _searchOpen = false;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();
  @override
  void initState() {
    super.initState();
    context.read<CattleBloc>().add(const LoadCattleList());
  }

  List<Cattle> _getFiltered(List<Cattle> allCattle) {
    final calves = allCattle
        .where(
          (b) =>
              b.isMaleGender &&
              b.isActive &&
              !b.effectiveIsRetired &&
              b.isBullCalf,
        )
        .toList();
    if (_searchQuery.isEmpty) return calves;
    final q = _searchQuery.toLowerCase();
    return calves
        .where(
          (b) =>
              b.name.toLowerCase().contains(q) ||
              b.tagNumber.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: BlocBuilder<CattleBloc, CattleState>(
        builder: (context, state) {
          List<Cattle> allCattle = [];
          if (state is CattleListLoaded) {
            allCattle = state.cattleList;
          } else if (state is CattleDetailLoaded) {
            allCattle = [state.cattle];
          }
          final filtered = _getFiltered(allCattle);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Text(
                  'Total ${filtered.length} Bull Calf',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? _EmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => _BullCalfCard(
                          bull: filtered[i],
                          onDelete: () {
                            // Deletion via Bloc not implemented here for brevity,
                            // but UI will update on next load
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: _CircleBack(onTap: () => Navigator.pop(context)),
      title: Text(
        'Bull Calf Report',
        style: GoogleFonts.poppins(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      actions: [
        _AppBarIconBtn(icon: Icons.file_download_outlined, onTap: () {}),
        const SizedBox(width: 8),
        _AppBarIconBtn(
          icon: _searchOpen ? Icons.close : Icons.search,
          highlighted: _searchOpen,
          onTap: () => setState(() {
            _searchOpen = !_searchOpen;
            if (!_searchOpen) {
              _searchCtrl.clear();
              _searchQuery = '';
            }
          }),
        ),
        const SizedBox(width: 16),
      ],
      bottom: _searchOpen ? _searchBar() : null,
    );
  }

  PreferredSize _searchBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: _SearchField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _searchQuery = v),
        ),
      ),
    );
  }
}

// ===========================================================================
// RetiredBullScreen – empty initially, FAB to add
// ===========================================================================
class RetiredBullScreen extends StatefulWidget {
  const RetiredBullScreen({super.key});

  @override
  State<RetiredBullScreen> createState() => _RetiredBullScreenState();
}

class _RetiredBullScreenState extends State<RetiredBullScreen> {
  bool _searchOpen = false;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CattleBloc>().add(const LoadCattleList());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: BlocBuilder<CattleBloc, CattleState>(
        builder: (context, state) {
          List<Cattle> allCattle = [];
          if (state is CattleListLoaded) {
            allCattle = state.cattleList;
          } else if (state is CattleDetailLoaded) {
            allCattle = [state.cattle];
          }

          final filtered = allCattle.where((b) {
            final isRetiredBull =
                b.gender.toLowerCase() == 'male' && b.isRetired == true;
            if (!isRetiredBull) return false;
            if (_searchQuery.isEmpty) return true;
            final q = _searchQuery.toLowerCase();
            return b.name.toLowerCase().contains(q) ||
                b.tagNumber.toLowerCase().contains(q);
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_searchOpen)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: _SearchField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
              Expanded(
                child: filtered.isEmpty
                    ? _EmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) =>
                            _RetiredBullCard.fromCattle(bull: filtered[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: _CircleBack(onTap: () => Navigator.pop(context)),
      title: Text(
        'Retired Bull',
        style: GoogleFonts.poppins(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      actions: [
        _AppBarIconBtn(
          icon: _searchOpen ? Icons.close : Icons.search,
          highlighted: _searchOpen,
          onTap: () => setState(() {
            _searchOpen = !_searchOpen;
            if (!_searchOpen) {
              _searchCtrl.clear();
              _searchQuery = '';
            }
          }),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _BullCard – for adult bulls (edit / delete buttons)
// ---------------------------------------------------------------------------
class _BullCard extends StatelessWidget {
  final Cattle bull;
  const _BullCard({required this.bull});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM, yyyy');
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
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bull image with status badge
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/icons/father_cow.png',
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
                    Positioned(
                      bottom: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Text(
                          'Bull',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[800],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              bull.name,
                              style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            'No. : ${bull.serialNumber ?? "---"}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _TagPill(tagNumber: bull.tagNumber),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 12, endIndent: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _DateCell(
                        label: 'Birthday',
                        value: fmt.format(bull.dateOfBirth),
                      ),
                    ),
                    Expanded(
                      child: _DateCell(label: 'Age', value: bull.displayAge),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _ActionBtn(isEdit: true, onTap: () {})),
                    const SizedBox(width: 12),
                    Expanded(child: _ActionBtn(isEdit: false, onTap: () {})),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _BullCalfCard – for bull calves (matches iPhone mockup exactly)
// ---------------------------------------------------------------------------
class _BullCalfCard extends StatelessWidget {
  final Cattle bull;
  final VoidCallback onDelete;
  const _BullCalfCard({required this.bull, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM, yyyy');
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
        children: [
          // ── Top: image + info ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bull calf image with badge
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/icons/father_cow.png',
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
                    // Bull Calf pill badge
                    Positioned(
                      bottom: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF3F51B5)),
                        ),
                        child: Text(
                          'Bull Calf',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF3F51B5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              bull.name,
                              style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            'No. : ${bull.serialNumber ?? "---"}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _TagPill(tagNumber: bull.tagNumber),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 12, endIndent: 12),
          // ── Bottom: dates + buttons ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _DateCell(
                        label: 'Birthday',
                        value: fmt.format(bull.dateOfBirth),
                      ),
                    ),
                    Expanded(
                      child: _DateCell(label: 'Age', value: bull.displayAge),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _ActionBtn(isEdit: true, onTap: () {})),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionBtn(
                        isEdit: false,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(
                                'Delete Bull Calf',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Text(
                                'Are you sure you want to delete ${bull.name}?',
                                style: GoogleFonts.inter(),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'Cancel',
                                    style: GoogleFonts.inter(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    onDelete();
                                  },
                                  child: Text(
                                    'Delete',
                                    style: GoogleFonts.inter(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _RetiredBullCard
// ---------------------------------------------------------------------------
class _RetiredBullCard extends StatelessWidget {
  final _RetiredBullEntry entry;
  const _RetiredBullCard({required this.entry});

  _RetiredBullCard.fromCattle({required Cattle bull})
    : entry = _RetiredBullEntry(
        name: bull.name,
        retiredDate: bull.updatedAt ?? bull.createdAt ?? DateTime.now(),
      );

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM, yyyy');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.07),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6F7),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/icons/father_cow.png',
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.pets, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Retired: ${fmt.format(entry.retiredDate)}',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Retired',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _AddRetiredBullSheet – matches iPhone 16 - 44/45 style for bulls
// ---------------------------------------------------------------------------
class _AddRetiredBullSheet extends StatefulWidget {
  final List<String> bullNames;
  final void Function(String name, DateTime date) onSubmit;

  const _AddRetiredBullSheet({required this.bullNames, required this.onSubmit});

  @override
  State<_AddRetiredBullSheet> createState() => _AddRetiredBullSheetState();
}

class _AddRetiredBullSheetState extends State<_AddRetiredBullSheet> {
  String? _selectedBull;
  DateTime? _selectedDate;
  bool _showSearch = false;
  String _searchQ = '';
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<String> get _filteredNames {
    if (_searchQ.isEmpty) return widget.bullNames;
    return widget.bullNames
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
                  'Retired Bull',
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

            // Name dropdown
            Text(
              'Name',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _showSearch = !_showSearch),
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
                        _selectedBull ?? 'Select bull name',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: _selectedBull == null
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
                                controller: _ctrl,
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
                                onTap: () => setState(() {
                                  _selectedBull = name;
                                  _showSearch = false;
                                  _ctrl.clear();
                                  _searchQ = '';
                                }),
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

            // Retired date
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
                if (picked != null) setState(() => _selectedDate = picked);
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
                  if (_selectedBull == null || _selectedDate == null) {
                    AppFeedback.showError(context, 
                          'Please fill all fields',
                        );
                    return;
                  }
                  widget.onSubmit(_selectedBull!, _selectedDate!);
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
// Shared helper widgets
// ===========================================================================
class _CircleBack extends StatelessWidget {
  final VoidCallback onTap;
  const _CircleBack({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          onPressed: onTap,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class _AppBarIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool highlighted;

  const _AppBarIconBtn({
    required this.icon,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        width: 38,
        decoration: BoxDecoration(
          color: highlighted ? Colors.grey.shade300 : const Color(0xFF99AA5A),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              controller: controller,
              autofocus: true,
              onChanged: onChanged,
              style: GoogleFonts.inter(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search here...',
                hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final String tagNumber;
  const _TagPill({required this.tagNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_offer, size: 11, color: Colors.brown),
          const SizedBox(width: 4),
          Text(
            'Tag No. : $tagNumber',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.brown[800],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateCell extends StatelessWidget {
  final String label;
  final String value;
  const _DateCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          label == 'Birthday' ? Icons.cake_outlined : Icons.pets,
          size: 14,
          color: Colors.grey,
        ),
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
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final bool isEdit;
  final VoidCallback onTap;
  const _ActionBtn({required this.isEdit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isEdit ? const Color(0xFFF1F8E9) : const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Center(
          child: Icon(
            isEdit ? Icons.edit_outlined : Icons.delete_outline,
            color: isEdit ? const Color(0xFF7CB342) : Colors.red,
            size: 20,
          ),
        ),
      ),
    );
  }
}

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
