const express = require('express');
const router = express.Router();
const assignmentController = require('../controllers/assignmentController');
const authMiddleware = require('../middleware/authMiddleware');

router.post('/assign', authMiddleware, assignmentController.assignTask);

module.exports = router;
