import 'package:flutter/material.dart';

import '../apis/previous_price.dart';

class PreviousPriceProvider extends ChangeNotifier {
  final PreviousPriceApi _api = PreviousPriceApi();
  
  Map<String, dynamic>? _previousPriceData;
  bool _isLoading = false;
  String? _error;
  bool _isDisposed = false;

  Map<String, dynamic>? get previousPriceData => _previousPriceData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPreviousPrice({
    required int variationId,
    required int customerId,
    required int locationId,
  }) async {
    if (_isDisposed) return; // Don't proceed if disposed
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _api.getPreviousPrice(
        variationId: variationId,
        customerId: customerId,
        locationId: locationId,
      );

      if (!_isDisposed) { // Check if still mounted before updating
        _previousPriceData = result;
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      if (!_isDisposed) { // Check if still mounted before updating
        _error = e.toString();
        _isLoading = false;
        _previousPriceData = null;
        notifyListeners();
      }
    }
  }

  void clearPreviousPrice() {
    _previousPriceData = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  double? get unitPrice => _previousPriceData != null 
    ? double.tryParse(_previousPriceData!['unit_price']?.toString() ?? '0')
    : null;

  double? get unitPriceIncTax => _previousPriceData != null
    ? double.tryParse(_previousPriceData!['unit_price_inc_tax']?.toString() ?? '0')
    : null;

  double? get quantity => _previousPriceData != null
    ? double.tryParse(_previousPriceData!['quantity']?.toString() ?? '0')
    : null;

  String? get transactionId => _previousPriceData?['transaction_id']?.toString();

  bool get hasPreviousPrice => _previousPriceData != null;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}