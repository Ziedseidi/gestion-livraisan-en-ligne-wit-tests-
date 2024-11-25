const request = require('supertest');
const app = require('../server'); // Chemin vers votre serveur principal
const mongoose = require('mongoose');
const Role = require('../models/Role.model');
const User = require('../models/User.model');
const jwt = require('jsonwebtoken');
const { hashPassword } = require('../utils/bcrypt'); // Assurez-vous que le chemin est correct

let adminToken; // Token pour l'utilisateur Admin
let adminUser;

beforeAll(async () => {
    // Connexion à la base de données si ce n'est pas déjà fait
    if (mongoose.connection.readyState === 0) {
        await mongoose.connect(process.env.MONGO_URI, {
            useNewUrlParser: true,
            useUnifiedTopology: true,
        });
    }

    // Créez un rôle de base "Admin" si inexistant
    let existingAdminRole = await Role.findOne({ name: 'Admin' });
    if (!existingAdminRole) {
        existingAdminRole = await Role.create({ name: 'Admin' });
    }

    // Créez un utilisateur Admin si inexistant
    adminUser = await User.findOne({ email: 'admin@example.com' });
    if (!adminUser) {
        const hashedPassword = await hashPassword('adminpassword');
        adminUser = await User.create({
            userName: 'adminuser',
            email: 'admin@example.com',
            password: hashedPassword,
            firstName: 'Admin',
            lastName: 'User',
            phone: '1234567890',
            address: 'Admin Address',
            service: 'Administration',
            roles: [existingAdminRole._id],
        });
    }

    // Génération d'un token JWT pour l'utilisateur Admin
    adminToken = jwt.sign({ userId: adminUser._id }, process.env.JWT_SECRET, { expiresIn: '1h' });
});

afterAll(async () => {
    // Nettoyage des rôles après les tests, sauf le rôle "Admin"
    await Role.deleteMany({ name: { $ne: 'Admin' } });
    
    // Supprimer l'utilisateur Admin
    await User.deleteOne({ _id: adminUser._id });
    
    // Supprimer les utilisateurs créés pour les tests
    await User.deleteMany({ email: /testuser/i });

    // Fermeture de la connexion à la base de données
    await mongoose.connection.close();
});

// Test de création d'un rôle (POST /roles/addrole)
it('should create a new role (POST /roles/addrole)', async () => {
    // Utiliser un nom de rôle unique pour éviter les duplications
    const uniqueRoleName = `TestRole_${Date.now()}`;
    const newRole = { name: uniqueRoleName };

    const response = await request(app)
        .post('/roles/addrole')
        .set('Authorization', `Bearer ${adminToken}`)
        .send(newRole)
        .expect(201);

    expect(response.body.message).toBe('Rôle créé avec succès');
    expect(response.body.role).toHaveProperty('_id');
    expect(response.body.role.name).toBe(uniqueRoleName);
});

// Test de récupération des rôles (GET /roles/Allroles)
it('should retrieve all roles (GET /roles/Allroles)', async () => {
    const response = await request(app)
        .get('/roles/Allroles')
        .set('Authorization', `Bearer ${adminToken}`)
        .expect(200);

    expect(Array.isArray(response.body)).toBe(true);
    if (response.body.length > 0) {
        expect(response.body[0]).toHaveProperty('name');
    }
});

// Test de suppression d'un rôle (DELETE /roles/:roleId)
it('should delete a role (DELETE /roles/:roleId)', async () => {
    // Créez un rôle temporaire pour le supprimer
    const uniqueRoleName = `TestRole_${Date.now()}`;
    const role = await Role.create({ name: uniqueRoleName });

    const response = await request(app)
        .delete(`/roles/${role._id}`)
        .set('Authorization', `Bearer ${adminToken}`)
        .expect(200);

    expect(response.body.message).toBe('Rôle supprimé avec succès');

    const deletedRole = await Role.findById(role._id);
    expect(deletedRole).toBeNull();
});

// Test de mise à jour d'un rôle (PUT /roles/:roleId)
it('should update a role (PUT /roles/:roleId)', async () => {
    const uniqueRoleName = `TestRole_${Date.now()}`;
    const role = await Role.create({ name: uniqueRoleName });

    const updatedRole = { name: `UpdatedRole_${Date.now()}` };

    const response = await request(app)
        .put(`/roles/${role._id}`)
        .set('Authorization', `Bearer ${adminToken}`)
        .send(updatedRole)
        .expect(200);

    expect(response.body.message).toBe('Mise à jour du rôle avec succès');
    expect(response.body.role.name).toBe(updatedRole.name);
});

// Test d'assignation d'un rôle à un utilisateur (POST /roles/assign-role)
it('should assign a role to a user (POST /roles/assign-role)', async () => {
    // Créez un utilisateur fictif avec tous les champs requis
    const hashedPassword = await hashPassword('password123');
    const user = await User.create({
        userName: 'testuser123',
        email: 'testuser123@example.com',
        password: hashedPassword,
        firstName: 'Test',
        lastName: 'User',
        phone: '1234567890',
        address: '123 Test Street',
        service: 'Test Service',
    });

    // Créez un rôle "Client"
    const role = await Role.create({ name: 'Client' });

    // Préparez les données pour l'assignation du rôle
    const userRoleData = {
        userId: user._id,
        roleName: 'Client', // Utiliser roleName conforme au contrôleur
    };

    const response = await request(app)
        .post('/roles/assign-role')
        .set('Authorization', `Bearer ${adminToken}`)
        .send(userRoleData)
        .expect(200);

    expect(response.body.message).toBe("Role assigned successfully");

    // Vérifier que le rôle a bien été attribué à l'utilisateur
    const updatedUser = await User.findById(user._id).populate('roles');
    const assignedRole = updatedUser.roles.find(r => r.name === 'Client');
    expect(assignedRole).toBeTruthy();
});
