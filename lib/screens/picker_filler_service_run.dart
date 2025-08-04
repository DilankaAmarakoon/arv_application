import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:staff_mangement/Models/picker_service_run_model.dart';
import 'package:staff_mangement/screens/picker_filler_section.dart';
import 'package:staff_mangement/screens/picker_machine_product_screen.dart';

import '../Models/machine_pick_list_model.dart';
import '../Models/picker_machine_product.dart';
import '../constants/theme.dart';
import '../providers/picker_data_provider.dart';
import '../reusebleWidgets/app_bar_section.dart';
import '../widgets/picker_filler_machine_cart.dart';
import '../widgets/picker_service_run_cart.dart';
import '../widgets/profile_section_drawer.dart';

class PickerServiceRunScreen extends StatefulWidget {
  final String role;
  const PickerServiceRunScreen({super.key,required this.role});

  @override
  State<PickerServiceRunScreen> createState() => _PickerServiceRunScreenState();
}

class _PickerServiceRunScreenState extends State<PickerServiceRunScreen>
    with TickerProviderStateMixin {
  List<PickerServiceRunModel> _serviceRuns = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'All';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Key _screenKey = UniqueKey();

  final List<String> _filterOptions = ['All', 'Pending', 'Completed', 'In Progress'];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadMachineData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
  Future<void> _loadMachineData() async {
    try {
      await Provider.of<PickerDataProvider>(context, listen: false).fetchServiceRunList();
      setState(() => _isLoading = true);
      setState(() {
        _serviceRuns =  Provider.of<PickerDataProvider>(context,listen: false).pickerServiceRunDetails;
        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorMessage('Failed to load machine data: ${e.toString()}');
    }
  }



  List<PickerServiceRunModel> get _filteredServiceRuns {
    List<PickerServiceRunModel> filtered = _serviceRuns;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((machine) {
        return machine.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply status filter
    if (_selectedFilter != 'All') {
      switch (_selectedFilter) {
        case 'Active':
          filtered = filtered.where((machine) => machine.name != "").toList();
          break;
        case 'Maintenance':
        // Add your maintenance logic here
          break;
        case 'Offline':
          filtered = filtered.where((machine) => machine.name == "").toList();
          break;
      }
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _screenKey,
      backgroundColor: AppColors.background,
      appBar: appBarSection(
        icon: Icons.analytics_outlined,
        headerTitle1: widget.role == "picker" ? 'Service Run Picker Operations' : 'Service Run Filler Operations',
        headerTitle2: 'Manage and monitor your vending machines',
        showNotification: true,
      ),
      endDrawer: const ProfileSectionDrawer(),
      body: _isLoading ? _buildLoadingState() : _buildContent(),
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
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Loading machines...',
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
          Expanded(child: _buildMachineList()),
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
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search machines, routes, or locations...',
              prefixIcon: const Icon(Icons.search_outlined),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() => _searchQuery = ''),
              )
                  : null,
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: _filterOptions.map((filter){
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) => setState(() => _selectedFilter = filter),
                    backgroundColor: AppColors.surfaceVariant,
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    checkmarkColor: AppColors.primary,
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.divider,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildMachineList() {
    final filteredServiceRuns = _filteredServiceRuns;

    if (filteredServiceRuns.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadMachineData,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: filteredServiceRuns.length,
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
                    child: PickerServiceRunCart(
                      role:widget.role,
                      serviceRun: filteredServiceRuns[index],
                      onTap: () => _navigateToMachineProducts(filteredServiceRuns[index]),
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
    return SingleChildScrollView(
      child: Center(
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
                Icons.kitchen,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              _searchQuery.isNotEmpty ? 'No machines found' : 'No machines available',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try adjusting your search or filters'
                  : 'Machines will appear here when available',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isNotEmpty || _selectedFilter != 'All') ...[
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _selectedFilter = 'All';
                  });
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear Filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showErrorMessage(String message) {
    if(mounted) return;
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

  Future<void> _navigateToMachineProducts(PickerServiceRunModel serviceRun) async {
    try {
      if (mounted) {
        // List<dynamic> machineDetails = [
        //   {
        //     "pickListId": machine.pick_list_id,
        //     "name": machine.name,
        //     "state": machine.state,
        //   }
        // ];

        await Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                PickerFillerScreen(
                  role: widget.role,
                  service_run_id: serviceRun.id,
                  service_run_name: serviceRun.name,
                ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                )),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
        await _loadMachineData();
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showErrorMessage('Failed to load products: ${e.toString()}');
    }
  }

}
