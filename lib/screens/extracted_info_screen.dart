import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'interview_setup_screen.dart';
import '../models/candidate_model.dart';

class ExtractedInfoScreen extends StatelessWidget {
  final String role;
  final ResumeData resumeData;
  final ATSAnalysisResult analysis;

  const ExtractedInfoScreen({
    super.key,
    required this.role,
    required this.resumeData,
    required this.analysis,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: const Text(
                  'We\'ve extracted information\nfrom your resume',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeInDown(
                delay: const Duration(milliseconds: 100),
                child: const Text(
                  'Please review and confirm your extracted info',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),
              FadeInUp(delay: const Duration(milliseconds: 200), child: _buildInfoField(Icons.person_outline, 'Full Name', resumeData.name.isNotEmpty ? resumeData.name : 'Not extracted')),
              FadeInUp(delay: const Duration(milliseconds: 250), child: _buildInfoField(Icons.email_outlined, 'Email', resumeData.email.isNotEmpty ? resumeData.email : 'Not extracted')),
              FadeInUp(delay: const Duration(milliseconds: 300), child: _buildInfoField(Icons.phone_outlined, 'Phone', resumeData.phone.isNotEmpty ? resumeData.phone : 'Not extracted')),
              FadeInUp(delay: const Duration(milliseconds: 350), child: _buildInfoField(Icons.integration_instructions_outlined, 'Skills', resumeData.skills.isNotEmpty ? resumeData.skills.join(', ') : 'Not extracted')),
              FadeInUp(delay: const Duration(milliseconds: 400), child: _buildInfoField(Icons.school_outlined, 'Education', resumeData.college.isNotEmpty ? resumeData.college : 'Not extracted')),
              FadeInUp(delay: const Duration(milliseconds: 450), child: _buildInfoField(Icons.work_outline, 'Experience', resumeData.experienceLevel.isNotEmpty ? resumeData.experienceLevel : (resumeData.experience.isNotEmpty ? resumeData.experience.first : 'Not extracted'))),
              FadeInUp(delay: const Duration(milliseconds: 500), child: _buildInfoField(Icons.folder_outlined, 'Projects', resumeData.projects.isNotEmpty ? resumeData.projects.map((p) => '• $p').join('\n') : 'Not extracted')),
              FadeInUp(delay: const Duration(milliseconds: 540), child: _buildInfoField(Icons.work_history_outlined, 'Target Role', role)),
              const SizedBox(height: 24),
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => InterviewSetupScreen(role: role, resumeData: resumeData)));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B42FA),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Confirm & Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoField(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
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
