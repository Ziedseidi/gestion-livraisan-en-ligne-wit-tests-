const express = require('express');
const mongoose = require('mongoose');
const cookieParser = require('cookie-parser');
const userRouter = require('./routes/userRouter');
const roleRouter = require('./routes/roleRouter');
const dishRouter = require('./routes/dishRouter');
const deliveryRouter = require('./routes/deliveryRouter');
const path = require('path'); // Ajoutez cette ligne


require('dotenv').config();

const app = express();
const port = process.env.PORT || 3500;

app.use(cookieParser());
app.use(express.json());

// Middleware de logging
app.use((req, res, next) => {
    console.log(`${req.method} ${req.url}`);
    next();
});
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Route de santé (health check)
app.get('/api/health', (req, res) => {
  res.status(200).json({ message: 'Server is running' });
});

// Routes
app.use('/users', userRouter);
app.use('/roles', roleRouter);
app.use('/dishs', dishRouter);
app.use('/deliverys', deliveryRouter);

// Middleware de gestion des erreurs
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).send('Quelque chose a échoué!');
});

// Connecter à MongoDB
(async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log("Connexion réussie avec la base de données");
    } catch (error) {
        console.log(error.message);
    }
})();

// Exporter l'application pour les tests
if (process.env.NODE_ENV !== 'test') {
    app.listen(port, () => {
        console.log(`Serveur démarré sur le port ${port}`);
    });
}

module.exports = app;  // Exporter l'application pour les tests
