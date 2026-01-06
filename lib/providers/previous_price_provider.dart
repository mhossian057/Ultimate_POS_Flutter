import 'package:flutter/material.dart';

import '../apis/previous_price.dart';
import '../helpers/otherHelpers.dart';

class PreviousPriceProvider extends ChangeNotifier {
  final PreviousPriceApi _api = PreviousPriceApi();
  
  // Static cache to persist across widget rebuilds
  static final Map<String, Map<String, dynamic>> _cache = {};
  static final Map<String, DateTime> _cacheTimestamp = {};
  static const int _cacheExpirationHours = 24; // Cache expires after 24 hours
  
  Map<String, dynamic>? _previousPriceData;
  bool _isLoading = false;
  String? _error;
  bool _isDisposed = false;
  bool _hasAttemptedFetch = false;
  DateTime? _lastFailedAttempt;
  String? _currentCacheKey;

  Map<String, dynamic>? get previousPriceData => _previousPriceData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String _getCacheKey(int variationId, int customerId, int locationId) {
    return '$variationId-$customerId-$locationId';
  }

  bool _isCacheValid(String cacheKey) {
    if (!_cacheTimestamp.containsKey(cacheKey)) return false;
    
    final cacheTime = _cacheTimestamp[cacheKey]!;
    final now = DateTime.now();
    return now.difference(cacheTime).inHours < _cacheExpirationHours;
  }

  Future<void> fetchPreviousPrice({
    required int variationId,
    required int customerId,
    required int locationId,
  }) async {
    if (_isDisposed) return; // Don't proceed if disposed
    
    _currentCacheKey = _getCacheKey(variationId, customerId, locationId);
    
    // Check cache first
    if (_cache.containsKey(_currentCacheKey) && _isCacheValid(_currentCacheKey!)) {
      _previousPriceData = _cache[_currentCacheKey!];
      _isLoading = false;
      _hasAttemptedFetch = true;
      _error = null;
      notifyListeners();
      return;
    }
    
    // Check if already attempted fetch or failed recently
    if (_hasAttemptedFetch) return;
    
    // Don't retry if failed within last 30 seconds to prevent spam
    if (_lastFailedAttempt != null && 
        DateTime.now().difference(_lastFailedAttempt!).inSeconds < 30) {
      return;
    }
    
    // Check connectivity before making API call
    bool isConnected = await Helper().checkConnectivity();
    if (!isConnected) {
      if (!_isDisposed) {
        _hasAttemptedFetch = true;
        _error = 'No internet connection';
        _isLoading = false;
        _lastFailedAttempt = DateTime.now();
        notifyListeners();
      }
      return;
    }
    
    _isLoading = true;
    _error = null;
    _hasAttemptedFetch = true;
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
        
        // Cache the result
        if (result != null && _currentCacheKey != null) {
          _cache[_currentCacheKey!] = result;
          _cacheTimestamp[_currentCacheKey!] = DateTime.now();
        }
        
        notifyListeners();
      }
    } catch (e) {
      if (!_isDisposed) { // Check if still mounted before updating
        _error = e.toString();
        _isLoading = false;
        _previousPriceData = null;
        _lastFailedAttempt = DateTime.now();
        notifyListeners();
      }
    }
  }

  void clearPreviousPrice() {
    _previousPriceData = null;
    _error = null;
    _isLoading = false;
    _hasAttemptedFetch = false;
    _lastFailedAttempt = null;
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