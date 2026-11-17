const Task = require('../models/Task');
const TaskActivity = require('../models/TaskActivity');

exports.logTaskActivity = async (taskId, userId, action, details = null) => {
  return await TaskActivity.create({ taskId, userId, action, details });
};

exports.getTaskByIdWithDetails = async (taskId) => {
  return await Task.findById(taskId)
    .populate('createdBy', 'fullName email avatarUrl')
    .populate('primaryAssigneeId', 'fullName email avatarUrl')
    .populate('assigneeIds', 'fullName email avatarUrl');
};

exports.getTaskActivities = async (taskId) => {
  return await TaskActivity.find({ taskId })
    .populate('userId', 'fullName email avatarUrl')
    .sort({ createdAt: -1 });
};
