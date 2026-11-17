const express = require('express');
const router = express.Router();
const assignmentController = require('../controllers/assignmentController');
const authMiddleware = require('../middleware/authMiddleware');

router.use(authMiddleware);

router.post('/assign', assignmentController.addAssignees);

module.exports = router;
