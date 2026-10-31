import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFFB8C00); // Amber / Orange
  static const Color gradientStart = Color(0xFFFFF8E1); // Vàng kem nhạt
  static const Color gradientEnd = Color(0xFFFFFFFF); // Trắng
  static const Color textPrimary = Color(0xFF212121); // Đen xám đậm
  static const Color textSecondary = Color(0xFF757575); // Xám trung tính
  static const Color error = Color(0xFFE53935); // Đỏ cảnh báo
  static const Color border = Color(0xFFE0E0E0); // Viền xám nhạt

  // Status Colors
  static const Color statusPending = Color(0xFFFFB74D);
  static const Color statusInProgress = Color(0xFF29B6F6);
  static const Color statusCompleted = Color(0xFF66BB6A);

  // Priority Colors
  static const Color priorityLow = Color(0xFF81C784);
  static const Color priorityMedium = Color(0xFFFFB74D);
  static const Color priorityHigh = Color(0xE5E53935);
}

class AppStrings {
  static const String appName = 'TaskManager';
  static const String loginGreeting = 'Chào mừng bạn trở lại! Hãy đăng nhập để quản lý công việc hiệu quả.';
  static const String registerGreeting = 'Đăng ký để bắt đầu trải nghiệm ứng dụng TaskManager.';
}

class AppConstants {
  // Dành cho Android Emulator: 'http://10.0.2.2:5000/api'
  // Dành cho Thiết bị thật / Web: 'http://<IP_MÁY_TÍNH>:5000/api'
  static const String baseUrl = 'http://10.0.2.2:5000/api';
}
