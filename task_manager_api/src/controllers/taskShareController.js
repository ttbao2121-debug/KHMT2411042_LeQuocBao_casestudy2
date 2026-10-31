const TaskShare = require('../models/TaskShare');

exports.shareTask = async (req, res, next) => {
  try {
    const { taskId, userId, sharedWithUserId, permission } = req.body;
    const targetUserId = userId || sharedWithUserId;

    const share = await TaskShare.create({
      taskId,
      userId: targetUserId,
      permission: permission || 'viewer',
      sharedBy: req.user.id,
    });
    res.status(201).json(share);
  } catch (error) {
    next(error);
  }
};

exports.getTaskShares = async (req, res, next) => {
  try {
    const shares = await TaskShare.find({ taskId: req.params.taskId })
      .populate('userId', 'fullName email')
      .populate('sharedBy', 'fullName email');
    res.json(shares);
  } catch (error) {
    next(error);
  }
};
