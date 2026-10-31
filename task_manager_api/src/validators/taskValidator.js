const { body } = require('express-validator');

exports.taskValidation = [
  body('title').notEmpty().withMessage('Vui lòng nhập tiêu đề công việc'),
  body('dueDate').isISO8601().withMessage('Vui lòng nhập ngày hạn chót hợp lệ'),
];
