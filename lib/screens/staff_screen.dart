import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:staff_mangement/reusebleWidgets/app_bar_section.dart';
import '../constants/theme.dart';
import '../Models/staff_task_data_model.dart';
import '../widgets/profile_section_drawer.dart';
import '../widgets/staff_cart.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen>
    with TickerProviderStateMixin {
  final StaffTaskDataList _staffTaskDataList = StaffTaskDataList();
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'All';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _filterOptions = ['All', 'Pending', 'Completed', 'In Progress'];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadStaffData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadStaffData() async {
    try {
      await _staffTaskDataList.fetchStaffData(context);
      setState(() {
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load staff data');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.onPrimary),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
      ),
    );
  }

  List<StaffTaskDataModel> get _filteredTasks {
    List<StaffTaskDataModel> filtered = _staffTaskDataList.staffTaskDataList;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((task) {
        return task.taskName!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            task.taskDesc!.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply status filter
    if (_selectedFilter != 'All') {
      switch (_selectedFilter) {
        case 'Completed':
          filtered = filtered.where((task) => task.isCompleted == true).toList();
          break;
        case 'Pending':
          filtered = filtered.where((task) => task.isCompleted == false).toList();
          break;
        case 'In Progress':
        // You can add logic for in-progress tasks here
          break;
      }
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // appBar: const appBarSection(title: "ssss"),
      endDrawer: const ProfileSectionDrawer(),
      body: _isLoading ? _buildLoadingState() : _buildContent(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingAnimationWidget.staggeredDotsWave(
            color: AppColors.primary,
            size: 50,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Loading staff data...',
            style: AppTextStyles.body1.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _buildSearchAndFilter(),
          _buildStatsBar(),
          Expanded(
            child: _buildTaskList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search tasks...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filterOptions.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    backgroundColor: AppColors.surfaceVariant,
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    checkmarkColor: AppColors.primary,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    final totalTasks = _staffTaskDataList.staffTaskDataList.length;
    final completedTasks = _staffTaskDataList.staffTaskDataList
        .where((task) => task.isCompleted == true)
        .length;
    final pendingTasks = totalTasks - completedTasks;
    final completionRate = totalTasks > 0 ? (completedTasks / totalTasks * 100) : 0;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primaryLight.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          _buildStatItem('Total', totalTasks.toString(), Icons.assignment),
          _buildStatDivider(),
          _buildStatItem('Completed', completedTasks.toString(), Icons.check_circle),
          _buildStatDivider(),
          _buildStatItem('Pending', pendingTasks.toString(), Icons.pending),
          _buildStatDivider(),
          _buildStatItem('Rate', '${completionRate.toStringAsFixed(0)}%', Icons.trending_up),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.subtitle1.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 40,
      width: 1,
      color: AppColors.divider,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
    );
  }

  Widget _buildTaskList() {
    final filteredTasks = _filteredTasks;

    if (filteredTasks.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadStaffData,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 200 + (index * 50)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: StaffCart(
                      task: filteredTasks[index],
                      index: index,
                      onTaskUpdated: () => setState(() {}),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assignment_outlined,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            _searchQuery.isNotEmpty
                ? 'No tasks found'
                : 'No tasks available',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search or filters'
                : 'Tasks will appear here when available',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedFilter = 'All';
                });
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _loadStaffData,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      icon: const Icon(Icons.refresh),
      label: const Text('Refresh'),
    );
  }
}