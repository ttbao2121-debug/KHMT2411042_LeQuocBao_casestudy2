const Task = require('../models/Task');

exports.getStatistics = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const filter = {
      $or: [{ createdBy: userId }, { assigneeIds: userId }, { primaryAssigneeId: userId }],
    };
    const total = await Task.countDocuments(filter);
    const todo = await Task.countDocuments({ status: 'todo', ...filter });
    const inProgress = await Task.countDocuments({ status: 'in_progress', ...filter });
    const completed = await Task.countDocuments({ status: 'completed', ...filter });

    res.json({ total, todo, inProgress, completed });
  } catch (error) {
    next(error);
  }
};
