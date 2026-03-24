import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/cattle.dart';
import '../bloc/cattle_bloc.dart';
import '../bloc/cattle_event.dart';
import '../bloc/cattle_state.dart';
import 'add_cattle_screen.dart';
import 'cow_details_screen.dart';

class CattleListScreen extends StatefulWidget {
  final String? initialFilter;
  const CattleListScreen({super.key, this.initialFilter});

  @override
  State<CattleListScreen> createState() => _CattleListScreenState();
}

class _CattleListScreenState extends State<CattleListScreen> {
  String? _selectedFilter;
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
    if (widget.initialFilter != null) {
      // Will be reconciled once filterOptions is built in build()
      _selectedFilter = widget.initialFilter;
    }
    context.read<CattleBloc>().add(const LoadCattleList());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Map of mock status to localized filters
    // Note: In a real app, use Enums or keys. For now mapping strings.
    final List<String> filterOptions = [
      l10n.lblAllCows,
      l10n.lblLactating,
      l10n.lblHeifer,
      l10n.lblPregnant,
      l10n.lblDryOff,
      l10n.lblRetiredCow,
    ];

    // If an initialFilter was provided (English key from dashboard), map it to the localized label.
    if (_selectedFilter != null && !filterOptions.contains(_selectedFilter)) {
      final filter = _selectedFilter!.toLowerCase();
      if (filter == 'lactating') {
        _selectedFilter = l10n.lblLactating;
      } else if (filter == 'heifer') {
        _selectedFilter = l10n.lblHeifer;
      } else if (filter.contains('calv') || filter == 'pregnant') {
        _selectedFilter = l10n.lblPregnant;
      } else if (filter.contains('dry')) {
        _selectedFilter = l10n.lblDryOff;
      } else {
        _selectedFilter = filterOptions[0];
      }
    }

    // Ensure valid selection on language change or init
    if (_selectedFilter == null || !filterOptions.contains(_selectedFilter)) {
      _selectedFilter = filterOptions[0];
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildCustomAppBar(context),
      body: Column(
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
                  items: filterOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
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
              builder: (context, state) {
                if (state is CattleLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CattleListLoaded) {
                  // Filter Logic
                  final filteredList = _filterCattle(state.cattleList, l10n);

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
                            l10n.lblTotalCow(filteredList.length),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
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
                            // Inject "Add New Button" after some items or at bottom?
                            // Design shows it as a button below a card.
                            // For now, I'll add it as the last item or a FAB.
                            // But design implies it might be interspersed.
                            // I'll stick to a FAB or bottom bar as implemented previously or add it to the list end.
                            // Let's implement card first.
                            return _CustomCattleCard(
                              cattle: filteredList[index],
                            );
                          },
                        ),
                      ),
                    ],
                  );
                } else if (state is CattleEmpty) {
                  return Center(child: Text(state.message));
                } else if (state is CattleError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(color: Colors.black87),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<CattleBloc>().add(const LoadCattleList(forceRefresh: true));
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text("Retry Connection"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFA4C639),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCattleScreen()),
          );
        },
        backgroundColor: const Color(0xFFA4C639),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          l10n.btnAddNewCow,
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
                hintText: 'Search cattle...', // Could localize this too
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                hintStyle: GoogleFonts.poppins(color: Colors.grey),
              ),
              style: GoogleFonts.poppins(color: Colors.black),
              onChanged: (value) {
                // Implement Local Search or trigger Bloc Event
                context.read<CattleBloc>().add(SearchCattle(value));
              },
            )
          : Text(
              AppLocalizations.of(context)!.titleCowList,
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
                  Icons.description,
                  const Color(0xFFA4C639),
                  () => _showFileMenu(context),
                ),
                const SizedBox(width: 8),
              ],
              _buildActionIcon(
                _isSearching ? Icons.close : Icons.search,
                const Color(0xFFA4C639),
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  void _showFileMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.file_open, color: Color(0xFFA4C639)),
            title: Text(l10n.menuOpen),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.share, color: Colors.black),
            title: Text(l10n.menuShare),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  List<Cattle> _filterCattle(List<Cattle> cattleList, AppLocalizations l10n) {
    final visibleCows = cattleList.where((cattle) {
      final isFemale = cattle.gender.toUpperCase().startsWith('F') ||
          cattle.gender.toLowerCase() == 'cow';
      return isFemale;
    }).toList();

    final activeCows = visibleCows.where((cattle) {
      return !_isTerminalStatus(cattle.status) && cattle.isRetired != true;
    }).toList();

    final retiredCows = visibleCows.where((cattle) {
      return cattle.isRetired == true;
    }).toList();

    if (_selectedFilter == l10n.lblAllCows) {
      return activeCows;
    }
    // Mapping logic: UI Filter String -> Data Status String
    // Assuming backend status matches english keys somewhat lowercased or exact.
    // In a real app, use Enums.
    // Here we'll match based on the text.
    String statusToMatch = '';
    if (_selectedFilter == l10n.lblLactating) statusToMatch = 'Lactating';
    if (_selectedFilter == l10n.lblHeifer) statusToMatch = 'Heifer';
    if (_selectedFilter == l10n.lblPregnant) statusToMatch = 'Pregnant';
    if (_selectedFilter == l10n.lblDryOff) statusToMatch = 'Dry Off';
    if (_selectedFilter == l10n.lblRetiredCow) statusToMatch = 'Retired';

    if (_selectedFilter == l10n.lblRetiredCow) {
      return retiredCows;
    }

    return activeCows
        .where((c) => c.status.toLowerCase() == statusToMatch.toLowerCase())
        .toList();
  }
}

class _CustomCattleCard extends StatelessWidget {
  final Cattle cattle;

  const _CustomCattleCard({required this.cattle});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLactating = cattle.status == 'Lactating';
    final isHeifer = cattle.status == 'Heifer';
    // Logic for other statuses

    Color statusColor = Colors.orange;
    Color statusBg = Colors.white; // Fixed background as requested
    if (isHeifer) {
      statusColor = Colors.blue;
      // statusBg remains white
    }
    // Add other colors maps preferred
    if (cattle.status == 'Pregnant') statusColor = Colors.green;
    if (cattle.status == 'Dry Off') statusColor = Colors.grey;
    if (cattle.status == 'Retired') statusColor = Colors.red;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CowDetailsScreen(cattle: cattle),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image & Status Pill
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
                                  'assets/icons/mother_cow.png',
                                ),
                                fit: BoxFit.contain,
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: Text(
                          _getLocalizedStatus(cattle.status, l10n),
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

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            cattle.name,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${l10n.lblParity}: ${cattle.parity ?? 0}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF9C4), // Yellowish
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.local_offer,
                                  size: 12,
                                  color: Colors.brown,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${l10n.lblTagNo} : ${cattle.tagNumber}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.brown[800],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${l10n.lblNo} : ${cattle.serialNumber ?? "0000"}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
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

            const Divider(height: 24),

            // Info Rows
            Row(
              children: [
                _buildInfoColumn(
                  l10n.lblBirthday,
                  DateFormat('dd MMM, yyyy').format(cattle.dateOfBirth),
                  Icons.cake,
                  context,
                ),
                const SizedBox(width: 24),
                _buildInfoColumn(
                  l10n.lblAge,
                  cattle.displayAge,
                  Icons.pets,
                  context,
                ), // Icons.pets as placeholder
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (isLactating)
                  _buildInfoColumn(
                    l10n.lblParityMilk,
                    '${cattle.dailyMilkProduction ?? 0} ${l10n.unitLPerDay}',
                    Icons.opacity,
                    context,
                  ),
                if (isLactating) const SizedBox(width: 24),
                if (isLactating)
                  _buildInfoColumn(
                    l10n.lblLastDelivery,
                    cattle.lastDeliveryDate != null
                        ? DateFormat(
                            'dd MMM, yyyy',
                          ).format(cattle.lastDeliveryDate!)
                        : '-',
                    Icons.calendar_today,
                    context,
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F8E9), // Light Green
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.edit_outlined,
                        color: const Color(0xFFA4C639),
                        size: 18,
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
                              "Delete Cow",
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
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE), // Light Red
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 18,
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

  Widget _buildInfoColumn(
    String label,
    String value,
    IconData icon,
    BuildContext context,
  ) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: Colors.grey),
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
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getLocalizedStatus(String status, AppLocalizations l10n) {
    switch (status.toLowerCase()) {
      case 'lactating':
        return l10n.lblLactating;
      case 'heifer':
        return l10n.lblHeifer;
      case 'pregnant':
        return l10n.lblPregnant;
      case 'dry off':
        return l10n.lblDryOff;
      case 'retired':
        return l10n.lblRetiredCow;
      default:
        return status;
    }
  }
}
