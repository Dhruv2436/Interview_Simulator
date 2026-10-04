import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'mcq_test_screen.dart';
import '../models/candidate_model.dart';

class InstructionsScreen extends StatelessWidget {
  final String role;
  final int mcqQuestions;
  final int interviewQuestions;
  final ResumeData? resumeData;
  
  const InstructionsScreen({
    super.key, 
    required this.role,
    required this.mcqQuestions,
    required this.interviewQuestions,
    this.resumeData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1423),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1423),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: const Text(
                  'Before we begin',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeInDown(
                delay: const Duration(milliseconds: 100),
                child: Text(
                  'Please allow the required permissions for best experience.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: _buildPermissionItem(Icons.mic, 'Microphone', 'Required for voice answers', true),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: _buildPermissionItem(Icons.camera_alt, 'Camera (Optional)', 'Used for better evaluation', true),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: _buildPermissionItem(Icons.volume_up, 'Speaker', 'Enable to hear questions', true),
              ),

              const SizedBox(height: 16),

              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B42FA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF5B42FA).withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF5B42FA)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'A quiet environment is recommended for accurate evaluation.',
                          style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: SizedBox(
                   width: double.infinity,
                   height: 56,
                   child: ElevatedButton(
                     onPressed: () {
                       // Push to MCQ Test
                       Navigator.push(
                         context,
                         MaterialPageRoute(
                           builder: (context) => MCQTestScreen(
                             candidateProfile: {
                               'numTechnical': interviewQuestions,
                               'skills': resumeData?.skills ?? [],
                               'projects': resumeData?.projects ?? [],
                               'name': resumeData?.name,
                             },
                             technicalDomain: role,
                             numAptitude: mcqQuestions ~/ 2,
                             numTechnical: mcqQuestions - (mcqQuestions ~/ 2),
                           ),
                         ),
                       );
                     },
                     style: ElevatedButton.styleFrom(
                       backgroundColor: const Color(0xFF5B42FA),
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(16),
                       ),
                       elevation: 0,
                     ),
                     child: const Text(
                       'Start Interview',
                       style: TextStyle(
                         fontSize: 16,
                         fontWeight: FontWeight.bold,
                         color: Colors.white,
                       ),
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

  Widget _buildPermissionItem(IconData icon, String title, String subtitle, bool isGranted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (isGranted)
            const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 24),
        ],
      ),
    );
  }
}
