const Task = require('../models/Task');
const TaskActivity = require('../models/TaskActivity');

exports.logTaskActivity = async (taskId, userId, action, details = {}) => {
  return await TaskActivity.create({ taskId, userId, action, details });
};

exports.getTaskByIdWithDetails = async (taskId) => {
  return await Task.findById(taskId)
    .populate('createdBy', 'fullName email')
    .populate('assigneeIds', 'fullName email')
    .populate('primaryAssigneeId', 'fullName email');
};
