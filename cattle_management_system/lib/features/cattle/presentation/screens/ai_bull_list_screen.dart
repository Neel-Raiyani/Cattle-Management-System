import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cattle_management_system/core/localization/app_text.dart';
import '../../domain/entities/cattle.dart';
import '../bloc/cattle_bloc.dart';
import '../bloc/cattle_event.dart';
import '../bloc/cattle_state.dart';
import 'add_ai_bull_screen.dart';
import 'edit_ai_bull_screen.dart'; // We will create this

class AiBullListScreen extends StatefulWidget {
  const AiBullListScreen({super.key});

  @override
  State<AiBullListScreen> createState() => _AiBullListScreenState();
}

class _AiBullListScreenState extends State<AiBullListScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

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
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: context.tr.searchByNameOrTag,
                  hintStyle: GoogleFonts.inter(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                ),
                style: GoogleFonts.poppins(fontSize: 16),
                onChanged: (val) {
                  context.read<CattleBloc>().add(SearchCattle(val));
                },
              )
            : Text(
                'AI ${context.tr.bull}',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                    context.read<CattleBloc>().add(
                      const LoadCattleList(forceRefresh: true),
                    );
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xff99AA5A),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isSearching ? Icons.close : Icons.search,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<CattleBloc, CattleState>(
        builder: (context, state) {
          if (state is CattleLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CattleListLoaded) {
            // Filter for AI Bulls
            final aiBulls = state.cattleList
                .where(
                  (c) =>
                      c.isMaleGender &&
                      c.isActive &&
                      c.normalizedBullView == 'AI',
                )
                .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    context.tr.totalBullCount(aiBulls.length),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: aiBulls.length,
                    itemBuilder: (context, index) {
                      return _AiBullCard(cattle: aiBulls[index]);
                    },
                  ),
                ),
              ],
            );
          } else if (state is CattleEmpty) {
            return Center(child: Text(state.message));
          } else if (state is CattleError) {
            // If error, maybe list is empty or actually error
            return Center(
              child: Text(
                state.message.contains('No cattle')
                    ? 'No AI Bulls found'
                    : state.message,
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: SizedBox(
          height: 48,
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddAiBullScreen(),
                ),
              );
            },
            backgroundColor: const Color(0xff99AA5A), // Olive Green
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              'Add AI Bull',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AiBullCard extends StatelessWidget {
  final Cattle cattle;

  const _AiBullCard({required this.cattle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                  image:
                      (cattle.imageUrl != null && cattle.imageUrl!.isNotEmpty)
                      ? DecorationImage(
                          image: NetworkImage(cattle.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : const DecorationImage(
                          image: AssetImage('assets/icons/father_cow.png'),
                          // Using father_cow.png as placeholder for Bull,
                          // though image uses a simpler cow silhouette.
                          // Sticking to consistent asset for now.
                          fit: BoxFit.contain,
                        ),
                ),
              ),
              const SizedBox(width: 16),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cattle.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Tag No Pill
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF9C4), // Light Yellow
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.local_offer,
                                  size: 10,
                                  color: Colors.brown,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'Tag No. : ${cattle.tagNumber}',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.brown[800],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            'No. : ${cattle.serialNumber ?? "-"}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
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
          const Divider(height: 1),
          const SizedBox(height: 12),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => EditAiBullScreen(cattle: cattle),
                      ),
                    );
                  },
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F8E9), // Light Green
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: Color(0xFFA4C639),
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    final blocContext = context;
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: Text(
                            "Delete AI Bull",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            "Are you sure you want to delete ${cattle.name}?",
                            style: GoogleFonts.inter(),
                          ),
                          actions: [
                            TextButton(
                              child: Text(
                                "Cancel",
                                style: GoogleFonts.inter(color: Colors.grey),
                              ),
                              onPressed: () => Navigator.pop(dialogContext),
                            ),
                            TextButton(
                              child: Text(
                                "Delete",
                                style: GoogleFonts.inter(color: Colors.red),
                              ),
                              onPressed: () {
                                Navigator.pop(dialogContext);
                                Future.microtask(() {
                                  if (!blocContext.mounted) return;
                                  blocContext.read<CattleBloc>().add(
                                    DeleteCattle(cattle.id),
                                  );
                                });
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE), // Light Red
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
