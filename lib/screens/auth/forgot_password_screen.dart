import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isOtpSent = false;
  bool _isLoading = false;
  bool _isPasswordObscured = true;

  // Quy chuẩn Phối màu
  static const Color primaryColor = Color(0xFFFB8C00);
  static const Color gradientStart = Color(0xFFFFF8E1);
  static const Color gradientEnd = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color errorColor = Color(0xFFE53935);
  static const Color borderColor = Color(0xFFE0E0E0);

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _sendOtp() async {
    if (_emailFormKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        await _authService.forgotPassword(_emailController.text);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mã OTP khôi phục đã được gửi đến Email của bạn!'),
              backgroundColor: primaryColor,
            ),
          );
          setState(() {
            _isOtpSent = true;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: errorColor,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _resetPassword() async {
    if (_resetFormKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        await _authService.resetPassword(
          _emailController.text,
          _otpController.text,
          _newPasswordController.text,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đặt lại mật khẩu thành công! Vui lòng đăng nhập.'),
              backgroundColor: primaryColor,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: errorColor,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Khôi phục mật khẩu', style: textTheme.headlineMedium?.copyWith(color: Colors.white)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [gradientStart, gradientEnd],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: !_isOtpSent ? _buildEmailStep(textTheme) : _buildResetStep(textTheme),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailStep(TextTheme textTheme) {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_reset_outlined,
                size: 48,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Quên mật khẩu?',
            textAlign: TextAlign.center,
            style: textTheme.displayMedium?.copyWith(
              fontSize: 26,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhập email của bạn để nhận mã OTP 6 chữ số khôi phục mật khẩu.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: textSecondary, height: 1.4),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: textTheme.bodyLarge?.copyWith(color: textPrimary),
            decoration: InputDecoration(
              hintText: 'Nhập email đã đăng ký',
              hintStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
              prefixIcon: const Icon(Icons.email_outlined, color: primaryColor),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: primaryColor, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập email của bạn';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                return 'Email không hợp lệ';
              }
              return null;
            },
          ),
          const SizedBox(height: 28),
          Container(
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : Text('Gửi mã OTP', style: textTheme.labelLarge?.copyWith(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetStep(TextTheme textTheme) {
    return Form(
      key: _resetFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_read_outlined,
                size: 48,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Nhập mã OTP & Mật khẩu mới',
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(
              fontSize: 22,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mã OTP đã được gửi tới ${_emailController.text}. Vui lòng kiểm tra Hộp thư đến.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: textSecondary, height: 1.4),
          ),
          const SizedBox(height: 28),
          TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            style: textTheme.headlineMedium?.copyWith(color: textPrimary, letterSpacing: 4),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '123456',
              counterText: '',
              hintStyle: textTheme.bodyMedium?.copyWith(letterSpacing: 0),
              prefixIcon: const Icon(Icons.pin, color: primaryColor),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: borderColor),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().length != 6) {
                return 'Vui lòng nhập đủ 6 chữ số mã OTP';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _newPasswordController,
            obscureText: _isPasswordObscured,
            style: textTheme.bodyLarge?.copyWith(color: textPrimary),
            decoration: InputDecoration(
              hintText: 'Nhập mật khẩu mới',
              prefixIcon: const Icon(Icons.lock_outlined, color: primaryColor),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: textSecondary,
                ),
                onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) {
              if (value == null || value.length < 6) {
                return 'Mật khẩu phải có ít nhất 6 ký tự';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _isPasswordObscured,
            style: textTheme.bodyLarge?.copyWith(color: textPrimary),
            decoration: InputDecoration(
              hintText: 'Xác nhận mật khẩu mới',
              prefixIcon: const Icon(Icons.lock_reset_outlined, color: primaryColor),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) {
              if (value != _newPasswordController.text) {
                return 'Mật khẩu xác nhận không trùng khớp';
              }
              return null;
            },
          ),
          const SizedBox(height: 28),
          Container(
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : Text('Đặt lại mật khẩu', style: textTheme.labelLarge?.copyWith(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
