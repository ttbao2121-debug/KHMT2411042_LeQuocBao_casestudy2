const Task = require('../models/Task');
const User = require('../models/User');
const notificationService = require('../services/notificationService');
const emailService = require('../services/emailService');
const emailTemplates = require('../utils/emailTemplates');
const taskService = require('../services/taskService');

exports.getAssignees = async (req, res, next) => {
  try {
    const task = await Task.findById(req.params.id)
      .populate('assigneeIds', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl');
    if (!task) return res.status(404).json({ message: 'Không tìm thấy công việc' });

    res.json({
      assignees: task.assigneeIds,
      primaryAssignee: task.primaryAssigneeId,
    });
  } catch (error) {
    next(error);
  }
};

exports.addAssignees = async (req, res, next) => {
  try {
    const { assigneeIds, primaryAssigneeId } = req.body;
    const task = await Task.findById(req.params.id);
    if (!task) return res.status(404).json({ message: 'Không tìm thấy công việc' });

    if (assigneeIds && Array.isArray(assigneeIds)) {
      assigneeIds.forEach((id) => {
        if (!task.assigneeIds.includes(id)) {
          task.assigneeIds.push(id);
        }
      });
    }

    if (primaryAssigneeId) {
      task.primaryAssigneeId = primaryAssigneeId;
      if (!task.assigneeIds.includes(primaryAssigneeId)) {
        task.assigneeIds.push(primaryAssigneeId);
      }
    }

    await task.save();
    await taskService.logTaskActivity(task._id, req.user.id, 'Giao việc mới', { assigneeIds, primaryAssigneeId });

    // Sự kiện Gửi Email & Thông báo: Giao việc mới (ASSIGN_TASK)
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
        emailService.sendNotificationEmail({
          taskId: task._id,
          recipientEmail: user.email,
          eventType: 'ASSIGN_TASK',
          subject: `[TaskManager] Giao việc mới: ${task.title}`,
          html: emailTemplates.taskAssignedTemplate(user.fullName, task.title, task.dueDate),
        });
      }
    }

    res.json({ message: 'Giao việc thành công', task });
  } catch (error) {
    next(error);
  }
};

exports.updateAssigneeRole = async (req, res, next) => {
  try {
    const { id, userId } = req.params;
    const { isPrimary } = req.body;

    const task = await Task.findById(id);
    if (!task) return res.status(404).json({ message: 'Không tìm thấy công việc' });

    if (isPrimary) {
      task.primaryAssigneeId = userId;
    } else if (task.primaryAssigneeId && task.primaryAssigneeId.toString() === userId) {
      task.primaryAssigneeId = null;
    }

    await task.save();
    await taskService.logTaskActivity(task._id, req.user.id, 'Cập nhật vai trò người phụ trách', { userId, isPrimary });

    res.json({ message: 'Cập nhật vai trò người phụ trách thành công', task });
  } catch (error) {
    next(error);
  }
};

exports.removeAssignee = async (req, res, next) => {
  try {
    const { id, userId } = req.params;
    const task = await Task.findById(id);
    if (!task) return res.status(404).json({ message: 'Không tìm thấy công việc' });

    task.assigneeIds = task.assigneeIds.filter((aId) => aId.toString() !== userId);
    if (task.primaryAssigneeId && task.primaryAssigneeId.toString() === userId) {
      task.primaryAssigneeId = null;
    }

    await task.save();
    await taskService.logTaskActivity(task._id, req.user.id, 'Hủy giao việc', { userId });

    res.json({ message: 'Hủy giao việc thành công', task });
  } catch (error) {
    next(error);
  }
};
