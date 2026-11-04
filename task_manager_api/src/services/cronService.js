const Task = require('../models/Task');
const User = require('../models/User');
const EmailLog = require('../models/EmailLog');
const notificationService = require('./notificationService');
const emailService = require('./emailService');
const emailTemplates = require('../utils/emailTemplates');

const checkUpcomingDeadlines = async () => {
  try {
    const now = new Date();
    const next24Hours = new Date(now.getTime() + 24 * 60 * 60 * 1000);

    // Tìm các công việc chưa hoàn thành và sắp đến hạn trong 24 giờ tới
    const tasks = await Task.find({
      dueDate: { $gte: now, $lte: next24Hours },
      status: { $ne: 'completed' },
    });

    for (const task of tasks) {
      // Kiểm tra xem đã gửi nhắc nhở cho công việc này trong vòng 12h qua chưa
      const recentLog = await EmailLog.findOne({
        taskId: task._id,
        eventType: 'REMINDER_DUE_DATE',
        createdAt: { $gte: new Date(now.getTime() - 12 * 60 * 60 * 1000) },
      });

      if (!recentLog) {
        // Lấy danh sách người nhận (người tạo + người phụ trách)
        const recipientUserIds = new Set();
        if (task.createdBy) recipientUserIds.add(task.createdBy.toString());
        if (task.primaryAssigneeId) recipientUserIds.add(task.primaryAssigneeId.toString());
        if (task.assigneeIds) task.assigneeIds.forEach((id) => recipientUserIds.add(id.toString()));

        for (const userId of recipientUserIds) {
          const user = await User.findById(userId);
          if (user) {
            await notificationService.createNotification(
              user._id,
              'Nhắc nhở hạn chót công việc',
              `Công việc "${task.title}" sắp đến hạn hoàn thành vào ngày ${new Date(task.dueDate).toLocaleDateString('vi-VN')}.`,
              task._id
            );

            emailService.sendNotificationEmail({
              taskId: task._id,
              recipientEmail: user.email,
              eventType: 'REMINDER_DUE_DATE',
              subject: `[TaskManager] Nhắc nhở hạn chót: ${task.title}`,
              html: emailTemplates.taskReminderTemplate(user.fullName, task.title, task.dueDate),
            });
          }
        }
      }
    }
  } catch (error) {
    console.error('[CronService Error]:', error.message);
  }
};

exports.initCronJobs = () => {
  console.log('Khởi tạo tác vụ định kỳ nhắc nhở hạn chót công việc (CronJob)...');
  // Chạy ngay lần đầu khi server mở
  checkUpcomingDeadlines();
  // Chạy định kỳ mỗi 1 tiếng (3,600,000 ms)
  setInterval(checkUpcomingDeadlines, 60 * 60 * 1000);
};
