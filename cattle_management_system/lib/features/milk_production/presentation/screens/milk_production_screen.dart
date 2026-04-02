import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/localized_ui.dart';
import 'package:cattle_management_system/core/widgets/no_data_found_widget.dart';
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
import '../../../../core/utils/app_feedback.dart';

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
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
      });
      _loadEntries();
    }
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
              border: Border.all(color: AppTheme.primaryColor),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor, size: 20),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '${context.ui.cowName}...',
                  border: InputBorder.none,
                  hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
                ),
                style: GoogleFonts.poppins(fontSize: 16),
                onChanged: (v) => setState(() => _searchQuery = v),
              )
            : Text(
                context.ui.milkProduction,
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
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
        onRefresh: () async { _loadEntries(); },
        child: BlocBuilder<MilkProductionBloc, MilkProductionState>(
          builder: (context, state) {
            if (state is MilkProductionLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            List<MilkProductionEntry> entries = [];
            if (state is MilkProductionLoaded) {
              entries = state.entries;
            }

            if (_searchQuery.isNotEmpty) {
              entries = entries.where((e) => e.cattleName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
            }

            if (_selectedGroup != context.ui.all) {
              final selectedGroup = _selectedGroup.trim().toLowerCase();
              entries = entries.where((e) => (e.cattleGroup ?? '').trim().toLowerCase() == selectedGroup).toList();
            }

            if (entries.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _buildFilters(context),
                  const SizedBox(height: 50),
                  const Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: NoDataFoundWidget(),
                  ),
                ],
              );
            }

            final tMMilk = entries.fold(0.0, (sum, e) => sum + e.morningMilk);
            final tMFeed = entries.fold(0.0, (sum, e) => sum + e.morningFeed);
            final tEMilk = entries.fold(0.0, (sum, e) => sum + e.eveningMilk);
            final tEFeed = entries.fold(0.0, (sum, e) => sum + e.eveningFeed);

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
                _buildFooter(tMMilk, tMFeed, tEMilk, tEFeed),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<dynamic>(context, MaterialPageRoute(builder: (context) => const AddMilkEntryScreen()));
          if (!mounted) return;
          if (result is Map && result['submitted'] == true) {
            _loadEntries();
            final msg = result['message']?.toString();
            if (msg != null && msg.isNotEmpty) await AppFeedback.showSuccess(context, msg);
          } else {
            _loadEntries();
          }
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(context.ui.addMilkEntry, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
      ),
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
                Text(context.ui.date, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () => _selectDate(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('dd MMM, yyyy').format(_selectedDate), style: GoogleFonts.inter(fontSize: 12)),
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
                Text(context.ui.cowGroup, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                BlocBuilder<CowGroupBloc, CowGroupState>(
                  builder: (context, state) {
                    List<String> groups = [context.ui.all];
                    if (state is CowGroupLoaded) groups = [context.ui.all, ...state.groups.map((g) => g.name)];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: groups.contains(_selectedGroup) ? _selectedGroup : context.ui.all,
                          icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
                          isDense: true,
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.black87),
                          items: groups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                          onChanged: (v) => setState(() => _selectedGroup = v!),
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

  Widget _buildTotalCount(int count) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: Text(context.ui.totalCowCount(count), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)));

  Widget _buildTableHeader() => Container(margin: const EdgeInsets.symmetric(horizontal: 16), padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))), child: Row(children: [Expanded(flex: 2, child: Text(context.ui.cowName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12))), Expanded(flex: 3, child: Column(children: [Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle), child: const Icon(Icons.wb_sunny, size: 12, color: Colors.white)), Text(context.ui.morning, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold))])), Expanded(flex: 3, child: Column(children: [Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle), child: const Icon(Icons.nightlight_round, size: 12, color: Colors.white)), Text(context.ui.evening, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold))]))]));

  Widget _buildSubHeader() => Container(margin: const EdgeInsets.symmetric(horizontal: 16), padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8), decoration: BoxDecoration(border: Border(left: BorderSide(color: Colors.grey.shade200), right: BorderSide(color: Colors.grey.shade200), bottom: BorderSide(color: Colors.grey.shade200))), child: Row(children: [const Expanded(flex: 2, child: SizedBox()), Expanded(flex: 3, child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: const [Icon(Icons.water_drop, size: 14, color: Colors.blue), Icon(Icons.grass, size: 14, color: Colors.green)])), Expanded(flex: 3, child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: const [Icon(Icons.water_drop, size: 14, color: Colors.blue), Icon(Icons.grass, size: 14, color: Colors.green)]))]));

  Widget _buildEntryRow(MilkProductionEntry entry) => Container(margin: const EdgeInsets.symmetric(horizontal: 16), padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), decoration: BoxDecoration(border: Border(left: BorderSide(color: Colors.grey.shade200), right: BorderSide(color: Colors.grey.shade200), bottom: BorderSide(color: Colors.grey.shade200))), child: Row(children: [Expanded(flex: 2, child: Text(entry.cattleName, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13))), Expanded(flex: 3, child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Text(entry.morningMilk.toStringAsFixed(0), style: GoogleFonts.inter(fontSize: 13)), Text(entry.morningFeed.toStringAsFixed(1), style: GoogleFonts.inter(fontSize: 13, color: Colors.grey))])), Expanded(flex: 3, child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Text(entry.eveningMilk.toStringAsFixed(0), style: GoogleFonts.inter(fontSize: 13)), Text(entry.eveningFeed.toStringAsFixed(1), style: GoogleFonts.inter(fontSize: 13, color: Colors.grey))]))]));

  Widget _buildFooter(double tMM, double tMF, double tEM, double tEF) => Container(margin: const EdgeInsets.symmetric(horizontal: 16), padding: const EdgeInsets.all(12), decoration: const BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12))), child: Row(children: [Expanded(flex: 2, child: Text(context.ui.total, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white))), Expanded(flex: 3, child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Text(tMM.toStringAsFixed(1), style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)), Text(tMF.toStringAsFixed(1), style: GoogleFonts.inter(color: Colors.white70))])), Expanded(flex: 3, child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Text(tEM.toStringAsFixed(1), style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)), Text(tEF.toStringAsFixed(1), style: GoogleFonts.inter(color: Colors.white70))]))]));
}
