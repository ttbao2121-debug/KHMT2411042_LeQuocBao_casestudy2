const express = require('express');
const router = express.Router();
const taskController = require('../controllers/taskController');
const assignmentController = require('../controllers/assignmentController');
const taskShareController = require('../controllers/taskShareController');
const authMiddleware = require('../middleware/authMiddleware');
const validateMiddleware = require('../middleware/validateMiddleware');
const { checkTaskAccess } = require('../middleware/permissionMiddleware');
const { taskValidation } = require('../validators/taskValidator');

router.use(authMiddleware);

// 6.3. Công việc — /tasks
router.get('/', taskController.getTasks);
router.post('/', taskValidation, validateMiddleware, taskController.createTask);
router.get('/:id', checkTaskAccess('viewer'), taskController.getTaskById);
router.put('/:id', checkTaskAccess('editor'), taskController.updateTask);
router.delete('/:id', checkTaskAccess('owner'), taskController.deleteTask);
router.patch('/:id/status', checkTaskAccess('editor'), taskController.updateTaskStatus);
router.get('/:id/activities', checkTaskAccess('viewer'), taskController.getTaskActivities);
router.get('/:id/email-logs', checkTaskAccess('viewer'), taskController.getTaskEmailLogs);

// 6.4. Giao việc — /tasks/:id/assignees
router.get('/:id/assignees', checkTaskAccess('viewer'), assignmentController.getAssignees);
router.post('/:id/assignees', checkTaskAccess('owner'), assignmentController.addAssignees);
router.patch('/:id/assignees/:userId', checkTaskAccess('owner'), assignmentController.updateAssigneeRole);
router.delete('/:id/assignees/:userId', checkTaskAccess('owner'), assignmentController.removeAssignee);

// 6.5. Chia sẻ — /tasks/:id/shares
router.get('/:id/shares', checkTaskAccess('viewer'), taskShareController.getShares);
router.post('/:id/shares', checkTaskAccess('owner'), taskShareController.createShare);
router.patch('/:id/shares/:shareId', checkTaskAccess('owner'), taskShareController.updateShare);
router.delete('/:id/shares/:shareId', checkTaskAccess('owner'), taskShareController.deleteShare);

module.exports = router;
