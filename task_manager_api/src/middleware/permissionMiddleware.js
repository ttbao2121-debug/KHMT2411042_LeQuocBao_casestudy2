const Task = require('../models/Task');
const TaskShare = require('../models/TaskShare');

exports.checkTaskAccess = (requiredLevel = 'viewer') => {
  return async (req, res, next) => {
    try {
      const taskId = req.params.id || req.params.taskId || req.body.taskId;
      if (!taskId) {
        return res.status(400).json({ message: 'Thiếu ID công việc' });
      }

      const task = await Task.findById(taskId);
      if (!task) {
        return res.status(404).json({ message: 'Không tìm thấy công việc' });
      }

      const userId = req.user.id.toString();

      // 1. Kiểm tra nếu là Người tạo công việc (Owner) -> Quyền cao nhất
      if (task.createdBy.toString() === userId) {
        req.task = task;
        req.userRole = 'owner';
        return next();
      }

      // 2. Kiểm tra nếu là Người được giao việc
      const isAssigned =
        (task.assigneeIds && task.assigneeIds.map((id) => id.toString()).includes(userId)) ||
        (task.primaryAssigneeId && task.primaryAssigneeId.toString() === userId);

      // 3. Kiểm tra bản ghi chia sẻ (TaskShare)
      const share = await TaskShare.findOne({ taskId, userId });

      let permission = null;
      if (share) {
        permission = share.permission; // 'viewer' hoặc 'editor'
      } else if (isAssigned) {
        permission = 'editor'; // Người được giao việc mặc định có quyền editor trên nội dung
      }

      if (!permission) {
        return res.status(403).json({ message: 'Bạn không có quyền truy cập công việc này' });
      }

      // Quy tắc 3: Chỉ Owner mới được XÓA công việc hoặc QUẢN LÝ QUYỀN CHIA SẺ
      if (requiredLevel === 'owner' && req.userRole !== 'owner') {
        return res.status(403).json({ message: 'Chỉ người tạo công việc mới có quyền thực hiện thao tác này' });
      }

      // Quy tắc 3: Người có quyền 'viewer' KHÔNG ĐƯỢC sửa dữ liệu
      if (requiredLevel === 'editor' && permission !== 'editor' && req.userRole !== 'owner') {
        return res.status(403).json({ message: 'Người có quyền Xem (Viewer) không được sửa dữ liệu công việc' });
      }

      req.task = task;
      req.userPermission = permission;
      next();
    } catch (error) {
      next(error);
    }
  };
};
