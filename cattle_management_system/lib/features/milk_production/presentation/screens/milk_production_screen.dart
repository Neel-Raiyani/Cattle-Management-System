import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../cow_group/presentation/bloc/cow_group_bloc.dart';
import '../../../cow_group/presentation/bloc/cow_group_state.dart';
import '../../../cow_group/presentation/bloc/cow_group_event.dart';
import '../../../cattle/presentation/bloc/cattle_bloc.dart';
import '../../../cattle/presentation/bloc/cattle_state.dart';
import '../bloc/milk_production_bloc.dart';
import '../bloc/milk_production_event.dart';
import '../bloc/milk_production_state.dart';
import '../../domain/entities/milk_production_entry.dart';
import 'add_milk_entry_screen.dart';

class MilkProductionScreen extends StatefulWidget {
  const MilkProductionScreen({super.key});

  @override
  State<MilkProductionScreen> createState() => _MilkProductionScreenState();
}

class _MilkProductionScreenState extends State<MilkProductionScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedGroup = 'All';
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CowGroupBloc>().add(LoadCowGroups());
    // Normalize date to midnight to avoid hour/minute filtering issues
    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    _loadEntries();
  }

  void _loadEntries() {
    final cattleState = context.read<CattleBloc>().state;
    final cattleList = cattleState is CattleListLoaded ? cattleState.cattleList : null;
    context.read<MilkProductionBloc>().add(
      LoadMilkProductionList(date: _selectedDate, cattleList: cattleList),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        // Normalize picked date
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
      });
      _loadEntries();
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
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
            border: Border.all(color: AppTheme.primaryColor),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
          ),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search cow name...',
                  border: InputBorder.none,
                  hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
                ),
                style: GoogleFonts.poppins(fontSize: 16),
                onChanged: (v) => setState(() => _searchQuery = v),
              )
            : Text(
                'Milk Production',
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchCtrl.clear();
                }
              });
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isSearching ? Icons.close : Icons.search,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadEntries();
        },
        child: BlocBuilder<MilkProductionBloc, MilkProductionState>(
          builder: (context, state) {
            if (state is MilkProductionLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            List<MilkProductionEntry> entries = [];
            if (state is MilkProductionLoaded) {
              entries = state.entries;
            }

            // Apply search filter locally
            if (_searchQuery.isNotEmpty) {
              entries = entries
                  .where((e) => e.cattleName.toLowerCase().contains(_searchQuery.toLowerCase()))
                  .toList();
            }

            // Apply Group filter
            if (_selectedGroup != 'All') {
              final selectedGroup = _selectedGroup.trim().toLowerCase();
              entries = entries
                  .where(
                    (e) => (e.cattleGroup ?? '').trim().toLowerCase() == selectedGroup,
                  )
                  .toList();
            }

            double totalMMilk = entries.fold(0, (sum, item) => sum + item.morningMilk);
            double totalMFeed = entries.fold(0, (sum, item) => sum + item.morningFeed);
            double totalEMilk = entries.fold(0, (sum, item) => sum + item.eveningMilk);
            double totalEFeed = entries.fold(0, (sum, item) => sum + item.eveningFeed);

            if (entries.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _buildFilters(context),
                  const SizedBox(height: 100),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No entries found for this date',
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.only(bottom: 80),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _buildFilters(context),
                _buildTotalCount(entries.length),
                const SizedBox(height: 16),
                _buildTableHeader(),
                _buildSubHeader(),
                ...entries.map((entry) => _buildEntryRow(entry)),
                _buildFooter(totalMMilk, totalMFeed, totalEMilk, totalEFeed),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMilkEntryScreen()),
          );
          // Always refresh when returning from the entry screen
          _loadEntries();
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Milk Entry',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () => _selectDate(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_selectedDate.day} ${_getMonthName(_selectedDate.month)}, ${_selectedDate.year}',
                          style: GoogleFonts.inter(fontSize: 12),
                        ),
                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cow Group',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                BlocBuilder<CowGroupBloc, CowGroupState>(
                  builder: (context, state) {
                    List<String> groupNames = ['All'];
                    if (state is CowGroupLoaded) {
                      groupNames = ['All', ...state.groups.map((g) => g.name)];
                    }
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: groupNames.contains(_selectedGroup) ? _selectedGroup : 'All',
                          icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
                          isDense: true,
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.black87),
                          items: groupNames.map((String value) {
                            return DropdownMenuItem<String>(value: value, child: Text(value));
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedGroup = newValue!;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCount(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Total $count Cow',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Cow Name',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.wb_sunny, size: 12, color: Colors.white),
                ),
                Text('Morning', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.nightlight_round, size: 12, color: Colors.white),
                ),
                Text('Evening', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.grey.shade200),
          right: BorderSide(color: Colors.grey.shade200),
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          const Expanded(flex: 2, child: SizedBox()),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Icon(Icons.water_drop, size: 14, color: Colors.blue),
                Icon(Icons.grass, size: 14, color: Colors.green),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Icon(Icons.water_drop, size: 14, color: Colors.blue),
                Icon(Icons.grass, size: 14, color: Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryRow(MilkProductionEntry entry) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.grey.shade200),
          right: BorderSide(color: Colors.grey.shade200),
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              entry.cattleName,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(entry.morningMilk.toStringAsFixed(0), style: GoogleFonts.inter(fontSize: 13)),
                Text(entry.morningFeed.toStringAsFixed(1), style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(entry.eveningMilk.toStringAsFixed(0), style: GoogleFonts.inter(fontSize: 13)),
                Text(entry.eveningFeed.toStringAsFixed(1), style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(double totalMMilk, double totalMFeed, double totalEMilk, double totalEFeed) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Total',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(totalMMilk.toStringAsFixed(1), style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                Text(totalMFeed.toStringAsFixed(1), style: GoogleFonts.inter(color: Colors.white70)),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(totalEMilk.toStringAsFixed(1), style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                Text(totalEFeed.toStringAsFixed(1), style: GoogleFonts.inter(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
