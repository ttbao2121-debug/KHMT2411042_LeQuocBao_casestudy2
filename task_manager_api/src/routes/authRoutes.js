const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const authMiddleware = require('../middleware/authMiddleware');
const validateMiddleware = require('../middleware/validateMiddleware');
const { registerValidation, loginValidation } = require('../validators/authValidator');

router.post('/send-register-otp', authController.sendRegisterOTP);
router.post('/register', registerValidation, validateMiddleware, authController.register);
router.post('/login', loginValidation, validateMiddleware, authController.login);
router.post('/forgot-password', authController.forgotPassword);
router.post('/reset-password', authController.resetPassword);
router.get('/me', authMiddleware, authController.getMe);
router.put('/me', authMiddleware, authController.updateMe);
router.put('/change-password', authMiddleware, authController.changePassword);

module.exports = router;
