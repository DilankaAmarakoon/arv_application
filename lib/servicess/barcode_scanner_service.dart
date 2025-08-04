// lib/servicess/barcode_scanner_service.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';

class BarcodeScannerService extends ChangeNotifier {
  FlutterDataWedge? _dataWedge;
  StreamSubscription<ScanResult>? _scanSubscription;

  String _lastScannedCode = '';
  bool _isInitialized = false;
  bool _isScanning = false;
  bool _isEnabled = true;

  // Getters
  String get lastScannedCode => _lastScannedCode;
  bool get isInitialized => _isInitialized;
  bool get isScanning => _isScanning;
  bool get isEnabled => _isEnabled;

  // Stream controller for barcode results
  final StreamController<String> _barcodeController =
  StreamController<String>.broadcast();

  Stream<String> get barcodeStream => _barcodeController.stream;

  // Scanner configuration
  static const String PROFILE_NAME = "FlutterPickerProfile";

  /// Initialize the DataWedge scanner
  Future<bool> initialize() async {
    try {
      print('Initializing DataWedge scanner...');

      _dataWedge = FlutterDataWedge();
      await _dataWedge!.initialize();

      // Create profile for your app
      await _dataWedge!.createDefaultProfile(profileName: PROFILE_NAME);

      // Listen for scan results
      _scanSubscription = _dataWedge!.onScanResult.listen((ScanResult result) {
        _handleScanResult(result);
      });

      _isInitialized = true;
      notifyListeners();

      print('DataWedge scanner initialized successfully');
      return true;
    } catch (e) {
      print('Error initializing scanner: $e');
      _isInitialized = false;
      notifyListeners();
      return false;
    }
  }

  /// Handle scan results with validation and filtering
  void _handleScanResult(ScanResult result) {
    if (!_isEnabled) {
      print('Scanner disabled, ignoring scan result');
      return;
    }

    if (result.data.isNotEmpty) {
      String scannedData = result.data.trim();

      // Validate barcode format if needed
      if (_isValidBarcode(scannedData)) {
        _lastScannedCode = scannedData;
        print('Valid barcode scanned: $scannedData');

        // Set scanning state to false since we got a result
        _isScanning = false;

        // Emit the barcode data to listeners
        _barcodeController.add(scannedData);
        notifyListeners();

        print('Barcode processed and sent to listeners');
      } else {
        print('Invalid barcode format: $scannedData');
        _handleInvalidBarcode(scannedData);
      }
    }
  }

  /// Validate barcode format
  bool _isValidBarcode(String barcode) {
    if (barcode.isEmpty) return false;

    // Basic validation - customize based on your barcode formats
    // Allow alphanumeric characters, hyphens, underscores, and spaces
    RegExp validPattern = RegExp(r'^[a-zA-Z0-9\-_\s\.]+$');

    // Check length (most barcodes are between 3-50 characters)
    if (barcode.length < 3 || barcode.length > 50) {
      return false;
    }

    return validPattern.hasMatch(barcode);
  }

  /// Handle invalid barcode scans
  void _handleInvalidBarcode(String invalidBarcode) {
    print('Invalid barcode detected: $invalidBarcode');
    // You can emit this to a separate stream for handling invalid barcodes
  }

  /// Enable or disable scanner
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    notifyListeners();
    print('Scanner ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Trigger software scan (limited support - hardware trigger recommended)
  Future<void> triggerScan() async {
    if (!_isInitialized || !_isEnabled) {
      print('Scanner not ready for software trigger');
      return;
    }

    try {
      _isScanning = true;
      notifyListeners();

      print('Scanner triggered (use hardware button for best results)');

      // Reset scanning state after timeout (10 seconds)
      Timer(Duration(seconds: 10), () {
        if (_isScanning) {
          _isScanning = false;
          notifyListeners();
          print('Scan timeout reached');
        }
      });
    } catch (e) {
      _isScanning = false;
      notifyListeners();
      print('Error triggering scan: $e');
    }
  }

  /// Clear last scanned barcode
  void clearLastScan() {
    _lastScannedCode = '';
    notifyListeners();
    print('Last scan cleared');
  }

  /// Get scanner status information
  Map<String, dynamic> getStatus() {
    return {
      'isInitialized': _isInitialized,
      'isScanning': _isScanning,
      'isEnabled': _isEnabled,
      'lastScannedCode': _lastScannedCode,
      'profileName': PROFILE_NAME,
    };
  }

  /// Dispose resources
  @override
  void dispose() {
    print('Disposing barcode scanner service...');

    _scanSubscription?.cancel();
    _barcodeController.close();

    super.dispose();
    print('Barcode scanner service disposed');
  }
}

/// Simple mixin for barcode scanning
mixin BarcodeScannerMixin<T extends StatefulWidget> on State<T> {
  BarcodeScannerService? _scannerService;
  StreamSubscription<String>? _barcodeSubscription;

  /// Initialize barcode scanner mixin
  Future<bool> initializeScanner({
    required Function(String) onBarcodeScanned,
  }) async {
    _scannerService = BarcodeScannerService();

    bool initialized = await _scannerService!.initialize();

    if (initialized) {
      _barcodeSubscription = _scannerService!.barcodeStream.listen(
        onBarcodeScanned,
        onError: (error) {
          print('Barcode stream error: $error');
        },
      );

      print('Scanner mixin initialized successfully');
      return true;
    } else {
      print('Failed to initialize scanner mixin');
      return false;
    }
  }

  /// Get scanner service instance
  BarcodeScannerService? get scannerService => _scannerService;

  /// Dispose scanner mixin resources
  void disposeScanner() {
    _barcodeSubscription?.cancel();
    _scannerService?.dispose();
    _scannerService = null;
  }

  @override
  void dispose() {
    disposeScanner();
    super.dispose();
  }
}