const bcrypt = require('bcryptjs');
const { comparePassword } = require('../utils/bcrypt'); // Assurez-vous que le chemin est correct

const plainPassword = '123456';
let hashedPassword;

beforeAll(async () => {
    // Créer un hachage avec un sel de coût de 10
    hashedPassword = await bcrypt.hash(plainPassword, 10);
});

describe('comparePassword', () => {
    test('devrait retourner true si les mots de passe correspondent', async () => {
        const result = await comparePassword(plainPassword, hashedPassword);
        expect(result).toBe(true); // Le mot de passe brut doit correspondre au haché
    });

    test('devrait retourner false si les mots de passe ne correspondent pas', async () => {
        const wrongPassword = 'wrongpassword';
        const result = await comparePassword(wrongPassword, hashedPassword);
        expect(result).toBe(false);
    });

    test('devrait lancer une erreur si le mot de passe brut ou haché ne sont pas des chaînes', async () => {
        await expect(comparePassword(12345, hashedPassword)).rejects.toThrow('Les mots de passe doivent être des chaînes');
        await expect(comparePassword(plainPassword, 12345)).rejects.toThrow('Les mots de passe doivent être des chaînes');
    });
});
