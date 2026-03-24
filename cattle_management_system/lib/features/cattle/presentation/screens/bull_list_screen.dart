import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cattle_management_system/core/localization/app_text.dart';
import '../../domain/entities/cattle.dart';
import '../bloc/cattle_bloc.dart';
import '../bloc/cattle_event.dart';
import '../bloc/cattle_state.dart';
import 'add_bull_screen.dart';
import 'bull_details_screen.dart';
import 'edit_bull_details_screen.dart';

class BullListScreen extends StatefulWidget {
  const BullListScreen({super.key});

  @override
  State<BullListScreen> createState() => _BullListScreenState();
}

class _BullListScreenState extends State<BullListScreen> {
  String _selectedFilter = 'all_bull';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  bool _isTerminalStatus(String status) {
    final normalized = status.toUpperCase();
    return normalized == 'SOLD' ||
        normalized == 'DEAD' ||
        normalized == 'DONATED';
  }

  @override
  void initState() {
    super.initState();
    // Refresh list to ensure we have latest data
    context.read<CattleBloc>().add(const LoadCattleList());
  }

  @override
  Widget build(BuildContext context) {
    final filterOptions = <MapEntry<String, String>>[
      MapEntry('all_bull', context.tr.allBull),
      MapEntry('bull', context.tr.bull),
      MapEntry('bull_calf', context.tr.bullCalf),
      MapEntry('retired_bull', context.tr.retiredBull),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildCustomAppBar(context),
      body: BlocListener<CattleBloc, CattleState>(
        listener: (context, state) {
          if (state is CattleAdded ||
              state is CattleDeleted ||
              state is CattleUpdated) {
            // Refresh the list when an animal is added, deleted, or updated
            context.read<CattleBloc>().add(const LoadCattleList());
          }
        },
        child: Column(
          children: [
            // Filter Dropdown
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedFilter,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey,
                    ),
                    items: filterOptions.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(
                          entry.value,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _selectedFilter == entry.key
                                ? const Color(
                                    0xff99AA5A,
                                  ) // Active color approximation
                                : Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedFilter = newValue!;
                      });
                    },
                  ),
                ),
              ),
            ),

            Expanded(
              child: BlocBuilder<CattleBloc, CattleState>(
                buildWhen: (previous, current) =>
                    current is CattleListLoaded ||
                    current is CattleLoading ||
                    current is CattleEmpty ||
                    current is CattleError,
                builder: (context, state) {
                  if (state is CattleLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is CattleListLoaded) {
                    // Filter Logic for Bulls
                    final filteredList = _filterBulls(state.cattleList);

                    return Column(
                      children: [
                        // Total Count
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              context.tr.totalBullCount(filteredList.length),
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),

                        // List
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              return _BullCard(cattle: filteredList[index]);
                            },
                          ),
                        ),
                      ],
                    );
                  } else if (state is CattleEmpty) {
                    return Center(child: Text(state.message));
                  } else if (state is CattleError) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigation to Add Bull Screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBullScreen()),
          );
        },
        backgroundColor: const Color(0xff99AA5A),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          context.tr.addNewBull,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
    return AppBar(
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
                filled: true,
                fillColor: const Color(0xFFF5F6F7),
                hintText: context.tr.searchSomething,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                hintStyle: GoogleFonts.poppins(color: Colors.grey),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
              style: GoogleFonts.poppins(color: Colors.black),
              onChanged: (value) {
                // Implement Local Search or trigger Bloc Event
                context.read<CattleBloc>().add(SearchCattle(value));
              },
            )
          : Text(
              context.tr.bull,
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
      centerTitle: false,
      backgroundColor: Colors.white,
      elevation: 0,
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              if (!_isSearching) ...[
                _buildActionIcon(
                  Icons.description, // Approximation for Excel/File icon
                  const Color(0xff99AA5A),
                  () => _showFileMenu(context),
                ),
                const SizedBox(width: 12),
              ],
              _buildActionIcon(
                _isSearching ? Icons.close : Icons.search,
                const Color(0xff99AA5A),
                () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                      context.read<CattleBloc>().add(
                        const LoadCattleList(),
                      ); // Reset search
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  void _showFileMenu(BuildContext context) {
    // Show PopupMenuButton styled menu as per screenshot
    // Replicating the dropdown menu style
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        100,
        80,
        20,
        0,
      ), // Adjust position roughly to top right
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      items: [
        PopupMenuItem(
          value: 'Open',
          child: Row(
            children: [
              Icon(Icons.description, size: 18, color: Color(0xff99AA5A)),
              SizedBox(width: 8),
              Text(context.tr.open, style: GoogleFonts.poppins(fontSize: 14)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'Share',
          child: Row(
            children: [
              Icon(Icons.share, size: 18, color: Colors.black),
              SizedBox(width: 8),
              Text(context.tr.share, style: GoogleFonts.poppins(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  List<Cattle> _filterBulls(List<Cattle> cattleList) {
    // Basic filter: Male cattle
    final males = cattleList.where((c) {
      return c.gender.toUpperCase().startsWith('M') &&
          !_isTerminalStatus(c.status);
    }).toList();

    if (_selectedFilter == 'all_bull') {
      // Show all males except those specifically excluded (if any)
      return males;
    }

    if (_selectedFilter == 'retired_bull') {
      return males.where((c) => c.isRetired == true).toList();
    }

    if (_selectedFilter == 'bull_calf') {
      // Usually check age or specific group
      return males.where((c) => 
        c.cowGroup?.toLowerCase() == 'calf' || 
        c.ageInMonths < 12 // fallback
      ).toList();
    }

    if (_selectedFilter == 'bull') {
      // Active, non-calf bulls
      return males.where((c) => 
        c.isRetired != true && 
        c.cowGroup?.toLowerCase() != 'calf' &&
        c.ageInMonths >= 12
      ).toList();
    }

    return males;
  }
}

class _BullCard extends StatelessWidget {
  final Cattle cattle;

  const _BullCard({required this.cattle});

  @override
  Widget build(BuildContext context) {
    Color statusColor = const Color(0xFF5E35B1); // Deep Purple (Bull Calf)
    Color statusBg = const Color(0xFFEDE7F6); // Light Purple
    Color statusBorder = const Color(0xFF5E35B1);

    // Filter Logic for pill colors
    // Bull Calf: Purple (from screenshot)
    // Retired Bull: Maybe Grey/Red?
    // Bull: Maybe Orange/Green?
    // Using screenshot colors:
    // Bull Calf (Image 2) has Blue text, White Bg, Blue border.

    if (cattle.status == 'Bull Calf') {
      statusColor = Color(0xFF3F51B5);
      statusBg = Colors.white;
      statusBorder = Color(0xFF3F51B5);
    } else if (cattle.status == 'Retired Bull') {
      statusColor = Colors.grey;
      statusBg = Colors.white;
      statusBorder = Colors.grey;
    } else {
      // Standard Bull
      statusColor = Colors.orange;
      statusBg = Colors.white;
      statusBorder = Colors.orange;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BullDetailsScreen(cattle: cattle),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image:
                            (cattle.imageUrl != null &&
                                cattle.imageUrl!.isNotEmpty)
                            ? DecorationImage(
                                image: NetworkImage(cattle.imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : const DecorationImage(
                                image: AssetImage(
                                  'assets/icons/father_cow.png',
                                ),
                                fit: BoxFit.contain, // or cover
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusBorder),
                        ),
                        child: Text(
                          cattle.status,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              cattle.name,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'No. : ${cattle.serialNumber ?? "1001"}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Tag Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9C4), // Yellowish
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.sell,
                              size: 14,
                              color: Colors.brown[800],
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Tag No : ${cattle.tagNumber}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown[800],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 16),

            // Dates
            Row(
              children: [
                _buildDateInfo(
                  'Birthday',
                  DateFormat('dd MMM, yyyy').format(cattle.dateOfBirth),
                  Icons.cake,
                ),
                const SizedBox(width: 24),
                _buildDateInfo(
                  'Age',
                  cattle.displayAge,
                  Icons.pets,
                ), // Pets icon as placeholder for bull icon
              ],
            ),

            const SizedBox(height: 16),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditBullDetailsScreen(cattle: cattle),
                        ),
                      );
                    },
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F8E9), // Light Green
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.edit_outlined,
                          color: const Color(0xFFA4C639), // Green
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              "Delete Bull",
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
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text(
                                  "Delete",
                                  style: GoogleFonts.inter(color: Colors.red),
                                ),
                                onPressed: () {
                                  context.read<CattleBloc>().add(
                                    DeleteCattle(cattle.id),
                                  );
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE), // Light Red
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateInfo(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
