import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Centralized error handling utility
class ErrorHandler {
  /// Parse Firebase Auth errors into user-friendly messages
  static String parseFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'invalid-credential':
        return 'Invalid email or password';
      case 'email-already-in-use':
        return 'An account already exists for this email';
      case 'weak-password':
        return 'The password is too weak. Use at least 6 characters';
      case 'operation-not-allowed':
        return 'This operation is not allowed';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Check your internet connection';
      default:
        return 'Authentication failed: ${e.message ?? "Unknown error"}';
    }
  }

  /// Show error snackbar
  static void showError(
    BuildContext context,
    String message, {
    int durationSeconds = 3,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: durationSeconds),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show success snackbar
  static void showSuccess(
    BuildContext context,
    String message, {
    int durationSeconds = 2,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(0xFF1db854),
        duration: Duration(seconds: durationSeconds),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show warning snackbar
  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(0xFFffa726),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Generic error dialog
  static void showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text(title, style: TextStyle(color: Colors.black87)),
          ],
        ),
        content: Text(message, style: TextStyle(color: Colors.black54)),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              child: Text('Retry', style: TextStyle(color: Color(0xFF1db854))),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  /// Parse network errors
  static String parseNetworkError(dynamic error) {
    if (error.toString().contains('SocketException') ||
        error.toString().contains('Failed host lookup')) {
      return 'No internet connection. Please check your network.';
    } else if (error.toString().contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    } else if (error.toString().contains('FormatException')) {
      return 'Invalid data received from server.';
    } else {
      return 'Network error: ${error.toString()}';
    }
  }

  /// Retry helper with exponential backoff
  static Future<T> retryOperation<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    Duration delay = initialDelay;

    while (attempts < maxAttempts) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts >= maxAttempts) {
          rethrow;
        }
        await Future.delayed(delay);
        delay *= 2; // Exponential backoff
      }
    }

    throw Exception('Max retry attempts reached');
  }
}
