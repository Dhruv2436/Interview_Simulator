import 'package:flutter/material.dart';
import '../models/candidate_model.dart';

class AutoFillFormDialog extends StatefulWidget {
  final ResumeData initialData;
  final Function(ResumeData) onConfirmed;

  const AutoFillFormDialog({
    super.key,
    required this.initialData,
    required this.onConfirmed,
  });

  @override
  State<AutoFillFormDialog> createState() => _AutoFillFormDialogState();
}

class _AutoFillFormDialogState extends State<AutoFillFormDialog> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _collegeCtrl;
  late TextEditingController _skillsCtrl;
  late TextEditingController _experienceCtrl;
  late TextEditingController _projectsCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialData.name);
    _emailCtrl = TextEditingController(text: widget.initialData.email);
    _phoneCtrl = TextEditingController(text: widget.initialData.phone);
    _collegeCtrl = TextEditingController(text: widget.initialData.college);
    _skillsCtrl = TextEditingController(text: widget.initialData.skills.join(', '));
    _experienceCtrl = TextEditingController(text: widget.initialData.experienceLevel);
    _projectsCtrl = TextEditingController(text: widget.initialData.projects.join(', '));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _collegeCtrl.dispose();
    _skillsCtrl.dispose();
    _experienceCtrl.dispose();
    _projectsCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final updated = ResumeData(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      college: _collegeCtrl.text.trim(),
      experienceLevel: _experienceCtrl.text.trim(),
      skills: _skillsCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
      projects: _projectsCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
      experience: [_experienceCtrl.text.trim()],
      technologies: _skillsCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
      certifications: widget.initialData.certifications,
    );
    widget.onConfirmed(updated);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 450, maxHeight: 680),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Extracted Information', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 2),
                    Text("We've extracted the following details", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                children: [
                  _buildField('Full Name', _nameCtrl),
                  _buildField('Email', _emailCtrl),
                  _buildField('Phone', _phoneCtrl),
                  _buildField('College', _collegeCtrl),
                  _buildField('Skills', _skillsCtrl),
                  _buildField('Experience', _experienceCtrl),
                  _buildField('Projects', _projectsCtrl),
                ],
              ),
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Confirm & Continue', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.black87, fontSize: 13),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF10B981))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
