import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/category_model.dart';
import '../../providers/core_providers.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/loading_state_widget.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSessionSelector(CategoryModel category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SessionSelectorSheet(category: category),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Explore Technologies',
          style: AppTextStyles.displaySmall.copyWith(fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            onPressed: () => ref.refresh(categoriesProvider),
            tooltip: 'Refresh Categories',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: categoriesAsync.when(
        loading: () => const LoadingStateWidget(message: 'Loading technologies...'),
        error: (err, _) => ErrorStateWidget(
          message: err.toString(),
          onRetry: () => ref.refresh(categoriesProvider),
        ),
        data: (categories) {
          final filtered = categories
              .where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => ref.refresh(categoriesProvider.future),
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: AppTextField(
                    hint: 'Search technologies (e.g. React, PHP, Python)...',
                    controller: _searchController,
                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textSecondary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),

                // Grid / List of technologies
                Expanded(
                  child: filtered.isEmpty
                      ? EmptyStateWidget(
                          title: 'No technologies found',
                          subtitle: _searchQuery.isEmpty
                              ? 'No technology tracks available.'
                              : 'No matches found for "$_searchQuery".',
                          icon: Icons.search_off_rounded,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final cat = filtered[index];
                            return _buildTechCard(cat);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTechCard(CategoryModel cat) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showSessionSelector(cat),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.mutedBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Text(
                      cat.name.isNotEmpty ? cat.name[0].toUpperCase() : 'T',
                      style: AppTextStyles.displaySmall.copyWith(
                        color: AppColors.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cat.name,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        cat.questionCount > 0
                            ? '${cat.questionCount} Questions in bank'
                            : 'Multi-session track',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionSelectorSheet extends ConsumerStatefulWidget {
  final CategoryModel category;

  const _SessionSelectorSheet({required this.category});

  @override
  ConsumerState<_SessionSelectorSheet> createState() => _SessionSelectorSheetState();
}

class _SessionSelectorSheetState extends ConsumerState<_SessionSelectorSheet> {
  int _selectedSession = 1;
  bool _isAllSessions = false;
  List<int> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSessions();
  }

  Future<void> _fetchSessions() async {
    try {
      final repo = ref.read(quizRepositoryProvider);
      final list = await repo.getCategorySessions(widget.category.name);
      if (mounted) {
        setState(() {
          _sessions = list;
          _selectedSession = list.isNotEmpty ? list.first : 1;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _sessions = widget.category.sessions.isNotEmpty
              ? widget.category.sessions
              : [1];
          _selectedSession = _sessions.first;
          _isLoading = false;
        });
      }
    }
  }

  void _startQuiz() {
    Navigator.of(context).pop();
    context.push(
      '/quiz/play',
      extra: {
        'category': widget.category.name,
        'session': _isAllSessions ? 0 : _selectedSession,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    widget.category.name.isNotEmpty ? widget.category.name[0] : 'T',
                    style: AppTextStyles.displaySmall.copyWith(
                      color: AppColors.primary,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.category.name,
                      style: AppTextStyles.displaySmall.copyWith(fontSize: 18),
                    ),
                    Text(
                      'Choose a session to begin assessment',
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            )
          else ...[
            Text(
              'Available Sessions',
              style: AppTextStyles.labelBold.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 10),

            // All Sessions option if multiple sessions exist
            if (_sessions.length > 1) ...[
              Material(
                color: _isAllSessions ? AppColors.accentLight : AppColors.mutedBg,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() {
                      _isAllSessions = true;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'All Sessions Combined',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: _isAllSessions ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                        if (_isAllSessions)
                          const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Individual Sessions
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sessions.map((sess) {
                final isSelected = !_isAllSessions && _selectedSession == sess;
                return ChoiceChip(
                  label: Text('Session $sess'),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.mutedBg,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedSession = sess;
                        _isAllSessions = false;
                      });
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            AppButton(
              text: _isAllSessions
                  ? 'Start All Sessions Assessment'
                  : 'Start Session $_selectedSession Quiz',
              onPressed: _startQuiz,
              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
            ),
          ],
        ],
      ),
    );
  }
}
