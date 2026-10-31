const { body } = require('express-validator');

exports.registerValidation = [
  body('email').isEmail().withMessage('Vui lòng nhập email hợp lệ'),
  body('password').isLength({ min: 6 }).withMessage('Mật khẩu phải có ít nhất 6 ký tự'),
  body().custom((value, { req }) => {
    if (!req.body.fullName && !req.body.name) {
      throw new Error('Vui lòng nhập họ và tên (fullName)');
    }
    return true;
  }),
];

exports.loginValidation = [
  body('email').isEmail().withMessage('Vui lòng nhập email hợp lệ'),
  body('password').notEmpty().withMessage('Vui lòng nhập mật khẩu'),
];
