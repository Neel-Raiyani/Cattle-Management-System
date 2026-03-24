import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../features/cattle/domain/entities/cattle.dart';
import '../../../../features/cattle/presentation/bloc/cattle_bloc.dart';
import '../../../../features/cattle/presentation/bloc/cattle_event.dart';
import '../../../../features/cattle/presentation/bloc/cattle_state.dart';
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
        if (state is CattleUpdated) {
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
              child: const Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
          title: Text(
            'Death',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF99AA5A),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search, color: Colors.white, size: 20),
            ),
          ],
        ),
        body: BlocBuilder<CattleBloc, CattleState>(
          builder: (context, state) {
            if (state is CattleLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            List<Cattle> deathRecords = [];
            if (state is CattleListLoaded) {
              deathRecords = state.cattleList
                  .where(
                    (c) => c.status.toUpperCase() == 'DEAD',
                  )
                  .toList();
            }

            if (deathRecords.isEmpty) {
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
                      'No data found',
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

            deathRecords.sort((a, b) {
              final aDate = a.deathDate ?? a.updatedAt;
              final bDate = b.deathDate ?? b.updatedAt;
              return bDate.compareTo(aDate);
            });

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Total ${deathRecords.length} death record${deathRecords.length == 1 ? '' : 's'}',
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
                    itemBuilder: (ctx, i) {
                      final r = deathRecords[i];
                      return _DeathRecordCard(cattle: r);
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
                MaterialPageRoute(builder: (_) => const AddDeathRecordScreen()),
              );
              if (result == true) {
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
                    'Add Death Record',
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
                child: cattle.imageUrl != null && cattle.imageUrl!.isNotEmpty
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
                    : Image.asset(
                        'assets/icons/no_data_found.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
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
                      'Reason: ${cattle.deathReason ?? '-'}',
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
                    : '-',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
