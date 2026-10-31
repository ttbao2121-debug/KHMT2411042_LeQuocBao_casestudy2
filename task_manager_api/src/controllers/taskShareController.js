const TaskShare = require('../models/TaskShare');

exports.shareTask = async (req, res, next) => {
  try {
    const { taskId, sharedWithUserId, permission } = req.body;
    const share = await TaskShare.create({ taskId, sharedWithUserId, permission });
    res.status(201).json(share);
  } catch (error) {
    next(error);
  }
};

exports.getTaskShares = async (req, res, next) => {
  try {
    const shares = await TaskShare.find({ taskId: req.params.taskId }).populate('sharedWithUserId', 'name email');
    res.json(shares);
  } catch (error) {
    next(error);
  }
};
