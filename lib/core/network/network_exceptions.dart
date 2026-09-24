import 'package:dio/dio.dart';
import '../constants/app_strings.dart';

class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const NetworkException({
    required this.message,
    this.statusCode,
    this.data,
  });

  factory NetworkException.fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          message: AppStrings.timeoutError,
          statusCode: 408,
        );

      case DioExceptionType.badResponse:
        final status = dioError.response?.statusCode;
        final resData = dioError.response?.data;
        String extractedMsg = '';

        if (resData is Map) {
          extractedMsg = resData['message']?.toString() ??
              resData['error']?.toString() ??
              '';
        }

        if (extractedMsg.isNotEmpty) {
          return NetworkException(
            message: extractedMsg,
            statusCode: status,
            data: resData,
          );
        }

        switch (status) {
          case 400:
            return NetworkException(
              message: 'Invalid request. Please check your inputs.',
              statusCode: status,
              data: resData,
            );
          case 401:
            return NetworkException(
              message: AppStrings.unauthorizedError,
              statusCode: status,
              data: resData,
            );
          case 403:
            return NetworkException(
              message: 'Access denied. You do not have permission.',
              statusCode: status,
              data: resData,
            );
          case 404:
            return NetworkException(
              message: 'Requested resource not found.',
              statusCode: status,
              data: resData,
            );
          case 409:
            return NetworkException(
              message: 'An account with this email already exists.',
              statusCode: status,
              data: resData,
            );
          case 500:
          case 502:
          case 503:
            return NetworkException(
              message: AppStrings.serverError,
              statusCode: status,
              data: resData,
            );
          default:
            return NetworkException(
              message: 'Unexpected server response ($status).',
              statusCode: status,
              data: resData,
            );
        }

      case DioExceptionType.cancel:
        return const NetworkException(message: 'Request was cancelled.');

      case DioExceptionType.connectionError:
        return const NetworkException(
          message: AppStrings.noInternetError,
        );

      case DioExceptionType.badCertificate:
        return const NetworkException(
          message: 'SSL Certificate validation failed.',
        );

      case DioExceptionType.unknown:
      default:
        if (dioError.message?.contains('SocketException') ?? false) {
          return const NetworkException(
            message: AppStrings.noInternetError,
          );
        }
        return const NetworkException(
          message: AppStrings.unknownError,
        );
    }
  }

  @override
  String toString() => message;
}
