import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../features/cattle/domain/entities/cattle.dart';
import '../../../../features/cattle/presentation/bloc/cattle_bloc.dart';
import '../../../../features/cattle/presentation/bloc/cattle_event.dart';
import '../../../../features/cattle/presentation/bloc/cattle_state.dart';
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
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
            ),
          ),
          title: Text(
            'Sell',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: BlocBuilder<CattleBloc, CattleState>(
          builder: (context, state) {
            if (state is CattleLoading) {
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
                          'Total ${soldAnimals.length} sold animal${soldAnimals.length == 1 ? '' : 's'}',
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
                      ? _NoDataView(message: 'No sold animals found')
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
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: InkWell(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddSellRecordScreen()),
              );
              if (result == true && mounted) {
                _loadData();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF99AA5A),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF99AA5A).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Add Sell Record',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
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

class _NoDataView extends StatelessWidget {
  final String message;

  const _NoDataView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/no_data_found.png',
            width: 200,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.search_off,
              size: 100,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF99AA5A),
            ),
          ),
        ],
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
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
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
