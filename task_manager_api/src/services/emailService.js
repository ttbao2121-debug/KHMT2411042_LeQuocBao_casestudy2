const transporter = require('../config/email');
const EmailLog = require('../models/EmailLog');

exports.sendNotificationEmail = async ({ taskId = null, recipientEmail, eventType = 'GENERAL', subject, html }) => {
  let log;
  try {
    // Bước 3: Ghi nhận yêu cầu gửi email vào CSDL với trạng thái 'pending'
    log = await EmailLog.create({
      taskId,
      recipientEmail,
      eventType,
      subject,
      status: 'pending',
      attempts: 1,
    });

    // Bước 4: Email service gửi email qua SMTP
    const info = await transporter.sendMail({
      from: `"TaskManager App" <${process.env.SMTP_USER || 'no-reply@taskmanager.com'}>`,
      to: recipientEmail,
      subject,
      html,
    });

    // Bước 5: Cập nhật trạng thái thành 'sent'
    log.status = 'sent';
    log.sentAt = new Date();
    await log.save();

    return info;
  } catch (error) {
    console.error(`[EmailService Error] (${eventType} -> ${recipientEmail}):`, error.message);

    // Bước 5: Nếu thất bại, lưu lỗi để cho phép thử gửi lại sau
    if (log) {
      log.status = 'failed';
      log.errorMessage = error.message;
      await log.save();
    } else {
      await EmailLog.create({
        taskId,
        recipientEmail,
        eventType,
        subject,
        status: 'failed',
        attempts: 1,
        errorMessage: error.message,
      });
    }
  }
};
