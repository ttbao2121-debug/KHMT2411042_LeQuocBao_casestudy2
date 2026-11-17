const User = require('../models/User');
const PendingRegistration = require('../models/PendingRegistration');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const emailService = require('../services/emailService');
const emailTemplates = require('../utils/emailTemplates');

exports.sendRegisterOTP = async (req, res, next) => {
  try {
    const { email } = req.body;
    const cleanEmail = email.trim().toLowerCase();

    const existingUser = await User.findOne({ email: cleanEmail });
    if (existingUser) {
      return res.status(400).json({ message: 'Email này đã được sử dụng. Vui lòng sử dụng email khác hoặc Đăng nhập.' });
    }

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 15 * 60 * 1000);

    await PendingRegistration.findOneAndUpdate(
      { email: cleanEmail },
      { email: cleanEmail, otp, expiresAt },
      { upsert: true, new: true }
    );

    emailService.sendNotificationEmail({
      recipientEmail: cleanEmail,
      eventType: 'REGISTER_OTP',
      subject: '[TaskManager] Mã OTP xác thực Email đăng ký',
      html: emailTemplates.registerOTPTemplate(cleanEmail, otp),
    });

    res.json({ message: 'Mã OTP xác thực đã được gửi đến email của bạn!' });
  } catch (error) {
    next(error);
  }
};

exports.register = async (req, res, next) => {
  try {
    const { fullName, name, email, password, otp } = req.body;
    const userFullName = fullName || name;
    const cleanEmail = email.trim().toLowerCase();

    const existingUser = await User.findOne({ email: cleanEmail });
    if (existingUser) {
      return res.status(400).json({ message: 'Email này đã được sử dụng' });
    }

    if (otp) {
      const pending = await PendingRegistration.findOne({ email: cleanEmail, otp: otp.trim() });
      if (!pending) {
        return res.status(400).json({ message: 'Mã OTP xác thực Email không chính xác hoặc đã hết hạn' });
      }
      await PendingRegistration.deleteMany({ email: cleanEmail });
    }

    const passwordHash = await bcrypt.hash(password, 10);
    const user = await User.create({ fullName: userFullName, email: cleanEmail, passwordHash });

    emailService.sendNotificationEmail({
      recipientEmail: user.email,
      eventType: 'WELCOME',
      subject: 'Chào mừng đến với TaskManager',
      html: emailTemplates.welcomeTemplate(user.fullName),
    });

    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET || 'your_jwt_secret_key_here', {
      expiresIn: process.env.JWT_EXPIRES_IN || '7d',
    });

    res.status(201).json({
      message: 'Đăng ký thành công',
      token,
      user: { id: user._id, fullName: user.fullName, email: user.email },
    });
  } catch (error) {
    next(error);
  }
};

exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email: email.trim().toLowerCase() });
    if (!user) {
      return res.status(400).json({ message: 'Email hoặc mật khẩu không chính xác' });
    }

    const isMatch = await bcrypt.compare(password, user.passwordHash);
    if (!isMatch) {
      return res.status(400).json({ message: 'Email hoặc mật khẩu không chính xác' });
    }

    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET || 'your_jwt_secret_key_here', {
      expiresIn: process.env.JWT_EXPIRES_IN || '7d',
    });

    res.json({
      message: 'Đăng nhập thành công',
      token,
      user: { id: user._id, fullName: user.fullName, email: user.email },
    });
  } catch (error) {
    next(error);
  }
};

exports.forgotPassword = async (req, res, next) => {
  try {
    const { email } = req.body;
    const user = await User.findOne({ email: email.trim().toLowerCase() });
    if (!user) {
      return res.status(404).json({ message: 'Email này chưa được đăng ký trong hệ thống' });
    }

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    user.resetPasswordOTP = otp;
    user.resetPasswordExpires = Date.now() + 15 * 60 * 1000;
    await user.save();

    emailService.sendNotificationEmail({
      recipientEmail: user.email,
      eventType: 'FORGOT_PASSWORD',
      subject: '[TaskManager] Mã OTP khôi phục mật khẩu',
      html: emailTemplates.forgotPasswordOTPTemplate(user.fullName, otp),
    });

    res.json({ message: 'Mã OTP khôi phục mật khẩu đã được gửi đến email của bạn!' });
  } catch (error) {
    next(error);
  }
};

exports.resetPassword = async (req, res, next) => {
  try {
    const { email, otp, newPassword } = req.body;
    const user = await User.findOne({ email: email.trim().toLowerCase() });
    if (!user) {
      return res.status(404).json({ message: 'Email không tồn tại trong hệ thống' });
    }

    if (!user.resetPasswordOTP || user.resetPasswordOTP !== otp.trim()) {
      return res.status(400).json({ message: 'Mã OTP không chính xác' });
    }

    if (user.resetPasswordExpires && user.resetPasswordExpires < Date.now()) {
      return res.status(400).json({ message: 'Mã OTP đã hết hạn (chỉ có hiệu lực trong 15 phút)' });
    }

    user.passwordHash = await bcrypt.hash(newPassword, 10);
    user.resetPasswordOTP = null;
    user.resetPasswordExpires = null;
    await user.save();

    res.json({ message: 'Đặt lại mật khẩu thành công! Vui lòng đăng nhập lại.' });
  } catch (error) {
    next(error);
  }
};

exports.getMe = async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id).select('-passwordHash');
    res.json(user);
  } catch (error) {
    next(error);
  }
};

exports.updateMe = async (req, res, next) => {
  try {
    const { fullName, avatarUrl } = req.body;
    const user = await User.findByIdAndUpdate(req.user.id, { fullName, avatarUrl }, { new: true }).select('-passwordHash');
    res.json(user);
  } catch (error) {
    next(error);
  }
};

exports.changePassword = async (req, res, next) => {
  try {
    const { oldPassword, newPassword } = req.body;
    const user = await User.findById(req.user.id);
    if (!user) return res.status(404).json({ message: 'Không tìm thấy người dùng' });

    const isMatch = await bcrypt.compare(oldPassword, user.passwordHash);
    if (!isMatch) {
      return res.status(400).json({ message: 'Mật khẩu cũ không chính xác' });
    }

    user.passwordHash = await bcrypt.hash(newPassword, 10);
    await user.save();

    res.json({ message: 'Đổi mật khẩu thành công' });
  } catch (error) {
    next(error);
  }
};
