const { getTransporter } = require('../config/email');
const EmailLog = require('../models/EmailLog');

exports.sendNotificationEmail = async ({ taskId = null, recipientEmail, eventType = 'GENERAL', subject, html }) => {
  let log;
  try {
    log = await EmailLog.create({
      taskId,
      recipientEmail,
      eventType,
      subject,
      status: 'pending',
      attempts: 1,
    });

    const transporter = await getTransporter();
    const sender =
      process.env.SMTP_USER && process.env.SMTP_USER !== 'your_email@gmail.com'
        ? process.env.SMTP_USER
        : 'no-reply@taskmanager.com';

    const info = await transporter.sendMail({
      from: `"TaskManager App" <${sender}>`,
      to: recipientEmail,
      subject,
      html,
    });

    log.status = 'sent';
    log.sentAt = new Date();
    await log.save();

    return info;
  } catch (error) {
    console.error(`[EmailService Error] (${eventType} -> ${recipientEmail}):`, error.message);

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

exports.sendEmail = async (to, subject, html) => {
  return exports.sendNotificationEmail({
    recipientEmail: to,
    eventType: 'WELCOME',
    subject,
    html,
  });
};
