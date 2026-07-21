import 'package:flutter/foundation.dart';
import 'package:church/core/constants/app_constants.dart';
import 'package:church/core/logger/app_logger.dart';
import 'package:dio/dio.dart';

const _tag = 'TelebirrService';

// Set to true once you have real Telebirr API credentials configured.
// While false, all calls return a local mock so the payment UI works without
// hitting api.ethiotelecom.et.
const _telebirrConfigured = false;

class TelebirrService {
  TelebirrService() {
    if (_telebirrConfigured) {
      _dio.interceptors.add(DioLogInterceptor(tag: _tag));
    }
  }

  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.telebirrBaseUrl,
    connectTimeout: const Duration(seconds: 10),
  ));

  Future<Map<String, dynamic>> sendPaymentRequest({
    required String outTradeNo,
    required double amount,
    required String subject,
  }) async {
    log.i(_tag, 'sendPaymentRequest outTradeNo=$outTradeNo amount=$amount');

    // ── Not configured → return mock immediately ────────────────────────
    if (!_telebirrConfigured || kDebugMode) {
      log.d(_tag, '[MOCK] Telebirr not configured — returning stub payload');
      await Future.delayed(const Duration(milliseconds: 600));
      return {
        'success':    true,
        'tradeNo':    'TB-MOCK-${DateTime.now().millisecondsSinceEpoch}',
        'paymentUrl': 'https://telebirr.et/pay-stub',
        'mock':       true,
      };
    }

    try {
      final response = await _dio.post(
        '/api/payment',
        data: {
          'outTradeNo': outTradeNo,
          'amount':     amount.toString(),
          'subject':    subject,
          'currency':   'ETB',
          'appKey':     AppConstants.telebirrAppKey,
          'appSecret':  AppConstants.telebirrAppSecret,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        return {
          'success':    true,
          'tradeNo':    response.data['tradeNo'],
          'paymentUrl': response.data['paymentUrl'],
        };
      }
      log.w(_tag, 'sendPaymentRequest unexpected status=${response.statusCode}');
      return {'success': false, 'message': 'Payment request failed'};
    } on DioException catch (e, stack) {
      log.e(_tag, 'sendPaymentRequest network error', error: e, stack: stack);
      return {'success': false, 'message': 'Network error. Try again.'};
    }
  }

  Future<bool> checkTransactionStatus(String tradeNo) async {
    // Mock trade numbers always succeed
    if (!_telebirrConfigured || kDebugMode || tradeNo.startsWith('TB-MOCK')) {
      log.d(_tag, '[MOCK] checkTransactionStatus tradeNo=$tradeNo → true');
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    }

    log.d(_tag, 'checkTransactionStatus tradeNo=$tradeNo');
    try {
      final response = await _dio.get('/api/transaction/status/$tradeNo');
      return response.statusCode == 200;
    } on DioException catch (e, stack) {
      log.e(_tag, 'checkTransactionStatus network error', error: e, stack: stack);
      return false;
    }
  }
}
