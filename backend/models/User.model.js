const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
    firstName: { type: String, required: true },
    lastName: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    phone: { type: String, required: true },
    address: { type: String, required: true },
    password: { type: String, required: true },
    createdAt: { type: Date, default: Date.now },
    roles: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Role', default: [] }],
    profileImage: { type: String },
    isActive: { type: Boolean, default: false },
    service: { type: String, required: true },
    confirmationCode: { type: String, default: '' },
    dishes: [
        {
          type: mongoose.Schema.Types.ObjectId,
          ref: 'Dish'
        }
    ]
});

const User = mongoose.model('User', userSchema);
module.exports = User;
