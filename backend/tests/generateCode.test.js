const generateCode = require('../utils/generatecode') // Assurez-vous que la casse correspond

describe('generateCode', () => {
    it('should generate a valid 8-digit code', () => {
        const code = generateCode();  
        expect(code).toMatch(/^\d{8}$/); // verification que le code contietn 8 chifres
    });
});
