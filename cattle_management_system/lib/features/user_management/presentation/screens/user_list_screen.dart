import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/di/injection_container.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Valid roles as per the backend (Swagger: UserGaushala.role enum)
// ─────────────────────────────────────────────────────────────────────────────
const List<String> kStaffRoles = ['OWNER', 'MANAGER', 'STAFF', 'VETERINARIAN'];

// ─────────────────────────────────────────────────────────────────────────────
// User List Screen
// ─────────────────────────────────────────────────────────────────────────────
class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<Map<String, dynamic>> _staff = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchStaff();
  }

  Future<void> _fetchStaff() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final list = await sl<ApiService>().getAllStaff();
      if (mounted) {
        setState(() {
          _staff = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.titleUserList,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF99AA5A)),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF99AA5A), size: 20),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF99AA5A)),
            onPressed: _fetchStaff,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddUserScreen()),
          );
          if (added == true && mounted) {
            _fetchStaff(); // always refresh from API after adding
          }
        },
        backgroundColor: const Color(0xFF99AA5A),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add User',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF99AA5A)));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchStaff,
                icon: const Icon(Icons.refresh),
                label: Text('Retry', style: GoogleFonts.poppins()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF99AA5A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_staff.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/no_data_found.png',
              width: 150,
              height: 150,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.people_outline, size: 80, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noDataFound,
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap "Add User" to add staff members.',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Text(
            'Total: ${_staff.length}',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _staff.length,
            itemBuilder: (context, index) {
              return _StaffCard(
                staff: _staff[index],
                onRefresh: _fetchStaff,
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Staff Card
// ─────────────────────────────────────────────────────────────────────────────
class _StaffCard extends StatelessWidget {
  final Map<String, dynamic> staff;
  final VoidCallback onRefresh;

  const _StaffCard({required this.staff, required this.onRefresh});

  Color _roleColor(String role) {
    switch (role.toUpperCase()) {
      case 'OWNER':        return const Color(0xFF6A1B9A);
      case 'MANAGER':      return const Color(0xFF1565C0);
      case 'VETERINARIAN': return const Color(0xFF2E7D32);
      default:             return const Color(0xFF546E7A);
    }
  }

  Color _roleBg(String role) {
    switch (role.toUpperCase()) {
      case 'OWNER':        return const Color(0xFFF3E5F5);
      case 'MANAGER':      return const Color(0xFFE3F2FD);
      case 'VETERINARIAN': return const Color(0xFFE8F5E9);
      default:             return const Color(0xFFECEFF1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = staff['role'] as String? ?? '';
    final name = staff['name'] as String? ?? '-';
    final phone = staff['mobileNumber'] as String? ?? '-';
    final city = staff['city'] as String? ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _roleBg(role),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.person, size: 32, color: _roleColor(role)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        phone.isEmpty ? '—' : phone,
                        style: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
                      ),
                      if (city.isNotEmpty && city != '-')
                        Text(
                          city,
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade400),
                        ),
                    ],
                  ),
                ),
                // Role badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _roleBg(role),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role.isEmpty ? '—' : role,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _roleColor(role),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add User Screen — calls POST /api/auth/staff
// ─────────────────────────────────────────────────────────────────────────────
class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  String? _selectedRole;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      await sl<ApiService>().addStaff(
        mobileNumber: _phoneController.text.trim(),
        name: _nameController.text.trim(),
        role: _selectedRole!,
        city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Staff member added successfully!'),
            backgroundColor: Color(0xFF99AA5A),
          ),
        );
        Navigator.pop(context, true); // return true → trigger refresh
      }
    } on ServerException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.titleAddUser,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF99AA5A)),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF99AA5A), size: 20),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar placeholder
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 32),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.person, size: 60, color: Color(0xFFABB5BE)),
                ),
              ),

              _buildLabel('Name *'),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Enter full name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('Mobile Number *'),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration('Enter 10-digit mobile number'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Mobile number is required';
                  if (v.trim().length < 10) return 'Enter a valid mobile number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildLabel('Role *'),
                  DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<String>(
                    padding: EdgeInsets.all(12),
                    value: _selectedRole,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    dropdownColor: Color(0xFFF5F5F5),
                    hint: Text(
                      'Select role',
                      style: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
                    ),
                    items: kStaffRoles.map((role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(role, style: GoogleFonts.inter(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedRole = v),
                    validator: (v) => v == null ? 'Please select a role' : null,
                  ),
                ),
              const SizedBox(height: 16),

              _buildLabel('City (optional)'),
              TextFormField(
                controller: _cityController,
                decoration: _inputDecoration('Enter city'),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF99AA5A),
                    disabledBackgroundColor: const Color(0xFF99AA5A).withOpacity(0.6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context)!.submit,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Colors.black87,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF99AA5A), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
    );
  }
}
