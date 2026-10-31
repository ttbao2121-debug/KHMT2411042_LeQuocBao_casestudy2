const Notification = require('../models/Notification');

exports.createNotification = async (userId, title, message, taskId = null, type = 'general') => {
  return await Notification.create({ userId, taskId, type, title, message });
};

exports.getUserNotifications = async (userId) => {
  return await Notification.find({ userId }).sort({ createdAt: -1 });
};
