const express = require('express');
const router = express.Router();
const statisticsController = require('../controllers/statisticsController');
const authMiddleware = require('../middleware/authMiddleware');

router.get('/', authMiddleware, statisticsController.getStatistics);

module.exports = router;
