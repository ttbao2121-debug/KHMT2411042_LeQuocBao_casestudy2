const Task = require('../models/Task');
const notificationService = require('../services/notificationService');
const emailService = require('../services/emailService');
const emailTemplates = require('../utils/emailTemplates');
const User = require('../models/User');

exports.assignTask = async (req, res, next) => {
  try {
    const { taskId, assigneeIds, primaryAssigneeId } = req.body;
    const updateData = {};
    if (assigneeIds) updateData.assigneeIds = assigneeIds;
    if (primaryAssigneeId) updateData.primaryAssigneeId = primaryAssigneeId;

    const task = await Task.findByIdAndUpdate(taskId, updateData, { new: true });
    if (!task) return res.status(404).json({ message: 'Không tìm thấy công việc' });

    const targetUserId = primaryAssigneeId || (assigneeIds && assigneeIds[0]);
    if (targetUserId) {
      const user = await User.findById(targetUserId);
      if (user) {
        await notificationService.createNotification(
          user._id,
          'Công việc mới được giao',
          `Bạn được giao công việc "${task.title}".`,
          task._id
        );
        emailService.sendEmail(
          user.email,
          'Công việc mới được giao',
          emailTemplates.taskAssignedTemplate(user.fullName, task.title)
        );
      }
    }

    res.json({ message: 'Phân công công việc thành công', task });
  } catch (error) {
    next(error);
  }
};
