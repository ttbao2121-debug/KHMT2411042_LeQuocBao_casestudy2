const express = require('express');
const router = express.Router();
const taskController = require('../controllers/taskController');
const authMiddleware = require('../middleware/authMiddleware');
const validateMiddleware = require('../middleware/validateMiddleware');
const { taskValidation } = require('../validators/taskValidator');

router.use(authMiddleware);

router.get('/', taskController.getTasks);
router.get('/:id', taskController.getTaskById);
router.post('/', taskValidation, validateMiddleware, taskController.createTask);
router.put('/:id', taskController.updateTask);
router.delete('/:id', taskController.deleteTask);

module.exports = router;
