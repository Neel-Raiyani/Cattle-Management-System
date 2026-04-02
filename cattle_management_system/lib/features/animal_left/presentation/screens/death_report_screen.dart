import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../features/cattle/domain/entities/cattle.dart';
import '../../../../features/cattle/presentation/bloc/cattle_bloc.dart';
import '../../../../features/cattle/presentation/bloc/cattle_event.dart';
import '../../../../features/cattle/presentation/bloc/cattle_state.dart';
import '../../../../core/localization/localized_ui.dart';
import 'package:cattle_management_system/core/widgets/no_data_found_widget.dart';
import 'add_death_record_screen.dart';

class DeathReportScreen extends StatefulWidget {
  const DeathReportScreen({super.key});

  @override
  State<DeathReportScreen> createState() => _DeathReportScreenState();
}

class _DeathReportScreenState extends State<DeathReportScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<CattleBloc>().add(const LoadCattleList());
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
            context.ui.death,
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

            List<Cattle> deathRecords = [];
            if (state is CattleListLoaded) {
              deathRecords = state.cattleList
                  .where((c) => c.status.toUpperCase() == 'DEAD')
                  .toList();
                  
              deathRecords.sort((a, b) {
                final aDate = a.deathDate ?? a.updatedAt;
                final bDate = b.deathDate ?? b.updatedAt;
                return bDate.compareTo(aDate);
              });
            }

            if (deathRecords.isEmpty) {
              return const NoDataFoundWidget();
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${context.ui.total}: ${deathRecords.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: deathRecords.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) => _DeathRecordCard(cattle: deathRecords[i]),
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
                MaterialPageRoute(builder: (_) => const AddDeathRecordScreen()),
              );
              if (result == true) _loadData();
            },
            backgroundColor: const Color(0xFF99AA5A),
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              'Add Death Record',
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

class _DeathRecordCard extends StatelessWidget {
  final Cattle cattle;
  const _DeathRecordCard({required this.cattle});

  @override
  Widget build(BuildContext context) {
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
                    ? Image.network(
                        cattle.imageUrl!,
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
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Reason: ${cattle.deathReason ?? '-'}',
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                    ),
                  ],
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
                cattle.deathDate != null
                    ? DateFormat('dd MMM, yyyy').format(cattle.deathDate!)
                    : DateFormat('dd MMM, yyyy').format(cattle.updatedAt),
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
