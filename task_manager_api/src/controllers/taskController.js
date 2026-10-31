const Task = require('../models/Task');
const taskService = require('../services/taskService');

exports.getTasks = async (req, res, next) => {
  try {
    const tasks = await Task.find({
      $or: [{ createdBy: req.user.id }, { assignedTo: req.user.id }],
    })
      .populate('createdBy', 'name email')
      .populate('assignedTo', 'name email')
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
    const { title, description, priority, dueDate, assignedTo } = req.body;
    const task = await Task.create({
      title,
      description,
      priority,
      dueDate,
      assignedTo: assignedTo || null,
      createdBy: req.user.id,
    });
    await taskService.logTaskActivity(task._id, req.user.id, 'Tạo công việc mới');
    res.status(201).json(task);
  } catch (error) {
    next(error);
  }
};

exports.updateTask = async (req, res, next) => {
  try {
    const { title, description, status, priority, dueDate, assignedTo } = req.body;
    const task = await Task.findByIdAndUpdate(
      req.params.id,
      { title, description, status, priority, dueDate, assignedTo },
      { new: true }
    );
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
