import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class AdminAiGeneratorScreen extends ConsumerStatefulWidget {
  const AdminAiGeneratorScreen({super.key});

  @override
  ConsumerState<AdminAiGeneratorScreen> createState() => _AdminAiGeneratorScreenState();
}

class _AdminAiGeneratorScreenState extends ConsumerState<AdminAiGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController(text: 'React Server Components');
  final _sessionController = TextEditingController(text: '1');
  String _difficulty = 'intermediate';
  int _questionCount = 5;
  bool _isGenerating = false;
  String? _successMessage;

  @override
  void dispose() {
    _topicController.disposeDisposeSafe();
    _sessionController.disposeDisposeSafe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Question Generator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF673AB7), Color(0xFF512DA8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF673AB7).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI-Powered Generation',
                            style: AppTextStyles.displaySmall.copyWith(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Generate production-grade MCQs directly into the question database.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Topic Input
              AppTextField(
                label: 'Technology / Topic',
                controller: _topicController,
                hint: 'e.g. Flutter State Management, Docker, GraphQL',
                prefixIcon: const Icon(Icons.code_rounded),
                validator: (v) => v?.trim().isEmpty == true ? 'Topic is required' : null,
              ),

              const SizedBox(height: 16),

              // Session Number
              AppTextField(
                label: 'Session Number',
                controller: _sessionController,
                hint: '1',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.pin_rounded),
                validator: (v) {
                  final parsed = int.tryParse(v?.trim() ?? '');
                  if (parsed == null || parsed < 1) return 'Must be a positive number';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Difficulty Dropdown
              Text(
                'Difficulty Level',
                style: AppTextStyles.labelBold,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _difficulty,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'beginner', child: Text('Beginner (Foundational)')),
                  DropdownMenuItem(value: 'intermediate', child: Text('Intermediate (Standard)')),
                  DropdownMenuItem(value: 'advanced', child: Text('Advanced (Architectural)')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _difficulty = val);
                },
              ),

              const SizedBox(height: 20),

              // Question Count Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Questions to Generate', style: AppTextStyles.labelBold),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$_questionCount questions',
                      style: AppTextStyles.mono.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              Slider(
                value: _questionCount.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: '$_questionCount',
                activeColor: AppColors.primary,
                onChanged: (val) => setState(() => _questionCount = val.round()),
              ),

              const SizedBox(height: 24),

              // Feedback State
              if (_successMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.success),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.success),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _successMessage!,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.success),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Generate Action Button
              AppButton(
                text: _isGenerating ? 'Generating Questions...' : 'Generate Questions with AI',
                icon: Icons.auto_awesome_rounded,
                isLoading: _isGenerating,
                onPressed: _isGenerating ? null : _handleGenerate,
              ),

              if (_successMessage != null) ...[
                const SizedBox(height: 12),
                AppButton(
                  text: 'View in Question Bank',
                  type: AppButtonType.outline,
                  icon: Icons.quiz_rounded,
                  onPressed: () => context.push('/admin/questions'),
                ),
              ],

              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleGenerate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isGenerating = true;
      _successMessage = null;
    });

    final topic = _topicController.text.trim();
    final session = int.tryParse(_sessionController.text.trim()) ?? 1;

    final success = await ref.read(adminControllerProvider.notifier).generateAiQuestions(
          topic: topic,
          session: session,
          difficulty: _difficulty,
          count: _questionCount,
        );

    if (mounted) {
      setState(() {
        _isGenerating = false;
        if (success) {
          _successMessage = 'Successfully generated and added $_questionCount questions for "$topic" Session $session!';
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to generate AI questions. Check backend connectivity.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      });
    }
  }
}

extension on TextEditingController {
  void disposeDisposeSafe() {
    try {
      dispose();
    } catch (_) {}
  }
}
