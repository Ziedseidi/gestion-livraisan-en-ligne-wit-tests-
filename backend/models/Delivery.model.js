const mongoose = require('mongoose');

const DeliverySchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  orderedDishes: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Dish',
      required: true
    }
  ],
  deliveryAddress: {
    type: String,
    required: true
  },
  totalPrice: {
    type: Number,
    required: true
  },
  status: {
    type: String,
    enum: ['En Cours', 'Acceptée', 'Refusée','Livrée'],
    default: 'En Cours'
  },
  phone:{
    type:Number,
    required:true

  },
  orderDate: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Delivery', DeliverySchema);
