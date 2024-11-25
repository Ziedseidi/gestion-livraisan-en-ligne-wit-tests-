module.exports = {
    testEnvironment: 'node',
    testMatch: ['**/__tests__/**/*.test.js'], // Cherche les fichiers de test JS dans le dossier __tests__
    verbose: true, // Affiche des informations détaillées lors des tests
    clearMocks: true, // Nettoie automatiquement les mocks entre chaque test
    setupFiles: ['dotenv/config'], // Charge les variables d'environnement depuis un fichier .env
    moduleFileExtensions: ['js', 'json', 'node'], // Extensions supportées
  };
  