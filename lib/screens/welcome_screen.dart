import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'role_selection_screen.dart';
import 'question_paper_solver_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // ── Top Welcome Header ──
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: const Text(
                  'Welcome 👋',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E1B4B),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              FadeInDown(
                delay: const Duration(milliseconds: 100),
                duration: const Duration(milliseconds: 500),
                child: const Text(
                  'Your go-to platform for smart interview\n& exam paper preparation.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF64748B),
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Illustration Banner ──
              FadeInUp(
                delay: const Duration(milliseconds: 150),
                duration: const Duration(milliseconds: 600),
                child: Center(
                  child: Container(
                    width: double.infinity,
                    height: 170,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Decorative background elements inside illustration
                        Positioned(
                          top: 20,
                          left: 30,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE0E7FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.description_outlined, color: Color(0xFF4F46E5), size: 16),
                          ),
                        ),
                        Positioned(
                          top: 25,
                          right: 40,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE0E7FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.assignment_outlined, color: Color(0xFF4F46E5), size: 16),
                          ),
                        ),
                        Positioned(
                          bottom: 25,
                          right: 35,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE0E7FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.bar_chart_rounded, color: Color(0xFF4F46E5), size: 16),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 40,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE0E7FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.article_outlined, color: Color(0xFF4F46E5), size: 16),
                          ),
                        ),

                        // Official AI Logo Container
                        Container(
                          width: 95,
                          height: 95,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4F46E5).withOpacity(0.2),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Image.asset(
                              'assets/logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── NEW FEATURE CARD: Question Paper Solver ──
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 600),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QuestionPaperSolverScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4F46E5).withOpacity(0.3),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Center(
                              child: Text('📄', style: TextStyle(fontSize: 24)),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Question Paper Solver',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'NEW',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFFFDE047),
                                        backgroundColor: Color(0x33000000),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Upload a question paper and generate complete exam-ready answers.',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: Color(0xFFEEF2FF),
                                    fontWeight: FontWeight.w500,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Other Features List ──
              FadeInUp(
                delay: const Duration(milliseconds: 250),
                duration: const Duration(milliseconds: 600),
                child: Column(
                  children: [
                    _buildFeatureRow(
                      icon: Icons.description_outlined,
                      title: 'Resume Analysis',
                      subtitle: 'Get AI-powered ATS score',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureRow(
                      icon: Icons.check_box_outlined,
                      title: 'MCQ Assessment',
                      subtitle: 'Test your skills & knowledge',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureRow(
                      icon: Icons.headset_mic_outlined,
                      title: 'AI Interview',
                      subtitle: 'Practice with real interview questions',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureRow(
                      icon: Icons.insights_outlined,
                      title: 'Performance Report',
                      subtitle: 'Track your progress',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Get Started Button ──
              FadeInUp(
                delay: const Duration(milliseconds: 350),
                duration: const Duration(milliseconds: 500),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RoleSelectionScreen(initialRole: 'Flutter Developer'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      elevation: 4,
                      shadowColor: const Color(0xFF4F46E5).withOpacity(0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Get Started with Interview',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E1B4B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
