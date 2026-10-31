const Task = require('../models/Task');
const TaskActivity = require('../models/TaskActivity');

exports.logTaskActivity = async (taskId, userId, action) => {
  return await TaskActivity.create({ taskId, userId, action });
};

exports.getTaskByIdWithDetails = async (taskId) => {
  return await Task.findById(taskId).populate('createdBy', 'name email').populate('assignedTo', 'name email');
};
