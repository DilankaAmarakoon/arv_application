import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_mangement/Models/basket_details_model.dart';
import 'package:staff_mangement/constants/theme.dart';
import 'package:staff_mangement/providers/picker_filler_data_provider.dart';
import '../servicess/barcode_scanner_service.dart';

Future<List<int>?> showScanBasketDialog(BuildContext context,List<dynamic> basketNumberList) {
  return showDialog<List<int>>(
    context: context,
    barrierDismissible: false,
    builder: (context) =>  ScanBasketDialog(basketNumberList: basketNumberList),
  );
}

class ScanBasketDialog extends StatefulWidget {
  List<dynamic> basketNumberList;
   ScanBasketDialog({Key? key,required this.basketNumberList}) : super(key: key);

  @override
  State<ScanBasketDialog> createState() => _ScanBasketDialogState();
}

class _ScanBasketDialogState extends State<ScanBasketDialog> {
  List<Map<String, dynamic>> _scannedBaskets = [];
  List<int> _savedBasketNumberList =[];
  late BarcodeScannerService _barcodeService;
  bool _isScannerEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadBasketDetails();
    _initializeBarcodeScanner();
  }

  @override
  void dispose() {
    _barcodeService.dispose();
    super.dispose();
  }
  _loadBasketDetails()async{
    _scannedBaskets = [];
    _savedBasketNumberList =[];
    if(widget.basketNumberList.isNotEmpty){
      for(int i =0; i<widget.basketNumberList.length; i++){
        for(BasketDetailsModel item in Provider.of<PickerDataProvider>(context,listen: false).basketData){
          if(item.id == widget.basketNumberList[i]){
            _scannedBaskets.add({
              "id": item.id,
              "code": item.code,
            });
            _savedBasketNumberList.add(item.id);
          }
        }
      }
    }
  }
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
      print('Barcode scanner initialized successfully for basket scanning');
    } else {
      print('Failed to initialize barcode scanner');
    }
  }

  void _handleBarcodeScanned(String barcode){
    print("opop....$barcode");
    if (barcode.isNotEmpty && !_isBasketAlreadyScanned(barcode)) {
      print("ioooooo");
          for(BasketDetailsModel item in Provider.of<PickerDataProvider>(context,listen: false).basketData){
            if(item.code == barcode){
              _scannedBaskets.add({
                "id": item.id,
                "code": item.code,
              });
              _savedBasketNumberList.add(item.id);
            }
          }
      setState(() {});
    } else if (_isBasketAlreadyScanned(barcode)) {
      // Show a brief message that this basket is already scanned
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Basket $barcode already scanned'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

// Helper method to check if basket is already scanned
  bool _isBasketAlreadyScanned(String barcode) {
    return _scannedBaskets.any((basket) => basket["code"] == barcode);
  }

  void _removeScannedBasket(int index) {
    setState(() {
      _scannedBaskets.removeAt(index);
      _savedBasketNumberList.removeAt(index);
    });
  }

  void _onConfirm() {
    if (_scannedBaskets.isNotEmpty) {
      Navigator.of(context).pop(_savedBasketNumberList);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("ioo.>>${_scannedBaskets.length}");
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 400,
                  ),
                  child: Material(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header icon
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary.withOpacity(0.1),
                                  theme.colorScheme.primary.withOpacity(0.05),
                                ],
                              ),
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(
                                    0.2),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Icon(
                              Icons.qr_code_scanner,
                              color: theme.colorScheme.primary,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Title
                          Text(
                            'Scan Basket Code',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                              color: theme.colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),

                          // Message/Subtitle
                          Text(
                            _isScannerEnabled
                                ? 'Scanner ready - scan basket barcodes with your device'
                                : 'Initializing scanner...',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                  0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          // Scanner status indicator
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _isScannerEnabled
                                      ? Colors.green
                                      : Colors.orange,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isScannerEnabled
                                    ? 'Scanner Active'
                                    : 'Scanner Initializing',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: _isScannerEnabled
                                      ? Colors.green
                                      : Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Scanned baskets list or empty state
                          if (_scannedBaskets.isNotEmpty) ...[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Scanned Basket Numbers:',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(maxHeight: 200),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListView.separated(
                                shrinkWrap: true,
                                padding: const EdgeInsets.all(8),
                                itemCount: _scannedBaskets.length,
                                separatorBuilder: (context,
                                    index) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final isLatest = index ==
                                      _scannedBaskets.length - 1;
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    decoration: BoxDecoration(
                                      color: isLatest ? theme.colorScheme
                                          .primary.withOpacity(0.05) : null,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ListTile(
                                      dense: true,
                                      leading: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                              16),
                                        ),
                                        child: Icon(
                                          Icons.shopping_basket_outlined,
                                          color: theme.colorScheme.primary,
                                          size: 16,
                                        ),
                                      ),
                                      title: Text(
                                        _scannedBaskets[index]["code"],
                                        style: TextStyle(
                                          fontWeight: isLatest
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          fontSize: 14,
                                          color: isLatest ? theme.colorScheme
                                              .primary : null,
                                        ),
                                      ),
                                      trailing: IconButton(
                                        onPressed: () =>
                                            _removeScannedBasket(index),
                                        icon: Icon(
                                          Icons.remove_circle_outline,
                                          color: Colors.red.shade400,
                                          size: 20,
                                        ),
                                        tooltip: 'Remove basket',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ] else
                            ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.qr_code_2,
                                      size: 48,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No baskets scanned yet',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Point your Zebra TC22 at a basket barcode',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                          const SizedBox(height: 24),

                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    foregroundColor: Colors.grey.shade700,
                                    side: BorderSide(
                                        color: Colors.grey.shade300),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _scannedBaskets.isEmpty
                                      ? null
                                      : _onConfirm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    elevation: 2,
                                    shadowColor: theme.colorScheme.primary
                                        .withOpacity(0.3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.check, size: 18),
                                  label: Text(
                                    'Confirm (${_scannedBaskets.length})',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}