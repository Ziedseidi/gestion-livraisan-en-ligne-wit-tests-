const express = require("express");
const router = express.Router();
const uploadImage = require('../utils/multer'); // Vérifiez le chemin
const dishController = require('../controller/dishController');
const authenticateToken = require('../midellware/authentication'); 

router.post('/addDish',authenticateToken ,uploadImage.single('image'), dishController.addDish);
router.delete('/:dishId', authenticateToken, dishController.deleteDish);
router.get('/allDishs',authenticateToken,dishController.getAllDishs);


module.exports = router;
