import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/cow_group_bloc.dart';
import '../bloc/cow_group_event.dart';
import '../bloc/cow_group_state.dart';
import '../../domain/entities/cow_group.dart';

class CowGroupScreen extends StatefulWidget {
  const CowGroupScreen({super.key});

  @override
  State<CowGroupScreen> createState() => _CowGroupScreenState();
}

class _CowGroupScreenState extends State<CowGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CowGroupBloc>().add(LoadCowGroups());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD1D5DB)),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        title: Text(
          'Cow Group',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: BlocBuilder<CowGroupBloc, CowGroupState>(
        builder: (context, state) {
          if (state is CowGroupLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CowGroupLoaded) {
            if (state.groups.isEmpty) {
              return _buildNoDataFound();
            }
            return _buildGroupList(state.groups);
          } else if (state is CowGroupError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20, right: 10),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddEditGroupDialog(),
          backgroundColor: const Color(0xFF99AA5A),
          elevation: 0,
          label: Text(
            'Add Cow Group',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          icon: const Icon(Icons.add, color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Widget _buildNoDataFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/no_data_found.png',
            width: 150,
            height: 150,
            color: const Color(0xFF99AA5A).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No data found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF99AA5A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupList(List<CowGroup> groups) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEEEEEE)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  color: Color(0xFF7CB342),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${group.cowCount} Cows',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Colors.blue,
                      size: 20,
                    ),
                    onPressed: () => _showAddEditGroupDialog(group: group),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red,
                      size: 20,
                    ),
                    onPressed: () => _showDeleteConfirmation(group),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddEditGroupDialog({CowGroup? group}) {
    _groupNameController.text = group?.name ?? '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cow Group',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF7CB342)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Cow Group Name',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                hintText: 'Enter cow group name',
                hintStyle: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_groupNameController.text.isNotEmpty) {
                    if (group == null) {
                      context.read<CowGroupBloc>().add(
                        AddCowGroup(_groupNameController.text),
                      );
                    } else {
                      context.read<CowGroupBloc>().add(
                        UpdateCowGroup(
                          group.copyWith(name: _groupNameController.text),
                        ),
                      );
                    }
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF99AA5A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Submit',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(CowGroup group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Group',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${group.name}" group?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              context.read<CowGroupBloc>().add(DeleteCowGroup(group.id));
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.inter(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
