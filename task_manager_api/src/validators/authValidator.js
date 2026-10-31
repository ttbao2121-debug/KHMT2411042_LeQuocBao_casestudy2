const { body } = require('express-validator');

exports.registerValidation = [
  body('name').notEmpty().withMessage('Vui lòng nhập họ và tên'),
  body('email').isEmail().withMessage('Vui lòng nhập email hợp lệ'),
  body('password').isLength({ min: 6 }).withMessage('Mật khẩu phải có ít nhất 6 ký tự'),
];

exports.loginValidation = [
  body('email').isEmail().withMessage('Vui lòng nhập email hợp lệ'),
  body('password').notEmpty().withMessage('Vui lòng nhập mật khẩu'),
];
