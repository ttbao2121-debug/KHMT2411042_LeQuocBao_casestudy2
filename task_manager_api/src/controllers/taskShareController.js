const TaskShare = require('../models/TaskShare');
const Task = require('../models/Task');
const User = require('../models/User');
const notificationService = require('../services/notificationService');
const emailService = require('../services/emailService');
const emailTemplates = require('../utils/emailTemplates');
const taskService = require('../services/taskService');

exports.getShares = async (req, res, next) => {
  try {
    const shares = await TaskShare.find({ taskId: req.params.id })
      .populate('userId', 'fullName email avatarUrl')
      .populate('sharedBy', 'fullName email');
    res.json(shares);
  } catch (error) {
    next(error);
  }
};

exports.createShare = async (req, res, next) => {
  try {
    const taskId = req.params.id;
    const { userId, userIds, permission } = req.body;
    const perm = permission || 'viewer';

    const targetUserIds = userIds && Array.isArray(userIds) ? userIds : [userId];
    const task = await Task.findById(taskId);
    const sharedByUser = await User.findById(req.user.id);

    const results = [];
    for (const uId of targetUserIds) {
      if (!uId) continue;
      const share = await TaskShare.findOneAndUpdate(
        { taskId, userId: uId },
        { taskId, userId: uId, permission: perm, sharedBy: req.user.id },
        { upsert: true, new: true }
      );
      results.push(share);

      // Sự kiện Gửi Email & Thông báo: Chia sẻ công việc (SHARE_TASK)
      const targetUser = await User.findById(uId);
      if (targetUser && task) {
        await notificationService.createNotification(
          targetUser._id,
          'Công việc được chia sẻ',
          `Bạn vừa được chia sẻ công việc "${task.title}".`,
          task._id
        );
        emailService.sendNotificationEmail({
          taskId: task._id,
          recipientEmail: targetUser.email,
          eventType: 'SHARE_TASK',
          subject: `[TaskManager] Công việc được chia sẻ: ${task.title}`,
          html: emailTemplates.taskSharedTemplate(targetUser.fullName, task.title, perm, sharedByUser?.fullName),
        });
      }
    }

    await taskService.logTaskActivity(taskId, req.user.id, 'Chia sẻ công việc', { targetUserIds, permission: perm });

    res.status(201).json(results);
  } catch (error) {
    next(error);
  }
};

exports.updateShare = async (req, res, next) => {
  try {
    const { shareId } = req.params;
    const { permission } = req.body;

    const share = await TaskShare.findByIdAndUpdate(shareId, { permission }, { new: true });
    if (!share) return res.status(404).json({ message: 'Không tìm thấy bản ghi chia sẻ' });

    res.json(share);
  } catch (error) {
    next(error);
  }
};

exports.deleteShare = async (req, res, next) => {
  try {
    const { shareId } = req.params;
    const share = await TaskShare.findByIdAndDelete(shareId);
    if (!share) return res.status(404).json({ message: 'Không tìm thấy bản ghi chia sẻ' });

    res.json({ message: 'Thu hồi quyền chia sẻ thành công' });
  } catch (error) {
    next(error);
  }
};
