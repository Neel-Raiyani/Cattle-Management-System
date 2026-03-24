import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:cattle_management_system/features/cattle/presentation/bloc/cattle_bloc.dart';
import 'package:cattle_management_system/features/cattle/presentation/bloc/cattle_state.dart';
import 'package:cattle_management_system/features/cattle/domain/entities/cattle.dart';

class CowChildListScreen extends StatelessWidget {
  final Cattle parentCattle;

  const CowChildListScreen({super.key, required this.parentCattle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      appBar: AppBar(
        title: Text(
          'Child',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F6F7),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: BlocBuilder<CattleBloc, CattleState>(
        builder: (context, state) {
          if (state is CattleLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CattleListLoaded) {
            // Filter all animals to find offspring of the parent cattle
            // A child has motherId matching parent's id, or motherName matching parent's name
            final List<Cattle> children = (state.cattleList).where((c) {
              final matchById = parentCattle.id.isNotEmpty &&
                  c.motherId != null && c.motherId == parentCattle.id;
              final matchByName = parentCattle.name.isNotEmpty &&
                  c.motherName != null &&
                  c.motherName!.toLowerCase() == parentCattle.name.toLowerCase();
              return matchById || matchByName;
            }).toList();

            if (children.isEmpty) {
              return Center(
                child: Text(
                  'No offspring found for ${parentCattle.name}',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: children.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildChildCard(children[index]);
              },
            );
          }

          if (state is CattleEmpty) {
            return Center(child: Text(state.message));
          }

          if (state is CattleError) {
            return Center(child: Text(state.message));
          }

          return const Center(child: Text('No data found'));
        },
      ),
    );
  }

  Widget _buildChildCard(Cattle child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section with Badge
              SizedBox(
                height: 120,
                width: 110,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 110,
                      width: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: (child.imageUrl != null && child.imageUrl!.isNotEmpty)
                              ? NetworkImage(child.imageUrl!)
                              : const AssetImage('assets/icons/mother_cow.png') as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8EAF6),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF3F51B5),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            child.status,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF3F51B5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Info Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF59D),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.sell,
                                  size: 14,
                                  color: Colors.brown,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'Tag No : ${child.tagNumber}',
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.brown,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'No. : ${child.serialNumber ?? "-"}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 12),

          // Bottom Section
          Row(
            children: [
              const Icon(Icons.cake, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Birthday',
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                  ),
                  Text(
                    DateFormat('dd MMM, yyyy').format(child.dateOfBirth),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
