const bcrypt = require('bcryptjs');

const hashPassword = async (password) => {
    const salt = await bcrypt.genSalt(10);  // Générer un "salt"
    return await bcrypt.hash(password, salt);  // Hacher le mot de passe avec le "salt"
};

const comparePassword = async (plainPassword, hashedPassword) => {
    if (typeof plainPassword !== 'string' || typeof hashedPassword !== 'string') {
        throw new Error('Les mots de passe doivent être des chaînes');
    }
    return await bcrypt.compare(plainPassword, hashedPassword);  // Comparer les mots de passe
};

module.exports = { hashPassword, comparePassword };
