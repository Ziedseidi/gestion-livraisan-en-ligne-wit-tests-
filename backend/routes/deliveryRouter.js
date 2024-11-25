const express = require("express");
const router = express.Router();
const deliveryController = require('../controller/deliveryController');
const authenticateToken = require('../midellware/authentication'); 

router.post('/addDelivery',authenticateToken,deliveryController.addDelivery);
router.get('/',authenticateToken, deliveryController.trackDeliveryStatus);
router.get('/AllDelivery',authenticateToken,deliveryController.getAllDelivery);
router.put('/:deliveryId',authenticateToken,deliveryController.UpdateStatus);
router.get('/DeliveryStatistics',authenticateToken,deliveryController.getDeliveryStatistics);

module.exports = router;


