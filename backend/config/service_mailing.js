require('dotenv').config();  // Charger les variables d'environnement depuis le fichier .env
const nodemailer = require('nodemailer');

// Création du transporteur avec Gmail et les informations d'authentification
const transporter = nodemailer.createTransport({
    service: "gmail",
    host: "smtp.gmail.com",
    port: 465,
    secure: true,
    auth: {
        user: process.env.GMAIL_USER,  // Utilisation de l'utilisateur depuis les variables d'environnement
        pass: process.env.GMAIL_PASS,  // Utilisation du mot de passe depuis les variables d'environnement
    },
    tls: {
        rejectUnauthorized: false  // Désactive la vérification du certificat SSL (inutile en local)
    }
});

// Fonction pour envoyer l'email
const sendMail = async (to, object, content, isHtml) => {
    console.log(`Envoi de l'email à : ${to}`);
    console.log(`Objet de l'email : ${object}`);

    const mailOptions = {
        from: process.env.GMAIL_USER,  // L'adresse d'envoi (doit être la même que celle utilisée dans auth.user)
        to: to, 
        subject: object,
        [isHtml ? 'html' : 'text']: content,  // Choix entre HTML et texte brut
    };

    try {
        const info = await transporter.sendMail(mailOptions);  // Envoi de l'email
        console.log('E-mail envoyé : ' + info.response);  // Affichage de la réponse
    } catch (err) {
        console.log('Erreur lors de l\'envoi de l\'email :', err);  // Gestion des erreurs
    }
};

module.exports = { sendMail };  // Exporter la fonction pour l'utiliser ailleurs dans votre projet
