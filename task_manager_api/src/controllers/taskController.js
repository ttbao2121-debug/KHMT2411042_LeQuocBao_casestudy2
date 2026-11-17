const Task = require('../models/Task');
const TaskShare = require('../models/TaskShare');
const taskService = require('../services/taskService');

exports.getTasks = async (req, res, next) => {
  try {
    const { scope, status, search } = req.query;
    const userId = req.user.id;

    let query = {};

    // 1. Phân loại theo vai trò (Scope)
    if (scope === 'my' || scope === 'created') {
      query.createdBy = userId;
    } else if (scope === 'assigned') {
      query.$or = [{ primaryAssigneeId: userId }, { assigneeIds: userId }];
    } else if (scope === 'shared') {
      const shares = await TaskShare.find({ userId });
      const sharedTaskIds = shares.map((s) => s.taskId);
      query._id = { $in: sharedTaskIds };
    } else {
      // All - Tất cả công việc liên quan
      const shares = await TaskShare.find({ userId });
      const sharedTaskIds = shares.map((s) => s.taskId);
      query.$or = [
        { createdBy: userId },
        { primaryAssigneeId: userId },
        { assigneeIds: userId },
        { _id: { $in: sharedTaskIds } },
      ];
    }

    // 2. Lọc theo trạng thái
    if (status) {
      query.status = status;
    }

    // 3. Tìm kiếm theo tiêu đề/mô tả
    if (search) {
      query.$and = query.$and || [];
      query.$and.push({
        $or: [
          { title: { $regex: search, $options: 'i' } },
          { description: { $regex: search, $options: 'i' } },
        ],
      });
    }

    const tasks = await Task.find(query)
      .populate('createdBy', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl')
      .populate('assigneeIds', 'fullName email avatarUrl')
      .sort({ createdAt: -1 });

    res.json(tasks);
  } catch (error) {
    next(error);
  }
};

exports.getTaskById = async (req, res, next) => {
  try {
    const task = await taskService.getTaskByIdWithDetails(req.params.id);
    if (!task) return res.status(404).json({ message: 'Không tìm thấy công việc' });
    res.json(task);
  } catch (error) {
    next(error);
  }
};

exports.createTask = async (req, res, next) => {
  try {
    const { title, description, priority, status, dueDate, primaryAssigneeId, assigneeIds } = req.body;
    const task = await Task.create({
      title,
      description: description || '',
      priority: priority || 'medium',
      status: status || 'todo',
      dueDate: dueDate || new Date(),
      primaryAssigneeId: primaryAssigneeId || null,
      assigneeIds: assigneeIds || [],
      createdBy: req.user.id,
    });

    await taskService.logTaskActivity(task._id, req.user.id, 'Tạo công việc mới');

    const populated = await Task.findById(task._id)
      .populate('createdBy', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl')
      .populate('assigneeIds', 'fullName email avatarUrl');

    res.status(201).json(populated);
  } catch (error) {
    next(error);
  }
};

exports.updateTask = async (req, res, next) => {
  try {
    const { title, description, status, priority, dueDate, primaryAssigneeId, assigneeIds } = req.body;
    const task = await Task.findByIdAndUpdate(
      req.params.id,
      { title, description, status, priority, dueDate, primaryAssigneeId, assigneeIds },
      { new: true }
    )
      .populate('createdBy', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl')
      .populate('assigneeIds', 'fullName email avatarUrl');

    if (!task) return res.status(404).json({ message: 'Không tìm thấy công việc' });
    await taskService.logTaskActivity(task._id, req.user.id, 'Cập nhật công việc');
    res.json(task);
  } catch (error) {
    next(error);
  }
};

exports.deleteTask = async (req, res, next) => {
  try {
    const task = await Task.findByIdAndDelete(req.params.id);
    if (!task) return res.status(404).json({ message: 'Không tìm thấy công việc' });
    await taskService.logTaskActivity(req.params.id, req.user.id, 'Xóa công việc');
    res.json({ message: 'Xóa công việc thành công' });
  } catch (error) {
    next(error);
  }
};

exports.updateTaskStatus = async (req, res, next) => {
  try {
    const { status } = req.body;
    const task = await Task.findByIdAndUpdate(req.params.id, { status }, { new: true })
      .populate('createdBy', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl')
      .populate('assigneeIds', 'fullName email avatarUrl');

    if (!task) return res.status(404).json({ message: 'Không tìm thấy công việc' });
    await taskService.logTaskActivity(task._id, req.user.id, `Đổi trạng thái sang ${status}`);
    res.json(task);
  } catch (error) {
    next(error);
  }
};

exports.getTaskActivities = async (req, res, next) => {
  try {
    const activities = await taskService.getTaskActivities(req.params.id);
    res.json(activities);
  } catch (error) {
    next(error);
  }
};

exports.getTaskEmailLogs = async (req, res, next) => {
  try {
    const EmailLog = require('../models/EmailLog');
    const logs = await EmailLog.find({ taskId: req.params.id }).sort({ createdAt: -1 });
    res.json(logs);
  } catch (error) {
    next(error);
  }
};
