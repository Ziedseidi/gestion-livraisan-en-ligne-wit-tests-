const Dish = require('../models/Dish.model');
const User = require('../models/User.model');
const Delivery = require('../models/Delivery.model'); // Assurez-vous d'importer le modèle Livraison

const deliveryController = {};

deliveryController.addDelivery = async (req, res) => {
  try {
    // Utilisez req.userId défini dans votre middleware
    const userId = req.userId;
    if (!userId) {
      return res.status(401).json({ message: 'User not authenticated' });
    }

    const { orderedDishes, deliveryAddress, phone } = req.body;

    // Vérifiez si l'utilisateur existe
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    // Vérifiez si tous les plats existent
    const dishes = await Dish.find({ _id: { $in: orderedDishes } });
    if (dishes.length !== orderedDishes.length) {
      return res.status(404).json({ message: "One or more dishes not found" });
    }

    // Calcul du prix total
    const totalPrice = dishes.reduce((total, dish) => total + dish.price, 0);

    // Créez une nouvelle livraison
    const newDelivery = new Delivery({
      user: userId,
      orderedDishes,
      deliveryAddress,
      phone, // Ajoutez le champ phone ici
      totalPrice,
    });

    // Sauvegardez la livraison
    const savedDelivery = await newDelivery.save();

    res.status(201).json({
      message: 'Delivery created successfully',
      delivery: savedDelivery,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Error creating delivery" });
  }
};

deliveryController.trackDeliveryStatus=async(req,res)=>{
  try {
    console.log('Utilisateur connecté:', req.userId); // Vérification dans les logs
    const userId = req.userId; // Accéder directement à userId

    if (!userId) {
        return res.status(400).json({ message: 'Utilisateur non trouvé.' });
    }

    const deliveries = await Delivery.find({ user: userId });

    if (!deliveries || deliveries.length === 0) {
        return res.status(404).json({ message: 'Aucune livraison trouvée pour cet utilisateur.' });
    }

    return res.status(200).json(deliveries);
} catch (error) {
    console.error('Erreur lors de la récupération des livraisons:', error);
    return res.status(500).json({ message: 'Erreur serveur' });
}


};

deliveryController.getAllDelivery=async(req,res)=>{
  try{
    const deliveries= await Delivery.find();
    if (deliveries.length === 0) {
      return res.status(404).json({ message: 'Aucune livraison trouvée' });
  }
  res.status(200).json(deliveries);
} catch (error) {
  console.error('Erreur lors de la récupération des livraisons:', error);
  res.status(500).json({ message: 'Erreur serveur' });
}
;}

deliveryController.UpdateStatus=async(req,res)=>{
  try {
    const { status } = req.body; // Récupère le nouveau statut

    if (!status) {
      return res.status(400).json({ message: 'Le statut est requis.' });
    }

    // Recherche de la livraison par deliveryId dans les paramètres de la route
    const delivery = await Delivery.findById(req.params.deliveryId);

    if (!delivery) {
      return res.status(404).json({ message: 'Livraison non trouvée.' });
    }

    // Mise à jour du statut
    delivery.status = status;
    await delivery.save();

    res.status(200).json({ message: 'Statut de la livraison mis à jour.', delivery });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur lors de la mise à jour du statut.' });
  }
};
deliveryController.getDeliveryStatistics=async(req,res)=>{
  try {
    // Calculer le nombre de livraisons pour chaque statut
    const ongoingDeliveries = await Delivery.countDocuments({ status: 'En cours' });
    const acceptedDeliveries = await Delivery.countDocuments({ status: 'Accepté' });
    const deliveredDeliveries = await Delivery.countDocuments({ status: 'Livrée' });
    const cancelledDeliveries = await Delivery.countDocuments({ status: 'Refusée' });

    // Retourner les statistiques au frontend
    res.json({
      ongoingDeliveries,
      acceptedDeliveries,
      deliveredDeliveries,
      cancelledDeliveries,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur lors de la récupération des statistiques.' });
  }
};




module.exports = deliveryController;