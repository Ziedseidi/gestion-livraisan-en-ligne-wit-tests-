const request = require('supertest');
const app = require('../server');  // Assurez-vous que le chemin est correct
const mongoose = require('mongoose');
const User = require('../models/User.model');
const Role = require('../models/Role.model'); // Importation du modèle Role si nécessaire
const jwt = require('jsonwebtoken');
const generateCode = require('../utils/generatecode');  // Assurez-vous d'utiliser le bon nom de fonction
const { hashPassword } = require('../utils/bcrypt');
describe('User Controller Tests', () => {
    let token;
    let userId;
    let confirmationCode;
    let email;

    beforeAll(async () => {
        email = `user${Date.now()}@example.com`; 
        confirmationCode = generateCode();  // Générer un code de confirmation dynamique

        const userRole = await Role.findOne({ name: 'User' }) || new Role({ name: 'User' }).save();
        const hashedPassword = await hashPassword('password123');

        const newUser = new User({
            firstName: 'John',
            lastName: 'Doe',
            email: email,  // Utilisation de l'email généré dynamiquement
            phone: '1234567890',
            address: '123 Main St',
            password: hashedPassword,
            service: 'delivery',
            confirmationCode,  // Ajouter le code de confirmation généré dynamiquement
            isActive: false,  // L'utilisateur commence avec isActive à false
            roles: [userRole._id] // Associer le rôle à l'utilisateur
        });

        const savedUser = await newUser.save();
        userId = savedUser._id;

        // Créez un token JWT pour les tests nécessitant une authentification
        token = jwt.sign({ userId }, process.env.JWT_SECRET, { expiresIn: '1h' });
    });

    // Après chaque test, supprimez les utilisateurs créés
    afterAll(async () => {
       // await User.deleteMany({});
        //await Role.deleteMany({});
        mongoose.connection.close();
    });

    // Test de la route de création d'un utilisateur (signup)
    it('should create a new user (POST /users/signup)', async () => {
        const newUser = {
            firstName: 'Alice',
            lastName: 'Smith',
            email: `alice.smith${Date.now()}@example.com`,  // Utilisation d'un email unique
            phone: '0987654321',
            address: '456 Elm St',
            password: 'password456',
            service: 'catering'
        };

        const response = await request(app)
            .post('/users/signup')
            .send(newUser)
            .expect(201);

        expect(response.body.message).toBe('Utilisateur créé avec succès');
        expect(response.body.user).toHaveProperty('_id');
    });

    // Test de la route de connexion (login) avec compte non activé
    it('should return 403 if user is not active (POST /users/login)', async () => {
        const loginData = {
            email: email,  // Utilisation de l'email généré dynamiquement
            password: 'password123'
        };

        const response = await request(app)
            .post('/users/login')
            .send(loginData)
            .expect(403);  // Modification pour gérer les comptes non actifs

        expect(response.body.message).toBe('Compte non activé. Code de confirmation envoyé.');
        expect(response.body.needsActivation).toBe(true);
    });

    // Test de l'activation du compte avec un code de confirmation dynamique
   // Avant d'exécuter le test, assure-toi que l'utilisateur a tous les champs requis.
it('should activate a user with correct confirmation code (POST /users/verify-confirmation)', async () => {
    // Créer un utilisateur avec un code de confirmation
    const confirmationCode = generateCode(); // Assurez-vous que le code est généré dynamiquement
    const newUser = await User.create({
        firstName: 'John',  // Ajouter tous les champs requis
        lastName: 'Doe',
        email: 'test@example.com',
        phone: '1234567890',
        address: '123 Main St',
        password: 'password123',
        service: 'delivery',
        confirmationCode: confirmationCode,  // Le code généré dynamiquement
        isActive: false,  // Le compte n'est pas encore activé
    });

    const confirmationData = {
        email: 'test@example.com',
        confirmationCode: confirmationCode,  // Utiliser le code dynamique généré pour correspondre
    };

    const response = await request(app)
        .post('/users/verify-confirmation')
        .send(confirmationData)
        .expect(200);

    expect(response.body.message).toBe('Compte activé avec succès');

    const updatedUser = await User.findOne({ email: 'test@example.com' });
    expect(updatedUser.isActive).toBe(true);  
});


    // Test de la récupération de tous les utilisateurs (GET /users)
    it('should retrieve all users (GET /users)', async () => {
        const response = await request(app)
            .get('/users')
            .set('Authorization', `Bearer ${token}`)  
            .expect(200);
    
        expect(Array.isArray(response.body)).toBe(true);
        if (response.body.length > 0) {
            expect(response.body[0]).toHaveProperty('firstName');
        }
    });

    // Test de la déconnexion (POST /users/logout)
    it('should logout the user (POST /users/logout)', async () => {
        const response = await request(app)
            .post('/users/logout')
            .expect(200);

        expect(response.body.message).toBe('Déconnexion réussie');
    });
});
