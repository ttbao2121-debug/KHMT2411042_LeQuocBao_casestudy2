const Task = require('../models/Task');

exports.getStatistics = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const total = await Task.countDocuments({ $or: [{ createdBy: userId }, { assignedTo: userId }] });
    const pending = await Task.countDocuments({ status: 'pending', $or: [{ createdBy: userId }, { assignedTo: userId }] });
    const inProgress = await Task.countDocuments({ status: 'inProgress', $or: [{ createdBy: userId }, { assignedTo: userId }] });
    const completed = await Task.countDocuments({ status: 'completed', $or: [{ createdBy: userId }, { assignedTo: userId }] });

    res.json({ total, pending, inProgress, completed });
  } catch (error) {
    next(error);
  }
};
