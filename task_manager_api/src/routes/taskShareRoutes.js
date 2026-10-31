const express = require('express');
const router = express.Router();
const taskShareController = require('../controllers/taskShareController');
const authMiddleware = require('../middleware/authMiddleware');

router.use(authMiddleware);

router.post('/share', taskShareController.shareTask);
router.get('/:taskId', taskShareController.getTaskShares);

module.exports = router;
