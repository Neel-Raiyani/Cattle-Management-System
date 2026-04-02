import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../features/cattle/domain/entities/cattle.dart';
import '../../../../features/cattle/presentation/bloc/cattle_bloc.dart';
import '../../../../features/cattle/presentation/bloc/cattle_event.dart';
import '../../../../features/cattle/presentation/bloc/cattle_state.dart';
import '../../../../core/localization/localized_ui.dart';
import 'package:cattle_management_system/core/widgets/no_data_found_widget.dart';
import 'add_sell_record_screen.dart';

class SellReportScreen extends StatefulWidget {
  const SellReportScreen({super.key});

  @override
  State<SellReportScreen> createState() => _SellReportScreenState();
}

class _SellReportScreenState extends State<SellReportScreen> {
  DateTime _fromDate = DateTime(DateTime.now().year, 1, 1);
  DateTime _toDate = DateTime(DateTime.now().year, 12, 31);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<CattleBloc>().add(const LoadCattleList());
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF99AA5A),
            onPrimary: Colors.white,
            onSurface: Colors.black87,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _fromDate = picked;
        if (_toDate.isBefore(_fromDate)) _toDate = _fromDate;
      });
    }
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate,
      firstDate: _fromDate,
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF99AA5A),
            onPrimary: Colors.white,
            onSurface: Colors.black87,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _toDate = picked);
    }
  }

  List<Cattle> _filterSoldAnimals(List<Cattle> cattleList) {
    return cattleList.where((cattle) {
      if (cattle.status.toUpperCase() != 'SOLD') return false;
      final soldDate = cattle.updatedAt;
      return !soldDate.isBefore(_fromDate) && !soldDate.isAfter(_toDate);
    }).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CattleBloc, CattleState>(
      listener: (context, state) {
        if (state is CattleUpdated || state is CattleAdded || state is CattleDeleted) {
          _loadData();
        }
      },
      child: Scaffold(
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
            context.ui.sell,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: BlocBuilder<CattleBloc, CattleState>(
          builder: (context, state) {
            if (state is CattleLoading && state is! CattleListLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            final cattleList = state is CattleListLoaded ? state.cattleList : <Cattle>[];
            final soldAnimals = _filterSoldAnimals(cattleList);

            return Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _DateFilterChip(
                              value: DateFormat('dd-MM-yyyy').format(_fromDate),
                              onTap: _pickFromDate,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'to',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ),
                          Expanded(
                            child: _DateFilterChip(
                              value: DateFormat('dd-MM-yyyy').format(_toDate),
                              onTap: _pickToDate,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${context.ui.total}: ${soldAnimals.length}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: soldAnimals.isEmpty
                      ? const NoDataFoundWidget()
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: soldAnimals.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (ctx, i) {
                            return _SellRecordCard(cattle: soldAnimals[i]);
                          },
                        ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: FloatingActionButton.extended(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddSellRecordScreen()),
              );
              if (result == true) _loadData();
            },
            backgroundColor: const Color(0xFF99AA5A),
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              'Add Sell Record',
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

class _DateFilterChip extends StatelessWidget {
  final String value;
  final VoidCallback onTap;

  const _DateFilterChip({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5F6F7),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Icon(
                Icons.calendar_month_rounded,
                size: 16,
                color: Color(0xFF99AA5A),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SellRecordCard extends StatelessWidget {
  final Cattle cattle;

  const _SellRecordCard({required this.cattle});

  @override
  Widget build(BuildContext context) {
    final soldDate = DateFormat('dd MMM, yyyy').format(cattle.updatedAt);
    final imageProvider = (cattle.imageUrl != null && cattle.imageUrl!.isNotEmpty)
        ? NetworkImage(cattle.imageUrl!)
        : const AssetImage('assets/icons/father_cow.png') as ImageProvider;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: (cattle.imageUrl != null && cattle.imageUrl!.isNotEmpty)
                    ? Image(
                        image: imageProvider,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.pets, color: Colors.grey),
                        ),
                      )
                    : Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.pets, color: Colors.grey),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cattle.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cattle.gender.toUpperCase().startsWith('F') ? 'Cow' : 'Bull',
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'SOLD',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: const Color(0xFF4C7A27),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tag: ${cattle.tagNumber}',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
              ),
              Text(
                soldDate,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
