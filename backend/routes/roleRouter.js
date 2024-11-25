const express = require("express");
const router = express.Router(); 
const roleController = require('../controller/role.controller');
const authenticateToken = require('../midellware/authentication')


router.post('/addrole', authenticateToken,roleController.addRole);
router.get('/Allroles',authenticateToken,roleController.getAllroles);
router.delete('/:roleId', authenticateToken, roleController.deleteRole);
router.put('/:roleId',authenticateToken,roleController.updateRole);
router.post('/assign-role',authenticateToken,roleController.assignRoleToUser);
module.exports = router;
