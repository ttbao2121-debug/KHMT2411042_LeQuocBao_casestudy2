exports.welcomeTemplate = (userName) => {
  return `
    <h2>Chào mừng ${userName} đến với TaskManager!</h2>
    <p>Cảm ơn bạn đã đăng ký tài khoản. Hãy bắt đầu quản lý công việc hiệu quả ngay hôm nay.</p>
  `;
};

exports.taskAssignedTemplate = (userName, taskTitle) => {
  return `
    <h2>Chào ${userName},</h2>
    <p>Bạn vừa được giao một công việc mới: <strong>${taskTitle}</strong>.</p>
    <p>Vui lòng đăng nhập vào ứng dụng để xem chi tiết.</p>
  `;
};
