const jwt = require('jsonwebtoken');

const authenticateToken = (req, res, next) => {
    // Vérifier le token dans les cookies ou dans les headers
    const token = req.cookies.token || req.headers.authorization?.split(' ')[1];

    console.log('Token reçu:', token); // Log du token reçu

    if (!token) {
        console.log('Aucun token trouvé');
        return res.status(401).send('Authentication failed: invalid token');
    }

    try {
        const decodedToken = jwt.verify(token, process.env.JWT_SECRET);
        console.log('Token décodé:', decodedToken); // Log du token décodé
        req.userId = decodedToken.userId; // Assurez-vous que cette propriété existe dans le token
        next();
    } catch (error) {
        console.log('Erreur lors de la vérification du token:', error.message);
        return res.status(401).send('Authentication failed: invalid token');
    }
};

module.exports = authenticateToken;
