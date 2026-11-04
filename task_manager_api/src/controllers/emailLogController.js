const EmailLog = require('../models/EmailLog');
const emailService = require('../services/emailService');

exports.retryEmail = async (req, res, next) => {
  try {
    const log = await EmailLog.findById(req.params.id);
    if (!log) return res.status(404).json({ message: 'Không tìm thấy nhật ký email' });

    // Hạn chế gửi trùng: Kiểm tra xem đã gửi thành công chưa
    if (log.status === 'sent') {
      return res.status(400).json({ message: 'Email này đã được gửi thành công trước đó' });
    }

    // Hạn chế số lần gửi lại tối đa (tránh spam)
    if (log.attempts >= 3) {
      return res.status(400).json({ message: 'Đã vượt quá số lần thử gửi lại email tối đa (3 lần)' });
    }

    log.attempts += 1;
    try {
      await emailService.sendNotificationEmail({
        taskId: log.taskId,
        recipientEmail: log.recipientEmail,
        eventType: log.eventType || 'RETRY',
        subject: log.subject,
        html: log.body || `<p>${log.subject}</p>`,
      });
      log.status = 'sent';
      log.sentAt = new Date();
      log.errorMessage = null;
    } catch (err) {
      log.status = 'failed';
      log.errorMessage = err.message;
    }

    await log.save();
    res.json(log);
  } catch (error) {
    next(error);
  }
};
