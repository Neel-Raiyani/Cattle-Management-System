import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditDonationRecordScreen extends StatefulWidget {
  final Map<String, dynamic> record;
  const EditDonationRecordScreen({super.key, required this.record});

  @override
  State<EditDonationRecordScreen> createState() =>
      _EditDonationRecordScreenState();
}

class _EditDonationRecordScreenState extends State<EditDonationRecordScreen> {
  late TextEditingController _gaushalaNameCtrl;
  late TextEditingController _mobileCtrl;
  late TextEditingController _refCtrl;

  @override
  void initState() {
    super.initState();
    _gaushalaNameCtrl = TextEditingController(
      text: widget.record['gaushalaName'],
    );
    _mobileCtrl = TextEditingController(text: widget.record['mobileNo']);
    _refCtrl = TextEditingController(text: widget.record['referenceBy']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          ),
        ),
        title: Text(
          'Edit Donation Record',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FieldLabel(label: 'Name'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.record['tagNo'] ?? '',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _FieldLabel(label: 'Gaushala Name'),
            const SizedBox(height: 8),
            _CustomTextField(
              hint: 'Enter gaushala name',
              controller: _gaushalaNameCtrl,
            ),
            const SizedBox(height: 20),

            _FieldLabel(label: 'Mobile No.'),
            const SizedBox(height: 8),
            _CustomTextField(
              hint: 'Enter mobile number',
              controller: _mobileCtrl,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),

            _FieldLabel(label: 'Reference By'),
            const SizedBox(height: 8),
            _CustomTextField(
              hint: 'Enter reference name',
              controller: _refCtrl,
            ),
            const SizedBox(height: 20),

            _FieldLabel(label: 'Photo at Time of Donation'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  const Icon(Icons.cloud_upload, color: Colors.grey, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Select Photo',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF99AA5A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Select Photo',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF99AA5A),
                  foregroundColor: Colors.white,
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
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const _CustomTextField({
    required this.hint,
    required this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 14),
      decoration: InputDecoration(
        fillColor: const Color(0xFFF5F6F7),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
