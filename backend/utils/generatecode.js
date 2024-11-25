const generateCode = () => {
    const min = 10000000; // 8 chiffres
    const max = 99999999;
    return Math.floor((Math.random() * (max - min + 1)) + min).toString();
};

module.exports = generateCode;  // Export par défaut
