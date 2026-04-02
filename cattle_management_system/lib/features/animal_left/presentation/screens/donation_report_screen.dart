import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../features/cattle/domain/entities/cattle.dart';
import '../../../../features/cattle/presentation/bloc/cattle_bloc.dart';
import '../../../../features/cattle/presentation/bloc/cattle_event.dart';
import '../../../../features/cattle/presentation/bloc/cattle_state.dart';
import '../../../../core/localization/localized_ui.dart';
import '../../../../core/services/app_feedback_service.dart';
import 'package:cattle_management_system/core/widgets/no_data_found_widget.dart';
import 'add_donation_record_screen.dart';

class DonationReportScreen extends StatefulWidget {
  const DonationReportScreen({super.key});

  @override
  State<DonationReportScreen> createState() => _DonationReportScreenState();
}

class _DonationReportScreenState extends State<DonationReportScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<CattleBloc>().add(const LoadCattleList());
  }

  List<Cattle> _filterDonatedAnimals(List<Cattle> cattleList) {
    final donated = cattleList
        .where((cattle) => cattle.status.toUpperCase() == 'DONATED')
        .toList();
    donated.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return donated;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CattleBloc, CattleState>(
      listener: (context, state) {
        if (state is CattleUpdated ||
            state is CattleAdded ||
            state is CattleDeleted) {
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
            context.ui.donation,
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
            final donatedAnimals = _filterDonatedAnimals(cattleList);

            if (donatedAnimals.isEmpty) {
              return const NoDataFoundWidget();
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${context.ui.total}: ${donatedAnimals.length}',
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
                    itemCount: donatedAnimals.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      return _DonationRecordCard(cattle: donatedAnimals[i]);
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
                MaterialPageRoute(builder: (_) => const AddDonationRecordScreen()),
              );
              if (result == true && mounted) {
                _loadData();
                Future.microtask(() {
                  AppFeedbackService.showPopup(
                    message: 'Donation record added successfully',
                    type: AppFeedbackType.success,
                  );
                });
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
                    'Add Donation Record',
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

class _DonationRecordCard extends StatelessWidget {
  final Cattle cattle;

  const _DonationRecordCard({required this.cattle});

  @override
  Widget build(BuildContext context) {
    final donatedDate = DateFormat('dd MMM, yyyy').format(cattle.updatedAt);
        
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
                child: Image(
                  image: imageProvider,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 56,
                    height: 56,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.pets, color: Colors.grey),
                  ),
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
                    const SizedBox(height: 4),
                    Text(
                      'Tag: ${cattle.tagNumber.isNotEmpty ? cattle.tagNumber : '-'}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'No.: ${cattle.serialNumber?.isNotEmpty == true ? cattle.serialNumber : '-'}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
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
                  cattle.gender.toUpperCase().startsWith('F') ? 'Cow' : 'Bull',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Donated on',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
              ),
              Text(
                donatedDate,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
