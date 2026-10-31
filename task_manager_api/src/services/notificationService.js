const Notification = require('../models/Notification');

exports.createNotification = async (userId, title, message) => {
  return await Notification.create({ userId, title, message });
};

exports.getUserNotifications = async (userId) => {
  return await Notification.find({ userId }).sort({ createdAt: -1 });
};
