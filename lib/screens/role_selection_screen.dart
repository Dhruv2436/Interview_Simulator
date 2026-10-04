import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'upload_resume_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  final String initialRole;
  const RoleSelectionScreen({super.key, this.initialRole = 'Flutter Developer'});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  late String _selectedRole;

  final List<Map<String, dynamic>> _roleOptions = [
    {
      'title': 'Flutter Developer',
      'subtitle': 'Mobile App Development',
      'icon': Icons.code_rounded,
      'iconBg': const Color(0xFFEEF2FF),
      'iconColor': const Color(0xFF4F46E5),
    },
    {
      'title': 'Frontend Developer',
      'subtitle': 'Web Development',
      'icon': Icons.code_rounded,
      'iconBg': const Color(0xFFD1FAE5),
      'iconColor': const Color(0xFF10B981),
    },
    {
      'title': 'Backend Developer',
      'subtitle': 'Server & APIs',
      'icon': Icons.storage_rounded,
      'iconBg': const Color(0xFFF3E8FF),
      'iconColor': const Color(0xFF8B5CF6),
    },
    {
      'title': 'Full Stack Developer',
      'subtitle': 'Frontend + Backend',
      'icon': Icons.memory_rounded,
      'iconBg': const Color(0xFFFFEDD5),
      'iconColor': const Color(0xFFF97316),
    },
    {
      'title': 'Data Analyst',
      'subtitle': 'Data & Analytics',
      'icon': Icons.bar_chart_rounded,
      'iconBg': const Color(0xFFE0F2FE),
      'iconColor': const Color(0xFF0284C7),
    },
    {
      'title': 'AI / ML Engineer',
      'subtitle': 'Machine Learning & AI',
      'icon': Icons.psychology_rounded,
      'iconBg': const Color(0xFFFCE7F3),
      'iconColor': const Color(0xFFEC4899),
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
  }

  void _onRoleSelect(String roleTitle) {
    setState(() {
      _selectedRole = roleTitle;
    });

    // Navigate to Upload Resume / Interview Setup Screen with selected role
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UploadResumeScreen(
              role: _selectedRole,
              experienceLevel: 'Fresher',
              difficultyLevel: 'Medium',
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFF1E293B), size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Title & Subtitle ──
              FadeInDown(
                duration: const Duration(milliseconds: 400),
                child: const Text(
                  'Select Your Role',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E1B4B),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              FadeInDown(
                delay: const Duration(milliseconds: 100),
                duration: const Duration(milliseconds: 400),
                child: const Text(
                  'Choose the job role you want to\nprepare for interview.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Roles List ──
              Expanded(
                child: FadeInUp(
                  delay: const Duration(milliseconds: 150),
                  duration: const Duration(milliseconds: 500),
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _roleOptions.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final item = _roleOptions[index];
                      final isSelected = _selectedRole == item['title'];

                      return GestureDetector(
                        onTap: () => _onRoleSelect(item['title'] as String),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFF3F0FF) : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFF1F5F9),
                              width: isSelected ? 1.8 : 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? const Color(0xFF6366F1).withOpacity(0.08)
                                    : Colors.black.withOpacity(0.02),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: item['iconBg'] as Color,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  item['icon'] as IconData,
                                  color: item['iconColor'] as Color,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'] as String,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF1E1B4B),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item['subtitle'] as String,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF94A3B8),
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
