import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';

class BarcodeScannerService extends ChangeNotifier {
  FlutterDataWedge? _dataWedge;
  StreamSubscription<ScanResult>? _scanSubscription;

  String _lastScannedCode = '';
  bool _isInitialized = false;
  bool _isScanning = false;

  // Getters
  String get lastScannedCode => _lastScannedCode;
  bool get isInitialized => _isInitialized;
  bool get isScanning => _isScanning;

  // Stream controller for barcode results
  final StreamController<String> _barcodeController =
  StreamController<String>.broadcast();

  Stream<String> get barcodeStream => _barcodeController.stream;

  /// Initialize the DataWedge scanner
  Future<bool> initialize() async {
    try {
      print('Initializing DataWedge scanner...');

      _dataWedge = FlutterDataWedge();
      await _dataWedge!.initialize();

      // Create profile for your app
      await _dataWedge!.createDefaultProfile(
          profileName: "FlutterBarcodeProfile"
      );

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

  /// Handle scan results
  void _handleScanResult(ScanResult result) {
    if (result.data.isNotEmpty) {
      _lastScannedCode = result.data;
      print('Barcode scanned: ${result.data}');

      // Emit the barcode data to listeners
      _barcodeController.add(result.data);
      notifyListeners();
    }
  }

  /// Trigger software scan (optional - hardware button is primary)
  Future<void> triggerScan() async {
    if (!_isInitialized) return;

    try {
      // await _dataWedge!.sendCommand(DataWedgeCommand.softScanTrigger);
      _isScanning = true;
      notifyListeners();

      // Reset scanning state after a delay
      Timer(Duration(seconds: 2), () {
        _isScanning = false;
        notifyListeners();
      });
    } catch (e) {
      print('Error triggering scan: $e');
    }
  }

  /// Dispose resources
  @override
  void dispose() {
    _scanSubscription?.cancel();
    // _dataWedge?.dispose();
    _barcodeController.close();
    super.dispose();
  }
}