const User = require('../models/User.model'); // Assurez-vous que le chemin est correct
const jwt = require('jsonwebtoken');
const { sendMail } = require('../config/service_mailing');
const generateCode = require('../utils/generatecode');
const bcrypt = require('bcryptjs');

const userController = {};

// Inscription de l'utilisateur
userController.signup = async (req, res) => {
    try {
        const { firstName, lastName, email, phone, address, password, service } = req.body;

        // Vérifier si l'utilisateur existe déjà
        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ message: 'Cet email est déjà utilisé.' });
        }

        // Hacher le mot de passe
        if (!password) {
            return res.status(400).json({ message: 'Le mot de passe est requis.' });
        }
        const hashedPassword = await bcrypt.hash(password, 10);

        // Créer un nouvel utilisateur
        const newUser = new User({
            firstName,
            lastName,
            email,
            phone,
            address,
            password: hashedPassword,
            roles: [],
            service,
            isActive: false,
        });

        const savedUser = await newUser.save();

        res.status(201).json({ message: 'Utilisateur créé avec succès', user: savedUser });
    } catch (error) {
        console.error('Erreur lors de la création de l\'utilisateur:', error);
        res.status(500).json({ message: 'Erreur lors de l\'inscription' });
    }
};

// Désactiver un utilisateur

// Connexion de l'utilisateur
userController.login = async (req, res) => {
    try {
        const { email, password } = req.body;

        const user = await User.findOne({ email }).populate('roles');
        if (!user) {
            return res.status(404).json({ message: 'Utilisateur non trouvé' });
        }

        if (user.isDisabled) {
            return res.status(403).json({ message: 'Utilisateur désactivé' });
        }

        if (!user.isActive) {
            const newConfirmationCode = generateCode();
            user.confirmationCode = newConfirmationCode;
            await user.save();
            await sendMail(email, 'Confirmez votre inscription', `Votre code de confirmation est : ${newConfirmationCode}`, false);

            return res.status(403).json({
                message: 'Compte non activé. Code de confirmation envoyé.',
                needsActivation: true,
                email: user.email,
            });
        }

        const validPassword = await bcrypt.compare(password, user.password);
        if (!validPassword) {
            return res.status(401).json({ message: 'Mot de passe incorrect' });
        }

        const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET, { expiresIn: '24h' });
        const refreshToken = jwt.sign({ userId: user._id }, process.env.JWT_REFRESH_SECRET, { expiresIn: '7d' });

        user.refreshToken = refreshToken;
        await user.save();

        res.status(200).json({
            message: `Bienvenue, ${user.firstName || 'utilisateur'}!`,
            token,
            refreshToken,
            user: {
                firstName: user.firstName,
                lastName: user.lastName,
                roles: user.roles.map(role => role.name),
            },
        });
    } catch (error) {
        console.error('Erreur lors de la connexion de l’utilisateur:', error);
        res.status(500).json({ message: 'Erreur lors de la connexion' });
    }
};

// Ré-envoyer le code de confirmation
userController.resendConfirmationCode = async (req, res) => {
    try {
        const { email } = req.body;

        if (!email) {
            return res.status(400).json({ message: 'Email requis' });
        }

        const user = await User.findOne({ email });

        if (!user) {
            return res.status(404).json({ message: 'Utilisateur non trouvé' });
        }

        const newConfirmationCode = generateCode();
        user.confirmationCode = newConfirmationCode;
        await user.save();

        await sendMail(email, 'Confirmez votre inscription', `Votre nouveau code de confirmation est : ${newConfirmationCode}`, false);

        res.status(200).json({ message: 'Code de confirmation renvoyé' });
    } catch (error) {
        console.error('Erreur lors du renvoi du code de confirmation:', error);
        res.status(500).json({ message: 'Échec lors du renvoi du code de confirmation' });
    }
};

userController.verifyConfirmationCode = async (req, res) => {
    try {
        const { email, confirmationCode } = req.body;

        if (!email || !confirmationCode) {
            return res.status(400).json({ message: 'Email et code de confirmation requis' });
        }

        // Chercher l'utilisateur par email et le code de confirmation
        const user = await User.findOne({ email, confirmationCode });

        // Vérifier si l'utilisateur existe et si le code de confirmation est correct
        if (!user) {
            return res.status(400).json({ message: 'Code de confirmation invalide ou utilisateur introuvable' });
        }

        // Si l'utilisateur est déjà activé, renvoyer une réponse appropriée
        if (user.isActive) {
            return res.status(400).json({ message: 'Le compte est déjà activé.' });
        }

        // Activer le compte et vider le code de confirmation
        user.isActive = true;
        user.confirmationCode = ''; // Vider le code après activation
        await user.save();

        res.status(200).json({ message: 'Compte activé avec succès' });
    } catch (error) {
        console.error('Erreur lors de la vérification du code de confirmation:', error);
        res.status(500).json({ message: 'Erreur lors de la vérification du code de confirmation' });
    }
};



// Rafraîchir le token
userController.refreshToken = async (req, res) => {
    try {
        const { refreshToken } = req.body;
        if (!refreshToken) {
            return res.status(401).json({ message: 'Refresh token manquant' });
        }
        const decodedToken = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);

        const user = await User.findById(decodedToken.userId);

        if (!user) {
            return res.status(404).json({ message: 'Utilisateur non trouvé' });
        }

        if (user.refreshToken !== refreshToken) {
            return res.status(401).json({ message: 'Refresh token invalide' });
        }

        const token = jwt.sign({ userId: user._id, role: user.role }, process.env.JWT_SECRET, { expiresIn: '24h' });
        res.status(200).json({ token });
    } catch (error) {
        console.error('Erreur lors du rafraîchissement du token :', error);
        res.status(500).json({ message: 'Erreur lors du rafraîchissement du token' });
    }
};

// Déconnexion
userController.logoutUser = async (req, res) => {
    try {
        res.clearCookie('token', { path: '/' });
        res.status(200).json({ message: 'Déconnexion réussie' });
    } catch (error) {
        res.status(500).json({ message: 'Erreur lors de la déconnexion' });
    }
};

// Récupérer tous les utilisateurs
userController.getAllUsers = async (req, res) => {
    try {
        const users = await User.find({ isActive: true }).populate('roles', 'name'); // Récupérer les utilisateurs actifs
        if (users.length === 0) {
            return res.status(404).json({ message: 'Aucun utilisateur actif trouvé.' });
        }
        res.json(users); // Retourner les utilisateurs au format JSON
    } catch (error) {
        console.error('Erreur lors de la récupération des utilisateurs:', error);
        res.status(500).json({ message: 'Erreur lors de la récupération des utilisateurs' });
    }
};

module.exports = userController;
