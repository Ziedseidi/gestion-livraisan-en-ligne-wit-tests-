const request = require('supertest');
const app = require('../server');  // Importer l'application Express exportée

describe('Test API de santé', () => {
  it('Devrait répondre avec un statut 200 pour /api/health', async () => {
    const response = await request(app).get('/api/health');
    expect(response.status).toBe(200);
    expect(response.body.message).toBe('Server is running');  // Assurez-vous que cette route existe
  });
});
