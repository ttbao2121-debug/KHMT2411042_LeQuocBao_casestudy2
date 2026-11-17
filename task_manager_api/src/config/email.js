const nodemailer = require('nodemailer');

let activeTransporter = null;

const getTransporter = async () => {
  if (activeTransporter) return activeTransporter;

  const isConfigured =
    process.env.SMTP_USER &&
    process.env.SMTP_USER !== 'your_email@gmail.com' &&
    process.env.SMTP_PASS &&
    process.env.SMTP_PASS !== 'your_email_password';

  if (isConfigured) {
    const smtpPass = process.env.SMTP_PASS.replace(/\s+/g, '');
    activeTransporter = nodemailer.createTransport({
      host: process.env.SMTP_HOST || 'smtp.gmail.com',
      port: parseInt(process.env.SMTP_PORT || '587'),
      secure: false,
      auth: {
        user: process.env.SMTP_USER,
        pass: smtpPass,
      },
    });
  } else {
    try {
      const testAccount = await nodemailer.createTestAccount();
      console.log(`[SMTP Auto-Test] Đã khởi tạo Email thử nghiệm tự động: ${testAccount.user}`);
      activeTransporter = nodemailer.createTransport({
        host: 'smtp.ethereal.email',
        port: 587,
        secure: false,
        auth: {
          user: testAccount.user,
          pass: testAccount.pass,
        },
      });
    } catch (err) {
      console.error('[SMTP Error]:', err.message);
      activeTransporter = nodemailer.createTransport({
        jsonTransport: true,
      });
    }
  }

  return activeTransporter;
};

module.exports = { getTransporter };
