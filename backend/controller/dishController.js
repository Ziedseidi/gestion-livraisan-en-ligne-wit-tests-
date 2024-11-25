const Dish = require('../models/Dish.model');
const User = require('../models/User.model');

const dishController = {};

// Ajouter une méthode pour ajouter un plat
dishController.addDish = async (req, res) => {
    try {
        const { name, category, description, price, restaurantName, image } = req.body;
    
        // Récupérer l'ID utilisateur depuis le token JWT
        const userId = req.userId; // Assurez-vous que `req.userId` est extrait du token dans le middleware d'authentification
    
        // Créer un nouveau plat
        const newDish = new Dish({
          name,
          category,
          description,
          price,
          restaurantName,
          createdBy: userId, // Lier le plat à l'utilisateur via le token
          image,
        });
    
        // Sauvegarder le plat
        const savedDish = await newDish.save();
    
        res.status(201).json({
          message: "Plat ajouté avec succès",
          dish: savedDish,
        });
      } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Erreur lors de l'ajout du plat" });
      }
};


dishController.deleteDish = async (req, res) => {
    try {
        const { dishId } = req.params; // Utilisez dishId ici

        // Supprimez le plat par son ID
        const deletedDish = await Dish.findByIdAndDelete(dishId);

        if (!deletedDish) {
            return res.status(404).json({ message: "Plat non trouvé" });
        }

        res.status(200).json({ message: "Plat supprimé avec succès" });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Erreur lors de la suppression du plat" });
    }
};
dishController.getAllDishs=async(req,res)=>{
    try {
        const dishes = await Dish.find();
        
        if (dishes.length === 0) {
          return res.status(404).json({ message: 'Aucun plat trouvé' });
        }
        
        // Retourner la liste des plats
        return res.status(200).json(dishes);
      } catch (error) {
        console.error(error);
        return res.status(500).json({ message: 'Erreur du serveur', error: error.message });
      }
};
// Exporter le contrôleur
module.exports = dishController;
