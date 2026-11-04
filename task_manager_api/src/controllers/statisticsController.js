const Task = require('../models/Task');

exports.getTaskStatistics = async (req, res, next) => {
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

exports.getAssignmentStatistics = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const assignedCount = await Task.countDocuments({ assigneeIds: userId });
    const primaryCount = await Task.countDocuments({ primaryAssigneeId: userId });
    const createdCount = await Task.countDocuments({ createdBy: userId });

    res.json({
      assignedCount,
      primaryCount,
      createdCount,
    });
  } catch (error) {
    next(error);
  }
};

exports.getDeadlineStatistics = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const now = new Date();
    const filter = {
      $or: [{ createdBy: userId }, { assigneeIds: userId }, { primaryAssigneeId: userId }],
    };

    const overdue = await Task.countDocuments({
      ...filter,
      dueDate: { $lt: now },
      status: { $ne: 'completed' },
    });

    const threeDaysFromNow = new Date(now.getTime() + 3 * 24 * 60 * 60 * 1000);
    const upcoming = await Task.countDocuments({
      ...filter,
      dueDate: { $gte: now, $lte: threeDaysFromNow },
      status: { $ne: 'completed' },
    });

    res.json({
      overdue,
      upcoming,
    });
  } catch (error) {
    next(error);
  }
};
