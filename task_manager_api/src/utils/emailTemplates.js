exports.welcomeTemplate = (userName) => {
  return `
    <div style="font-family: Arial, sans-serif; padding: 20px; color: #212121;">
      <h2 style="color: #FB8C00;">Chào mừng ${userName} đến với TaskManager!</h2>
      <p>Cảm ơn bạn đã đăng ký tài khoản. Hãy bắt đầu quản lý công việc hiệu quả ngay hôm nay.</p>
    </div>
  `;
};

exports.taskAssignedTemplate = (userName, taskTitle, dueDate) => {
  return `
    <div style="font-family: Arial, sans-serif; padding: 20px; color: #212121;">
      <h2 style="color: #FB8C00;">Thông báo giao việc mới</h2>
      <p>Chào <strong>${userName}</strong>,</p>
      <p>Bạn vừa được giao công việc mới: <strong style="color: #FB8C00;">${taskTitle}</strong>.</p>
      ${dueDate ? `<p>Hạn hoàn thành: <strong>${new Date(dueDate).toLocaleDateString('vi-VN')}</strong></p>` : ''}
      <p>Vui lòng mở ứng dụng <strong>TaskManager</strong> để xem chi tiết.</p>
    </div>
  `;
};

exports.taskSharedTemplate = (userName, taskTitle, permission, sharedByName) => {
  const permText = permission === 'editor' ? 'Chỉnh sửa (Editor)' : 'Xem (Viewer)';
  return `
    <div style="font-family: Arial, sans-serif; padding: 20px; color: #212121;">
      <h2 style="color: #FB8C00;">Thông báo chia sẻ công việc</h2>
      <p>Chào <strong>${userName}</strong>,</p>
      <p>Người dùng <strong>${sharedByName || 'Thành viên'}</strong> vừa chia sẻ công việc: <strong style="color: #FB8C00;">${taskTitle}</strong> với quyền: <strong>${permText}</strong>.</p>
      <p>Vui lòng đăng nhập vào <strong>TaskManager</strong> để kiểm tra.</p>
    </div>
  `;
};

exports.taskDueDateUpdatedTemplate = (userName, taskTitle, newDueDate) => {
  return `
    <div style="font-family: Arial, sans-serif; padding: 20px; color: #212121;">
      <h2 style="color: #FB8C00;">Cập nhật hạn hoàn thành công việc</h2>
      <p>Chào <strong>${userName}</strong>,</p>
      <p>Công việc <strong style="color: #FB8C00;">${taskTitle}</strong> đã được thay đổi hạn hoàn thành mới thành: <strong>${new Date(newDueDate).toLocaleDateString('vi-VN')}</strong>.</p>
      <p>Vui lòng sắp xếp thời gian để hoàn thành đúng hạn.</p>
    </div>
  `;
};

exports.taskCompletedTemplate = (userName, taskTitle) => {
  return `
    <div style="font-family: Arial, sans-serif; padding: 20px; color: #212121;">
      <h2 style="color: #4CAF50;">🎉 Công việc đã hoàn thành!</h2>
      <p>Chào <strong>${userName}</strong>,</p>
      <p>Công việc <strong style="color: #4CAF50;">${taskTitle}</strong> vừa được đánh dấu là <strong>HOÀN THÀNH</strong>.</p>
      <p>Chúc mừng bạn đã hoàn thành mục tiêu này!</p>
    </div>
  `;
};

exports.taskReminderTemplate = (userName, taskTitle, dueDate) => {
  return `
    <div style="font-family: Arial, sans-serif; padding: 20px; color: #212121;">
      <h2 style="color: #E53935;">⏰ Nhắc nhở hạn hoàn thành công việc</h2>
      <p>Chào <strong>${userName}</strong>,</p>
      <p>Công việc <strong style="color: #E53935;">${taskTitle}</strong> sắp đến hạn hoàn thành vào ngày <strong>${new Date(dueDate).toLocaleDateString('vi-VN')}</strong>.</p>
      <p>Hãy nhanh chóng hoàn thành công việc đúng hạn nhé!</p>
    </div>
  `;
};
