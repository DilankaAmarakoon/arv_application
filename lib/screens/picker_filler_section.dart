import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:staff_mangement/screens/picker_machine_product_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Models/machine_pick_list_model.dart';
import '../Models/picker_machine_product.dart';
import '../constants/theme.dart';
import '../providers/picker_filler_data_provider.dart';
import '../reusebleWidgets/app_bar_section.dart';
import '../widgets/basket_number_popup.dart';
import '../widgets/filler_location_dragable_form_sheet.dart';
import '../widgets/picker_filler_machine_cart.dart';
import '../widgets/picker_operation_dragable_form_sheet.dart';
import '../widgets/profile_section_drawer.dart';

class PickerFillerScreen extends StatefulWidget {
  final String role;
  final int service_run_id;
  final String service_run_name;
  const PickerFillerScreen({super.key,required this.role,this.service_run_id = 0,this.service_run_name =""});

  @override
  State<PickerFillerScreen> createState() => _PickerFillerScreenState();
}

class _PickerFillerScreenState extends State<PickerFillerScreen>
    with TickerProviderStateMixin {
  List<MachinePickListModel> _machines = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'All';
  String basketNumbers ="";

  // Selection mode variables
  List<int> _selectedMachineIds = [];
  bool _isSelectionMode = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Key _screenKey = UniqueKey();

  final List<String> _filterOptions = ['All', 'Active', 'Maintenance', 'Offline'];

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

  // Selection mode methods
  void _handleLongPress(MachinePickListModel machine) {
    if(widget.role  != "picker"){
      return;
    }
    setState(() {
      if (!_isSelectionMode) {
        _isSelectionMode = true;
          _selectedMachineIds.add(machine.pick_list_id);
      } else {
        _toggleSelection(machine.pick_list_id);
      }
    });
  }
  void _handleDoublePress(MachinePickListModel machine,int index) {
    if(_isSelectionMode){
      return;
    }
    if(widget.role == "picker"){
      showScanBasketDialog(context,machine.basketNumbers).then((value)async{
        if(value !=null){
          await Provider.of<PickerDataProvider>(context, listen: false)
              .saveBasketNumbersData(machine.pick_list_id,value);
          _loadMachineData();
        }});
    }else{
      FillerLocationDragableFormSheet().openDraggableSheet(
        context,
        onConfirm: () {
          _openMap(machine.latitude,machine.longitude);
        },
      );


    }
  }
  Future<void> _openMap(latitude,longitude) async {
    final Uri googleUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
    }
  }

  void _handleTap(MachinePickListModel machine) {
    if (_isSelectionMode) {
      if(machine.state !="picked"){
        _toggleSelection(machine.pick_list_id);
      }
    } else {
      _navigateToMachineProducts(machine);
    }
  }

  void _toggleSelection(int machineId) {
    setState(() {
      if (_selectedMachineIds.contains(machineId)) {
        _selectedMachineIds.remove(machineId);
        if (_selectedMachineIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedMachineIds.add(machineId);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedMachineIds.clear();
      _isSelectionMode = false;
    });
  }

  _handleViewSelected() {
    // Filter selected machines
    List<MachinePickListModel> selectedMachines = _machines
        .where((machine) => _selectedMachineIds.contains(machine.pick_list_id))
        .toList();


    // Extract details only from selected machines
    List<int> selectedMachinesIds = selectedMachines
        .expand((m) => m.pickListIds)
        .cast<int>()
        .toList();
    List<int> pickListIds = selectedMachines.map((m) => m.pick_list_id).toList();
    String combinedNames = selectedMachines.map((m) => m.name).join(" | ");
    String? state = selectedMachines.isNotEmpty ? selectedMachines.first.state : null;

    List<dynamic> machineDetails = [
      {
        "pickListId": pickListIds,
        "name": combinedNames,
        "state": state,
      }
    ];
     _navigateToListMachineProducts(selectedMachinesIds, machineDetails);
  }




  Future<void> _loadMachineData() async {
    try {
      await Provider.of<PickerDataProvider>(context, listen: false).fetchMachinePickList(role:widget.role,serviceRunId:widget.service_run_id);
      await Provider.of<PickerDataProvider>(context, listen: false).fetchHrEmployeeDataData();
      await Provider.of<PickerDataProvider>(context,listen: false).fetchBasketNumberData();
      setState(() => _isLoading = true);
      setState(() {
        _machines =  Provider.of<PickerDataProvider>(context,listen: false).pickerMachineDetails;
        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      if(mounted) return;
      setState(() => _isLoading = false);
      _showErrorMessage('Failed to load machine data: ${e.toString()}');
    }
  }
  List<MachinePickListModel> get _filteredMachines {
    List<MachinePickListModel> filtered =[];
    if(_isSelectionMode){
      filtered = _machines.where((machine) => machine.state != "picked").toList();
    }else{
      filtered = _machines;
    }
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
    return  WillPopScope(
      onWillPop: () async {
        if(widget.role == "picker"){
          return false;

        }else{
          return true;
        }
      },
      child: Scaffold(
        key: _screenKey,
        backgroundColor: AppColors.background,
        appBar: appBarSection(
          icon: Icons.analytics_outlined,
          headerTitle1: _isSelectionMode
              ? '${_selectedMachineIds.length} selected'
              : widget.role == "picker" ? '${widget.service_run_name}\nMachine Operations' : 'Filler Operations',
          headerTitle2: _isSelectionMode
              ? 'Tap to select/deselect machines'
              : 'Manage and monitor your vending machines',
          showNotification: !_isSelectionMode,
          // Add close button for selection mode
          actions: _isSelectionMode ? [
            IconButton(
              icon: Icon(Icons.close),
              onPressed: _clearSelection,
            ),
          ] : null,
        ),
        endDrawer: _isSelectionMode ? null : const ProfileSectionDrawer(),
        body: _isLoading ? _buildLoadingState() : _buildContent(),
        floatingActionButton: _selectedMachineIds.isNotEmpty
            ? FloatingActionButton.extended(
          onPressed: _handleViewSelected,
          icon: const Icon(Icons.add),
          label: const Text('Pick'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        )
            : null,
      ),
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
          if (!_isSelectionMode) _buildSearchAndFilter(),
          Expanded(child: _buildMachineList()),
          if (widget.role == "picker" && !_isSelectionMode) _buildBottomActions()
          else SizedBox()
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: (){
                  PickerOperationConfirmationFormSheet().openDraggableSheet(
                    context,
                    role: "picker",
                    onConfirm: (formData) {
                      Provider.of<PickerDataProvider>(context,listen: false).saveServiceRunPickerForm(formData,widget.service_run_id);
                      Navigator.pop(context);
                    },
                  );
                },
                icon: const Icon(Icons.shopping_cart),
                label: Text('Confirm Operation',),
              ),
            ),
          ],
        ),
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
              children: _filterOptions.map((filter) {
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
    final filteredMachines = _filteredMachines;

    if (filteredMachines.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadMachineData,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: filteredMachines.length,
        itemBuilder: (context, index) {
          final machine = filteredMachines[index];
          final isSelected = _selectedMachineIds.contains(machine.pick_list_id);

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
                    child: PickerFillerMatchingCart(
                      role: widget.role,
                      machine: machine,
                      onTap: () => _handleTap(machine),
                      onLongPress: () =>  _handleLongPress(machine),
                      onDoublePress: () =>  _handleDoublePress(machine,index),
                      isSelected: isSelected,
                      isSelectionMode: _isSelectionMode,
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

  Future<void> _navigateToMachineProducts(MachinePickListModel machine) async {
    try {
      if (mounted) {
        List<dynamic>  machineDetails = [
            {
              "pickListId": machine.pick_list_id,
              "name": machine.name,
              "state": machine.state,
            }
          ];
        await Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                PickerFillerMachineProductScreen(
                  role: widget.role,
                  machineDetails: machineDetails,
                  machineProductIdsList: machine.pickListIds,
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
  Future<void> _navigateToListMachineProducts(selectedMachinesPickListIds,List<dynamic> machineDetails) async {
    try {
      if (mounted) {
        await Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                PickerFillerMachineProductScreen(
                  role: widget.role,
                  machineDetails: machineDetails,
                  machineProductIdsList: selectedMachinesPickListIds,
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