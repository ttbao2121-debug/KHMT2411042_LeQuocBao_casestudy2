const transporter = require('../config/email');
const EmailLog = require('../models/EmailLog');

exports.sendEmail = async (to, subject, html) => {
  try {
    const info = await transporter.sendMail({
      from: `"TaskManager App" <${process.env.SMTP_USER || 'no-reply@taskmanager.com'}>`,
      to,
      subject,
      html,
    });
    await EmailLog.create({ to, subject, body: html, status: 'sent' });
    return info;
  } catch (error) {
    await EmailLog.create({ to, subject, body: html, status: 'failed', error: error.message });
    console.error('Email error:', error.message);
  }
};
