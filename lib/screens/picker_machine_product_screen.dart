// lib/screens/picker_machine_product_screen.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:staff_mangement/reusebleWidgets/app_bar_section.dart';
import '../constants/theme.dart';
import '../Models/picker_machine_product.dart';
import '../providers/picker_data_provider.dart';
import '../reusebleWidgets/loading_btn.dart';
import '../reusebleWidgets/showDialog.dart';
import '../widgets/filler_operation_dragable_form_sheet.dart';
import '../widgets/picker_filler_product_cart.dart';
import '../servicess/barcode_scanner_service.dart'; // Import barcode service

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

  late List<PickerMachineProductModel> productsList = [];
  final Map<int, bool> _selectedProducts = {};
  final Map<int, int> _productQuantities = {};
  String _searchQuery = '';
  int totalPickedItem = 0;
  bool _isLoading = true;

  // Barcode scanning variables
  late BarcodeScannerService _barcodeService;
  bool _isScannerEnabled = false;
  String _lastScannedBarcode = '';

  List<dynamic> basketNumberList =[];

  @override
  void initState() {
    super.initState();
    initLoading();
    if(widget.role =="picker"){
      _initializeBarcodeScanner();
    }
  }

  initLoading() async {
    _setupAnimations();
    _loadMachineData();
  }
  // Initialize barcode scanner for auto-picking
  void _initializeBarcodeScanner() async {
    _barcodeService = BarcodeScannerService();
    bool initialized = await _barcodeService.initialize();

    if (initialized) {
      setState(() {
        _isScannerEnabled = true;
      });

      // Listen to barcode scan results
      _barcodeService.barcodeStream.listen((scannedBarcode) {
        _handleBarcodeScanned(scannedBarcode);
      });
      print('Barcode scanner initialized successfully for auto-picking');
    } else {
      print('Failed to initialize barcode scanner');
    }
  }

  // Handle barcode scan result - auto pick product
  void _handleBarcodeScanned(String barcode) {
    setState(() {
      _lastScannedBarcode = barcode;
    });

    // Find product that matches the scanned barcode
    PickerMachineProductModel? matchedProduct = _findProductByBarcode(barcode);

    if (matchedProduct != null) {
      // Auto-pick the product
      _autoPickProduct(matchedProduct);

      // Show success feedback
      _showBarcodeSuccessMessage(matchedProduct.displayName, barcode);
    } else {
      // Show error feedback - no matching product found
      _showBarcodeErrorMessage(barcode);
    }
  }
  // Find product that matches the scanned barcode
  PickerMachineProductModel? _findProductByBarcode(String barcode) {
    for (PickerMachineProductModel product in productsList) {
      // Check if barcode matches product code
      if (product.barcode == barcode) {
        final list = Provider.of<PickerDataProvider>(context,listen: false).pickerMachineProductDetails;
        for(PickerMachineProductModel item in list){
          if(item.id == product.id){
            item.isPicked =_selectedProducts[product.id]!;
          }
        }
        return product;
      }

      // Check if barcode matches product SKU (if available)
      if (product.barcode != null && product.machineName == barcode) {
        return product;
      }

      // Check if barcode matches product ID as string
      if (product.id.toString() == barcode) {
        return product;
      }

      // You can add more matching criteria here based on your product model
      // For example, if you have a dedicated barcode field:
      // if (product.barcode == barcode) {
      //   return product;
      // }
    }

    return null;
  }

  // Auto-pick the matched product
  void _autoPickProduct(PickerMachineProductModel product) {
    if (widget.role == "picker" &&
        (widget.machineDetails[0]['state'] == "picked" || widget.machineDetails[0]['state'] == "filled")) {
      _showBarcodeErrorMessage(_lastScannedBarcode, "Cannot pick - machine already processed");
      return;
    }
    if (widget.role != "picker" && widget.machineDetails[0]['state'] == "filled") {
      _showBarcodeErrorMessage(_lastScannedBarcode, "Cannot fill - machine already filled");
      return;
    }

    setState(() {
      // Auto-select the product
      _selectedProducts[product.id] = true;

      // Set quantity to the required pick amount
      _productQuantities[product.id] = product.pickAmount;

      // Update total picked items
      _updateTotalPickedItems();
    });

    // Scroll to the selected product for visual feedback
    _scrollToProduct(product);
  }

  // Update total picked items count
  void _updateTotalPickedItems() {
    totalPickedItem = 0;
    final selectedProducts = productsList.where(
            (product) => _selectedProducts[product.id] == true
    ).toList();

    for (PickerMachineProductModel item in selectedProducts) {
      totalPickedItem += item.pickAmount;
    }
  }

  // Scroll to the auto-picked product
  void _scrollToProduct(PickerMachineProductModel product) {
    // Find the index of the product in the filtered list
    int index = _filteredProducts.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      // Calculate scroll position (approximate)
      double scrollPosition = index * 120.0; // Approximate card height

      // You can implement scrolling logic here if you have a ScrollController
      // _scrollController.animateTo(scrollPosition, ...);
    }
  }

  // Show success message for barcode scan
  void _showBarcodeSuccessMessage(String productName, String barcode) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Product Auto-Picked!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$productName (${barcode})',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 150, // Adjust this value as needed
          right: 20,
          left: 20,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Show error message for barcode scan
  void _showBarcodeErrorMessage(String barcode, [String? customMessage]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    customMessage ?? 'Product Not Found',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Barcode: $barcode',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: Duration(seconds: 4),
      ),
    );
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
    if(widget.role =="picker"){
      _barcodeService.dispose();
    }
    super.dispose();
  }

  // Load machine data (existing method)
  Future<void> _loadMachineData() async {
    try {
      await Provider.of<PickerDataProvider>(context, listen: false)
          .fetchPickerMachineProductData(widget.role,widget.machineProductIdsList);

      setState(() => _isLoading = true);
      setState(() {
        productsList = Provider.of<PickerDataProvider>(context, listen: false)
            .pickerMachineProductDetails;

        // Initialize selection maps
        for (final product in productsList) {
          widget.role == "picker" ?
          _selectedProducts[product.id] = product.isPicked:  _selectedProducts[product.id] = product.isFilled;
          _productQuantities[product.id] = 0;
        }

        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading machine data: $e');
    }
  }

  List<PickerMachineProductModel> get _filteredProducts {
    if (_searchQuery.isEmpty) return productsList;

    return productsList.where((product) {
      return product.displayName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.barcode.toLowerCase().contains(_searchQuery.toLowerCase());
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
        headerTitle2: '',
        showNotification: true,
        // Add barcode indicator in app bar
      ),
      body: _isLoading
          ? _buildLoadingState()
          : Column(
        children: [
          _buildHeader(),
          if (_isScannerEnabled) _buildBarcodeStatus(),
          Expanded(child: _buildProductGrid()),
          if (_selectedCount > 0) _buildBottomControls(),
        ],
      ),
    );
  }

  // Build barcode scanner status widget
  Widget _buildBarcodeStatus() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isScannerEnabled ? AppColors.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isScannerEnabled ? AppColors.primary.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isScannerEnabled ? Icons.qr_code_scanner : Icons.scanner_outlined,
            color: _isScannerEnabled ? AppColors.primary : Colors.grey,
            size: 20,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              _isScannerEnabled
                  ? 'Scan to auto-pick'
                  : 'Barcode scanner not available',
              style: TextStyle(
                color: _isScannerEnabled ? AppColors.primary : Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (_lastScannedBarcode.isNotEmpty) ...[
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Last: $_lastScannedBarcode',
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
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
          const SizedBox(height: 24),
          Text(
            'Loading products...',
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
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
              hintText: 'Search products or scan barcode...',
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
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Summary Row
          Row(
            children: [
              _buildSummaryItem('Total', '${productsList.length}', Icons.inventory_2, AppColors.primary),
              _buildSummaryItem('Selected', '$_selectedCount', Icons.check_circle, AppColors.success),
              _buildSummaryItem(widget.role == "picker" ?'Pick Amount':'Fill Amount', '$_totalQuantity', Icons.numbers, AppColors.warning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
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
      padding: const EdgeInsets.all(16),
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
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ProfessionalProductCard(
                    role: widget.role,
                    bulkView: widget.machineDetails[0]["pickListId"] is List ? true : false,
                    product: product,
                    isSelected: _selectedProducts[product.id] ?? false,
                    quantity: _productQuantities[product.id] ?? 0,
                    onSelectionChanged: () {
                      if (widget.role == "picker" &&
                          (widget.machineDetails[0]['state'] == "picked" || widget.machineDetails[0]['state'] == "filled")) {
                        return;
                      }
                      if (widget.role != "picker" && widget.machineDetails[0]['state'] == "filled") {
                        return;
                      }

                      setState(() {
                        _selectedProducts[product.id] = !(_selectedProducts[product.id] ?? false);
                        widget.role == "picker" ?
                        Provider.of<PickerDataProvider>(context,listen: false).pickerMachineProductDetails[index].isPicked = _selectedProducts[product.id]!:
                        Provider.of<PickerDataProvider>(context,listen: false).pickerMachineProductDetails[index].isFilled = _selectedProducts[product.id]!;
                        if (_selectedProducts[product.id]!) {
                          _productQuantities[product.id] = product.pickAmount;
                        } else {
                          _productQuantities[product.id] = 0;
                        }
                        _updateTotalPickedItems();
                      });
                    },
                    onQuantityChanged: (newQuantity) {
                      setState(() {
                        _productQuantities[product.id] = newQuantity;
                        _updateTotalPickedItems();
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: AppColors.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              _searchQuery.isNotEmpty ? 'No products found' : 'No products available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try adjusting your search or scan a barcode'
                  : 'Products will appear here when available',
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear Search'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    if (widget.role == "picker" && widget.machineDetails[0]['state'] == "picked"){
      return SizedBox();
    }
    if (widget.role != "picker" && widget.machineDetails[0]['state'] == "filled"){
      return SizedBox();
    }
    return Container(
      padding: const EdgeInsets.all(16),
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
              child: OutlinedButton(
                onPressed: _clearAllSelections,
                child: Text('Clear All'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _confirmSelection,
                child: Text(
                  widget.role == "picker"
                      ? 'Confirm'
                      : 'Confirm',
                ),
              ),
            ),
          ],
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
      _updateTotalPickedItems();
    });
  }

  void _confirmSelection() {
    if (widget.role != "picker" && productsList.length != _selectedCount) {
      showSuccessMessage(context, "Please fill all products before proceeding");
      return;
    }

    final selectedProducts = productsList.where(
            (product) => _selectedProducts[product.id] == true
    ).toList();

    if (selectedProducts.isEmpty) return;

    if (widget.role != "picker") {
      FillerOperationConfirmationFormSheet().openDraggableSheet(
        context,
        selectedProducts: selectedProducts,
        totalPickedItem: totalPickedItem,
        role: widget.role,
        onConfirm: (fillerRequiredData) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const LoadingOverlay(),
          );
          fillerRequiredData["state"] = "filled";
          fillerRequiredData["machineId"] = widget.machineDetails[0]['pickListId'];
          _handleSubmission(widget.role, fillerRequiredData,selectedProducts);
          Navigator.pop(context);
        },
      );
    } else {
      Map pickerRequiredData ={};
      pickerRequiredData["state"] = "picked";
      _handleSubmission(widget.role, pickerRequiredData,selectedProducts);
    }
  }

  void _handleSubmission(String role, requiredData,List selectedProducts) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const LoadingOverlay(),
      );
      List<int> pickListIds;

      if (widget.machineDetails[0]["pickListId"] is List) {
        pickListIds = widget.machineDetails[0]["pickListId"];
      } else {
        pickListIds = [widget.machineDetails[0]["pickListId"]];
      }
      bool success = await Provider.of<PickerDataProvider>(context, listen: false)
          .savePickerMachineProductData(widget.role, pickListIds,requiredData);

      if (success) {
        Navigator.pop(context, true);
        Provider.of<PickerDataProvider>(context, listen: false)
            .updateMachinePickListState(pickListIds, "picked");
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Operation completed successfully!'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error in _handleSubmission: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}