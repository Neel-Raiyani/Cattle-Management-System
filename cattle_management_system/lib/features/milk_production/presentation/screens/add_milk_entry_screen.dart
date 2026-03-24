import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/datasources/feed_local_data_source.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/error/exceptions.dart';
import '../../../cow_group/presentation/bloc/cow_group_bloc.dart';
import '../../../cow_group/presentation/bloc/cow_group_state.dart';
import '../../../cow_group/presentation/bloc/cow_group_event.dart';
import '../../../cattle/presentation/bloc/cattle_bloc.dart';
import '../../../cattle/presentation/bloc/cattle_state.dart';
import '../../../milk_production/presentation/bloc/milk_production_bloc.dart';
import '../../../milk_production/presentation/bloc/milk_production_event.dart';

class AddMilkEntryScreen extends StatefulWidget {
  const AddMilkEntryScreen({super.key});

  @override
  State<AddMilkEntryScreen> createState() => _AddMilkEntryScreenState();
}

class _AddMilkEntryScreenState extends State<AddMilkEntryScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedGroup;
  bool _isMorning = true; // Toggle state
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _cowEntries = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    context.read<CowGroupBloc>().add(LoadCowGroups());
    // Normalize date to midnight to match production list fetching
    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    final state = context.read<CattleBloc>().state;
    if (state is CattleListLoaded) {
      _cowEntries = state.cattleList
          .where(
            (c) =>
        c.gender.toUpperCase().startsWith('F') &&
            c.status.toUpperCase() == 'ACTIVE',
      )
          .map(
            (c) => {
          'id': c.tagNumber,
          'animalId': c.id,
          'name': c.name,
          'milk': '',
          'feed': '',
        },
      )
          .toList();
    }
  }

  // Helper method to pick date
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primaryColor),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
          ),
        ),
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search cow name...',
            hintStyle: GoogleFonts.inter(
              color: Colors.grey,
              fontSize: 14,
            ),
            border: InputBorder.none,
          ),
          style: GoogleFonts.poppins(fontSize: 16),
          onChanged: (val) {
            setState(() {
              _searchQuery = val.toLowerCase();
            });
          },
        )
            : Text(
          'Add Milk Entry',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        actions: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Date Picker ───
                  InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('dd MMM, yyyy').format(_selectedDate),
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: Colors.black87,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cow Group Dropdown
                  Text(
                    'Cow Group',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  BlocBuilder<CowGroupBloc, CowGroupState>(
                    builder: (context, state) {
                      List<String> groupNames = [];
                      if (state is CowGroupLoaded) {
                        groupNames = state.groups.map((g) => g.name).toList();
                      }
                      return DropdownButtonFormField<String>(
                        value: _selectedGroup,
                        hint: Text(
                          'Select cow group',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        icon: const Icon(Icons.keyboard_arrow_down),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        items: groupNames
                            .map(
                              (g) => DropdownMenuItem(value: g, child: Text(g)),
                        )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedGroup = val),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Toggle
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isMorning = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isMorning
                                    ? AppTheme.primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.wb_sunny,
                                    color:
                                    _isMorning ? Colors.white : Colors.grey,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Morning',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: _isMorning
                                          ? Colors.white
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isMorning = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isMorning
                                    ? AppTheme.primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,

                                children: [
                                  Icon(
                                    Icons.nightlight_round,
                                    color: !_isMorning
                                        ? Colors.white
                                        : Colors.grey,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Evening',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: !_isMorning
                                          ? Colors.white
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: Text(
                            'Gr No.',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Cow Name',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(
                          width: 60,
                          child: Center(
                            child: Icon(
                              Icons.water_drop,
                              size: 16,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const SizedBox(
                          width: 60,
                          child: Center(
                            child: Icon(
                              Icons.grass,
                              size: 16,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // List Entries
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _getFilteredEntries().length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = _getFilteredEntries()[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(color: Colors.grey.shade200),
                            right: BorderSide(color: Colors.grey.shade200),
                            bottom: index == _cowEntries.length - 1
                                ? BorderSide(color: Colors.grey.shade200)
                                : BorderSide.none,
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40,
                              child: Text(
                                item['id'],
                                style: GoogleFonts.inter(fontSize: 12),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'],
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    DateFormat('MMM d').format(_selectedDate),
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 60,
                              height: 40,
                              child: TextFormField(
                                initialValue: item['milk'],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                ),
                                style: GoogleFonts.inter(fontSize: 14),
                                onChanged: (val) {
                                  setState(() {
                                    item['milk'] = val;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 60,
                              height: 40,
                              child: TextFormField(
                                initialValue: item['feed'],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  hintText: 'Kg',
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    item['feed'] = val;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // Submit Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () async {
                  setState(() => _isSubmitting = true);
                  try {
                    double totalFeedUsed = 0;
                    final List<Map<String, dynamic>> entries = [];

                    for (var entry in _cowEntries) {
                      final feedVal =
                          double.tryParse(entry['feed'] ?? '0') ?? 0;
                      totalFeedUsed += feedVal;
                    }

                    double currentStock = 0;
                    try {
                      final response = await sl<ApiService>().getFeedInventory();
                      
                      if (response is Map<String, dynamic>) {
                        dynamic dataObj = response.containsKey('data') ? response['data'] : response;
                        if (dataObj is Map<String, dynamic>) {
                          if (dataObj.containsKey('inventory')) {
                            final inv = dataObj['inventory'] as Map<String, dynamic>;
                            currentStock = (inv['totalQuantity'] as num? ?? inv['quantity'] as num?)?.toDouble() ?? 0.0;
                          } else {
                            currentStock = (dataObj['totalQuantity'] as num? ?? dataObj['quantity'] as num?)?.toDouble() ?? 0.0;
                          }
                        } else if (dataObj is List) {
                          for (var item in dataObj) {
                            if (item is Map) {
                              currentStock += (item['totalQuantity'] as num? ?? item['quantity'] as num?)?.toDouble() ?? 0.0;
                            }
                          }
                        }
                      } else if (response is List) {
                        for (var item in response) {
                          if (item is Map) {
                            currentStock += (item['totalQuantity'] as num? ?? item['quantity'] as num?)?.toDouble() ?? 0.0;
                          }
                        }
                      }
                      
                      await sl<FeedLocalDataSource>().updateFeedStock(currentStock);
                    } catch (e) {
                      currentStock = await sl<FeedLocalDataSource>().getFeedStock();
                    }
                    if (totalFeedUsed > currentStock) {
                      throw Exception(
                          'Insufficient feed inventory. Required: ${totalFeedUsed.toInt()} Kg, Available: ${currentStock.toInt()} Kg');
                    }

                    for (var entry in _cowEntries) {
                      final milkVal =
                          double.tryParse(entry['milk'] ?? '0') ?? 0;
                      final feedVal =
                          double.tryParse(entry['feed'] ?? '0') ?? 0;

                      if ((milkVal > 0 || feedVal > 0) &&
                          entry['animalId'] != null) {
                        entries.add({
                          'animalId': entry['animalId'],
                          'quantity': milkVal.toDouble(),
                          'feedQuantity': feedVal.toDouble(),
                        });
                      }
                    }

                    if (entries.isNotEmpty) {
                      await sl<ApiService>().logBulkMilkYields(
                        date:
                        _selectedDate.toIso8601String().split('T')[0],
                        session: _isMorning ? 'MORNING' : 'EVENING',
                        entries: entries,
                      );

                      await sl<FeedLocalDataSource>()
                          .deductFeedStock(totalFeedUsed);

                      // CRITICAL: Refresh the MilkProductionBloc with the normalized date
                      if (context.mounted) {
                        context.read<MilkProductionBloc>().add(
                            LoadMilkProductionList(date: _selectedDate, cattleList: [])
                        );
                      }
                    }

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Entries submitted. ${totalFeedUsed.toInt()} Kg feed deducted.',
                          ),
                          backgroundColor: AppTheme.primaryColor,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  } on ServerException catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.message)),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e
                              .toString()
                              .replaceAll('Exception:', '')),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _isSubmitting = false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text(
                  'Submit',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredEntries() {
    if (_searchQuery.isEmpty) return _cowEntries;
    return _cowEntries.where((item) {
      final name = (item['name'] as String).toLowerCase();
      final id = (item['id'] as String).toLowerCase();
      return name.contains(_searchQuery) || id.contains(_searchQuery);
    }).toList();
  }
}