const Task = require('../models/Task');
const notificationService = require('../services/notificationService');
const emailService = require('../services/emailService');
const emailTemplates = require('../utils/emailTemplates');
const User = require('../models/User');

exports.assignTask = async (req, res, next) => {
  try {
    const { taskId, assignedToUserId } = req.body;
    const task = await Task.findByIdAndUpdate(taskId, { assignedTo: assignedToUserId }, { new: true });
    if (!task) return res.status(404).json({ message: 'Không tìm thấy công việc' });

    const user = await User.findById(assignedToUserId);
    if (user) {
      await notificationService.createNotification(
        assignedToUserId,
        'Công việc mới được giao',
        `Bạn được giao công việc "${task.title}".`
      );
      emailService.sendEmail(
        user.email,
        'Công việc mới được giao',
        emailTemplates.taskAssignedTemplate(user.name, task.title)
      );
    }

    res.json({ message: 'Phân công công việc thành công', task });
  } catch (error) {
    next(error);
  }
};
