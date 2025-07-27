// lib/screens/professional_machine_products_screen.dart
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:staff_mangement/reusebleWidgets/app_bar_section.dart';
import '../constants/theme.dart';
import '../Models/machine_pick_list_model.dart';
import '../Models/picker_machine_product.dart';
import '../providers/picker_data_provider.dart';
import '../widgets/picker_product_cart.dart';

class PickerFillerMachineProductScreen extends StatefulWidget {
  final String role;
  final List machineDetails;
  List<dynamic> machineProductIdsList;
   PickerFillerMachineProductScreen({
    super.key,
    required this.role,
    required this.machineDetails,
    required this.machineProductIdsList
  });

  @override
  State<PickerFillerMachineProductScreen> createState() =>
      _PickerFillerMachineProductScreenState();
}

class _PickerFillerMachineProductScreenState
    extends State<PickerFillerMachineProductScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  late  List<PickerMachineProductModel> productsList = [];
  final Map<int, bool> _selectedProducts = {};
  final Map<int, int> _productQuantities = {};
  String _searchQuery = '';
  int totalPickedItem = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initLoading();
  }

  initLoading()async{
     _setupAnimations();
     await _loadMachineData();
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

    _animationController.forward();
  }
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<PickerMachineProductModel> get _filteredProducts {
    if (_searchQuery.isEmpty) return productsList;

    return productsList.where((product) {
      return product.displayName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  int get _selectedCount => _selectedProducts.values.where((selected) => selected).length;
  int get _totalQuantity => _productQuantities.values.fold<int>(0, (sum, qty) => sum + qty);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: appBarSection(
        icon: Icons.analytics_outlined,
        headerTitle1: widget.machineDetails[0]["name"],
        headerTitle2: '${productsList.length} products available',
        showNotification: true,
      ),
      body: _isLoading ? _buildLoadingState() : _buildProductGrid(),
      bottomNavigationBar: _buildBottomActions(),
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
            'Loading Products...',
            style: AppTextStyles.body1.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadMachineData() async {
    await Provider.of<PickerDataProvider>(context, listen: false).fetchPickerMachineProductData(widget.role,widget.machineProductIdsList);
    try {
      setState(() => _isLoading = true);
      setState(() {
        productsList =  Provider.of<PickerDataProvider>(context,listen: false).pickerMachineProductDetails;
        _isLoading = false;
      });
      for (final product in productsList) {
        widget.role == "picker" ?
        _selectedProducts[product.id] = product.isPicked:  _selectedProducts[product.id] = product.isFilled;
        _productQuantities[product.id] = 0;
      }

      _animationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorMessage('Failed to load Product data: ${e.toString()}');
    }
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

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search products...',
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
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: AppSpacing.xs),
          Column(
            children: [
              Text(
                value,
                style: AppTextStyles.subtitle2.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    final filteredProducts = _filteredProducts;

    if (filteredProducts.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
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
                  child: ProfessionalProductCard(
                    role:widget.role,
                    product: product,
                    isSelected: _selectedProducts[product.id] ?? false,
                    quantity: _productQuantities[product.id] ?? 0,
                    onSelectionChanged: () {
                      print("sdsdsdsd999");
                      setState(() {
                        _selectedProducts[product.id] =  _selectedProducts[product.id]! ? false : true;
                        widget.role == "picker" ?
                       Provider.of<PickerDataProvider>(context,listen: false).pickerMachineProductDetails[index].isPicked = _selectedProducts[product.id]!:
                        Provider.of<PickerDataProvider>(context,listen: false).pickerMachineProductDetails[index].isFilled = _selectedProducts[product.id]!;
                        // if (!selected) {
                        //   _productQuantities[product.id] = 0;
                        // } else if (_productQuantities[product.id] == 0) {
                        //   _productQuantities[product.id] = 1;
                        // }
                      });
                    },
                    onQuantityChanged: (quantity) {
                      setState(() {
                        _productQuantities[product.id] = quantity;
                        _selectedProducts[product.id] = quantity > 0;
                      });
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomActions() {
    final hasValidSelection = _selectedCount > 0;

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
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _selectedCount > 0 ? _clearAllSelections : null,
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear All'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: hasValidSelection ? _confirmSelection : null,
                icon: const Icon(Icons.shopping_cart),
                label: Text('Confirm Selection $_selectedCount',),
                style: ElevatedButton.styleFrom(
                  backgroundColor:  AppColors.primary.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSummaryDivider() {
    return Container(
      height: 30,
      width: 1,
      color: AppColors.divider,
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Center(
        child: SizedBox(
          height: 700,
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
              if (_searchQuery.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear Filters'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _clearAllSelections() {
    setState(() {
      for (final key in _selectedProducts.keys) {
        _selectedProducts[key] = false;
        _productQuantities[key] = 0;
      }
    });
  }

  void _confirmSelection() {
    totalPickedItem = 0;
    final selectedProducts =productsList.where(
          (product) => _selectedProducts[product.id] == true).toList();
    for(PickerMachineProductModel item in selectedProducts){
      setState(() {
        totalPickedItem = totalPickedItem + item.pickAmount;
      });
    }
    if (selectedProducts.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        ),
        title: Row(
          children: [
            Icon(Icons.shopping_cart, color: AppColors.primary),
            const SizedBox(width: AppSpacing.md),
            const Text('Confirm Selection'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.role == "picker" ?
                'Selected ${selectedProducts.length} products for picking:' : 'Selected ${selectedProducts.length} products for filling:',
                style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: selectedProducts.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),

                  itemBuilder: (context, index) {
                    final product = selectedProducts[index];
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.inventory_2,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        product.displayName,
                        style: AppTextStyles.body2.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                        ),
                        child: Text(
                          'Qty: ${product.pickAmount}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info, size: 20),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        widget.role == "picker" ?
                        'Total items to pick: $totalPickedItem':'Total items to fill: $totalPickedItem',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(

            onPressed: () {
              Provider.of<PickerDataProvider>(context,listen: false).savePickerMachineProductData(widget.role,widget.machineDetails[0]["pickListId"]);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.check),
            label: const Text('Confirm'),
            style: ElevatedButton.styleFrom(
              backgroundColor:  AppColors.primary.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

}

