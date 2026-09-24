import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/question_model.dart';
import '../../providers/admin_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/loading_state_widget.dart';

class AdminQuestionsScreen extends ConsumerStatefulWidget {
  const AdminQuestionsScreen({super.key});

  @override
  ConsumerState<AdminQuestionsScreen> createState() => _AdminQuestionsScreenState();
}

class _AdminQuestionsScreenState extends ConsumerState<AdminQuestionsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(adminQuestionsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(adminCategoryFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Bank'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(adminQuestionsProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Question'),
        onPressed: () => _openCreateQuestionDialog(),
      ),
      body: Column(
        children: [
          // Filter & Search Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Column(
              children: [
                // Search Input
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search questions by text...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                ),
                const SizedBox(height: 10),
                // Category Filter Pills
                categoriesAsync.when(
                  data: (cats) => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: selectedCategory == null,
                          onSelected: (_) => ref.read(adminCategoryFilterProvider.notifier).state = null,
                        ),
                        const SizedBox(width: 8),
                        ...cats.map((c) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(c.name),
                                selected: selectedCategory == c.name,
                                onSelected: (sel) {
                                  ref.read(adminCategoryFilterProvider.notifier).state =
                                      sel ? c.name : null;
                                },
                              ),
                            )),
                      ],
                    ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (err, stack) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Questions List
          Expanded(
            child: questionsAsync.when(
              loading: () => const LoadingStateWidget(message: 'Loading question bank...'),
              error: (err, stack) => ErrorStateWidget(
                message: 'Failed to load questions: ${err.toString()}',
                onRetry: () => ref.invalidate(adminQuestionsProvider),
              ),
              data: (questions) {
                final filtered = questions.where((q) {
                  if (_searchQuery.isEmpty) return true;
                  return q.question.toLowerCase().contains(_searchQuery) ||
                      q.category.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.quiz_outlined,
                    title: 'No Questions Found',
                    subtitle: _searchQuery.isNotEmpty
                        ? 'No questions match "$_searchQuery".'
                        : 'No questions in this category yet. Click "New Question" below.',
                    actionText: 'Add First Question',
                    onAction: () => _openCreateQuestionDialog(),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(adminQuestionsProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final q = filtered[index];
                      return _buildQuestionCard(q);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuestionModel q) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${q.category} • Session ${q.session}',
                  style: AppTextStyles.mono.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                tooltip: 'Delete Question',
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                onPressed: () => _confirmDeleteQuestion(q),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            q.question,
            style: AppTextStyles.labelBold.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: q.options.map((opt) {
              final isCorrect = opt.trim().toLowerCase() == q.correctAnswer.trim().toLowerCase();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  children: [
                    Icon(
                      isCorrect ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      size: 16,
                      color: isCorrect ? AppColors.success : AppColors.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        opt,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isCorrect ? AppColors.success : AppColors.textSecondary,
                          fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteQuestion(QuestionModel q) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Question?'),
        content: Text('Are you sure you want to delete this question from ${q.category}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await ref.read(adminControllerProvider.notifier).deleteQuestion(q.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Question deleted successfully.' : 'Failed to delete question.'),
                    backgroundColor: success ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _openCreateQuestionDialog() {
    final formKey = GlobalKey<FormState>();
    final catController = TextEditingController(text: ref.read(adminCategoryFilterProvider) ?? 'JavaScript');
    final sessionController = TextEditingController(text: '1');
    final qTextController = TextEditingController();
    final opt1Controller = TextEditingController();
    final opt2Controller = TextEditingController();
    final opt3Controller = TextEditingController();
    final opt4Controller = TextEditingController();
    int correctIndex = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (dialogCtx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add New Question', style: AppTextStyles.displaySmall.copyWith(fontSize: 18)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: AppTextField(
                          label: 'Category',
                          controller: catController,
                          hint: 'e.g. React',
                          validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: AppTextField(
                          label: 'Session',
                          controller: sessionController,
                          hint: '1',
                          keyboardType: TextInputType.number,
                          validator: (v) => int.tryParse(v ?? '') == null ? 'Invalid' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Question Text',
                    controller: qTextController,
                    hint: 'Type the question here...',
                    maxLines: 3,
                    validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  Text('Options (Select correct one):', style: AppTextStyles.labelBold),
                  const SizedBox(height: 8),
                  _buildOptionInput(0, opt1Controller, correctIndex, (idx) => setSheetState(() => correctIndex = idx)),
                  const SizedBox(height: 8),
                  _buildOptionInput(1, opt2Controller, correctIndex, (idx) => setSheetState(() => correctIndex = idx)),
                  const SizedBox(height: 8),
                  _buildOptionInput(2, opt3Controller, correctIndex, (idx) => setSheetState(() => correctIndex = idx)),
                  const SizedBox(height: 8),
                  _buildOptionInput(3, opt4Controller, correctIndex, (idx) => setSheetState(() => correctIndex = idx)),
                  const SizedBox(height: 20),
                  AppButton(
                    text: 'Save Question',
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final options = [
                        opt1Controller.text.trim(),
                        opt2Controller.text.trim(),
                        opt3Controller.text.trim(),
                        opt4Controller.text.trim(),
                      ];
                      if (options.any((o) => o.isEmpty)) {
                        ScaffoldMessenger.of(sheetCtx).showSnackBar(
                          const SnackBar(content: Text('All 4 options must be filled.')),
                        );
                        return;
                      }

                      Navigator.of(sheetCtx).pop();
                      final success = await ref.read(adminControllerProvider.notifier).createQuestion(
                            category: catController.text.trim(),
                            session: int.tryParse(sessionController.text.trim()) ?? 1,
                            questionText: qTextController.text.trim(),
                            options: options,
                            correctAnswer: options[correctIndex],
                          );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? 'Question saved to bank!' : 'Failed to save question.'),
                            backgroundColor: success ? AppColors.success : AppColors.error,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionInput(
    int index,
    TextEditingController controller,
    int selectedIndex,
    ValueChanged<int> onSelect,
  ) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            index == selectedIndex
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_unchecked_rounded,
            color: index == selectedIndex ? AppColors.success : AppColors.textMuted,
          ),
          tooltip: 'Select as correct answer',
          onPressed: () => onSelect(index),
        ),
        Expanded(
          child: AppTextField(
            label: 'Option ${index + 1}',
            controller: controller,
            hint: 'Option content',
            validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
          ),
        ),
      ],
    );
  }
}
