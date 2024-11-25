const express = require('express');
const userController = require('../controller/user.controller');
const router = express.Router();
const authenticateToken = require('../midellware/authentication')

router.post('/signup', userController.signup);
router.post('/login',userController.login);
router.post('/resend-confirmation-code', userController.resendConfirmationCode);
router.post('/verify-confirmation', userController.verifyConfirmationCode);
router.post('/refresh-token', userController.refreshToken);
router.get('/',authenticateToken,userController.getAllUsers);
router.post('/logout',userController.logoutUser);




module.exports = router;
