const Task = require('../models/Task');
const TaskShare = require('../models/TaskShare');
const TaskActivity = require('../models/TaskActivity');
const EmailLog = require('../models/EmailLog');
const User = require('../models/User');
const taskService = require('../services/taskService');
const notificationService = require('../services/notificationService');
const emailService = require('../services/emailService');
const emailTemplates = require('../utils/emailTemplates');

exports.getTasks = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { scope, status, priority, q, sortBy, order } = req.query;

    let query = {};

    if (scope === 'created') {
      query.createdBy = userId;
    } else if (scope === 'assigned') {
      query.$or = [{ assigneeIds: userId }, { primaryAssigneeId: userId }];
    } else if (scope === 'shared') {
      const shares = await TaskShare.find({ userId });
      const sharedTaskIds = shares.map((s) => s.taskId);
      query._id = { $in: sharedTaskIds };
    } else {
      const shares = await TaskShare.find({ userId });
      const sharedTaskIds = shares.map((s) => s.taskId);
      query.$or = [
        { createdBy: userId },
        { assigneeIds: userId },
        { primaryAssigneeId: userId },
        { _id: { $in: sharedTaskIds } },
      ];
    }

    if (status) query.status = status;
    if (priority) query.priority = priority;

    if (q) {
      const regex = new RegExp(q, 'i');
      query.$and = [{ $or: [{ title: regex }, { description: regex }] }];
    }

    const sortField = sortBy || 'createdAt';
    const sortOrder = order === 'asc' ? 1 : -1;

    const tasks = await Task.find(query)
      .populate('createdBy', 'fullName email')
      .populate('assigneeIds', 'fullName email')
      .populate('primaryAssigneeId', 'fullName email')
      .sort({ [sortField]: sortOrder });

    res.json(tasks);
  } catch (error) {
    next(error);
  }
};

exports.getTaskById = async (req, res, next) => {
  try {
    const task = await Task.findById(req.params.id)
      .populate('createdBy', 'fullName email')
      .populate('assigneeIds', 'fullName email')
      .populate('primaryAssigneeId', 'fullName email');

    if (!task) return res.status(404).json({ message: 'Không tìm thấy công việc' });
    res.json(task);
  } catch (error) {
    next(error);
  }
};

exports.createTask = async (req, res, next) => {
  try {
    const { title, description, priority, status, startDate, dueDate, assigneeIds, primaryAssigneeId } = req.body;
    const task = await Task.create({
      title,
      description,
      priority,
      status: status || 'todo',
      startDate: startDate || null,
      dueDate,
      assigneeIds: assigneeIds || [],
      primaryAssigneeId: primaryAssigneeId || null,
      createdBy: req.user.id,
    });
    await taskService.logTaskActivity(task._id, req.user.id, 'Tạo công việc mới', { title });
    res.status(201).json(task);
  } catch (error) {
    next(error);
  }
};

exports.updateTask = async (req, res, next) => {
  try {
    const oldTask = await Task.findById(req.params.id);
    if (!oldTask) return res.status(404).json({ message: 'Không tìm thấy công việc' });

    const { title, description, status, priority, startDate, dueDate, assigneeIds, primaryAssigneeId } = req.body;
    const task = await Task.findByIdAndUpdate(
      req.params.id,
      { title, description, status, priority, startDate, dueDate, assigneeIds, primaryAssigneeId },
      { new: true }
    );

    await taskService.logTaskActivity(task._id, req.user.id, 'Cập nhật công việc', { title, status });

    // Lấy danh sách người liên quan
    const recipientUserIds = new Set([
      task.createdBy?.toString(),
      task.primaryAssigneeId?.toString(),
      ...(task.assigneeIds ? task.assigneeIds.map((id) => id.toString()) : []),
    ]);

    // Sự kiện 1: Thay đổi hạn hoàn thành (UPDATE_DUE_DATE)
    if (dueDate && new Date(dueDate).getTime() !== new Date(oldTask.dueDate).getTime()) {
      for (const uId of recipientUserIds) {
        if (!uId || uId === req.user.id) continue;
        const user = await User.findById(uId);
        if (user) {
          await notificationService.createNotification(
            user._id,
            'Thay đổi hạn hoàn thành',
            `Công việc "${task.title}" đã được đổi hạn chót mới: ${new Date(dueDate).toLocaleDateString('vi-VN')}.`,
            task._id
          );
          emailService.sendNotificationEmail({
            taskId: task._id,
            recipientEmail: user.email,
            eventType: 'UPDATE_DUE_DATE',
            subject: `[TaskManager] Cập nhật hạn hoàn thành: ${task.title}`,
            html: emailTemplates.taskDueDateUpdatedTemplate(user.fullName, task.title, dueDate),
          });
        }
      }
    }

    // Sự kiện 2: Hoàn thành công việc (COMPLETE_TASK)
    if (status === 'completed' && oldTask.status !== 'completed') {
      for (const uId of recipientUserIds) {
        if (!uId) continue;
        const user = await User.findById(uId);
        if (user) {
          await notificationService.createNotification(
            user._id,
            'Công việc đã hoàn thành',
            `Công việc "${task.title}" vừa được đánh dấu là thành công.`,
            task._id
          );
          emailService.sendNotificationEmail({
            taskId: task._id,
            recipientEmail: user.email,
            eventType: 'COMPLETE_TASK',
            subject: `[TaskManager] Hoàn thành công việc: ${task.title}`,
            html: emailTemplates.taskCompletedTemplate(user.fullName, task.title),
          });
        }
      }
    }

    res.json(task);
  } catch (error) {
    next(error);
  }
};

exports.updateTaskStatus = async (req, res, next) => {
  try {
    const { status } = req.body;
    const oldTask = await Task.findById(req.params.id);
    if (!oldTask) return res.status(404).json({ message: 'Không tìm thấy công việc' });

    const task = await Task.findByIdAndUpdate(req.params.id, { status }, { new: true });
    await taskService.logTaskActivity(task._id, req.user.id, 'Cập nhật trạng thái công việc', { status });

    // Sự kiện: Hoàn thành công việc (COMPLETE_TASK)
    if (status === 'completed' && oldTask.status !== 'completed') {
      const recipientUserIds = new Set([
        task.createdBy?.toString(),
        task.primaryAssigneeId?.toString(),
        ...(task.assigneeIds ? task.assigneeIds.map((id) => id.toString()) : []),
      ]);

      for (const uId of recipientUserIds) {
        if (!uId) continue;
        const user = await User.findById(uId);
        if (user) {
          await notificationService.createNotification(
            user._id,
            'Công việc đã hoàn thành',
            `Công việc "${task.title}" vừa được đánh dấu là hoàn thành.`,
            task._id
          );
          emailService.sendNotificationEmail({
            taskId: task._id,
            recipientEmail: user.email,
            eventType: 'COMPLETE_TASK',
            subject: `[TaskManager] Hoàn thành công việc: ${task.title}`,
            html: emailTemplates.taskCompletedTemplate(user.fullName, task.title),
          });
        }
      }
    }

    res.json(task);
  } catch (error) {
    next(error);
  }
};

exports.deleteTask = async (req, res, next) => {
  try {
    const task = await Task.findByIdAndDelete(req.params.id);
    if (!task) return res.status(404).json({ message: 'Không tìm thấy công việc' });
    await taskService.logTaskActivity(req.params.id, req.user.id, 'Xóa công việc', {});
    res.json({ message: 'Xóa công việc thành công' });
  } catch (error) {
    next(error);
  }
};

exports.getTaskActivities = async (req, res, next) => {
  try {
    const activities = await TaskActivity.find({ taskId: req.params.id })
      .populate('userId', 'fullName email')
      .sort({ createdAt: -1 });
    res.json(activities);
  } catch (error) {
    next(error);
  }
};

exports.getTaskEmailLogs = async (req, res, next) => {
  try {
    const logs = await EmailLog.find({ taskId: req.params.id }).sort({ createdAt: -1 });
    res.json(logs);
  } catch (error) {
    next(error);
  }
};
