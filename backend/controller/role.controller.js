const express=require('express')
const Role = require('../models/Role.model');
const User=require('../models/User.model')  // Corriger l'importation

const roleController = {};

roleController.addRole = async (req, res) => {
    try {
        const { name, description } = req.body;

        if (!name) {
            return res.status(400).json({ message: 'Le nom du rôle est requis' });
        }

        const existingRole = await Role.findOne({ name });
        if (existingRole) {
            return res.status(409).json({ message: 'Le rôle existe déjà' });
        }

        const newRole = new Role({
            name,
            description,
        });

        await newRole.save();

        return res.status(201).json({ message: 'Rôle créé avec succès', role: newRole });
    } catch (error) {
        console.error('Erreur lors de la création du rôle:', error);
        return res.status(500).json({ message: 'Erreur lors de la création du rôle' });
    }
};
roleController.getAllroles = async(req,res)=>{
    try {
        const roles = await Role.find();
        res.status(200).json(roles);
    } catch (error) {
        console.error('Error fetching roles:', error);
        res.status(500).json({ message: 'Error fetching roles' });
    }
};
roleController.deleteRole=async(req,res)=>{
    const { roleId } = req.params;  // Récupère l'ID du rôle à partir des paramètres

    try {
        const deletedRole = await Role.findByIdAndDelete(roleId);  // Supprime le rôle par son ID
        if (!deletedRole) {
            return res.status(404).json({ message: 'Rôle introuvable' });
        }

        res.status(200).json({ message: 'Rôle supprimé avec succès' });
    } catch (error) {
        console.error('Erreur lors de la suppression du rôle :', error);
        res.status(500).json({ message: 'Erreur lors de la suppression du rôle' });
    }
};
roleController.updateRole = async (req, res) => {
    const { roleId } = req.params; // Récupérer l'ID du rôle à partir des paramètres de l'URL
    const { name, description } = req.body; // Récupérer les nouvelles données à partir du corps de la requête

    try {
        const role = await Role.findById(roleId); // Chercher le rôle par son ID
        if (!role) {
            return res.status(404).json({ message: 'Rôle non trouvé' }); // Retourner 404 si le rôle n'existe pas
        }

        // Mettre à jour les informations du rôle
        role.name = name; // Mettre à jour le nom
        role.description = description; // Mettre à jour la description

        await role.save(); // Enregistrer les modifications

        // Renvoyer l'objet rôle mis à jour dans la réponse
        return res.status(200).json({ 
            message: 'Mise à jour du rôle avec succès',
            role: role // Inclure l'objet `role` dans la réponse
        });
    } catch (error) {
        console.error(error); // Afficher l'erreur dans la console
        return res.status(500).json({ message: 'Erreur de mise à jour' }); // Retourner une erreur 500
    }
};


roleController.assignRoleToUser = async (req, res) => {
    try {
      const { userId, roleName } = req.body; // Récupérer userId et roleName du corps de la requête
  
      // Vérifier que les champs requis sont présents
      if (!userId || !roleName) {
        return res.status(400).json({ message: 'userId and roleName are required' });
      }
  
      // Trouver l'utilisateur en utilisant l'ID
      const user = await User.findById(userId);
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }
  
      // Trouver le rôle par son nom
      const role = await Role.findOne({ name: roleName });
      if (!role) {
        return res.status(404).json({ message: 'Role not found' });
      }
  
      // Vérifier si le rôle n'est pas déjà assigné
      if (user.roles.includes(role._id)) {
        return res.status(400).json({ message: 'Role already assigned to this user' });
      }
  
      // Ajouter l'ID du rôle à la liste des rôles de l'utilisateur
      user.roles.push(role._id);
      await user.save();
  
      // Retourner une réponse de succès
      res.status(200).json({ message: 'Role assigned successfully' });
    } catch (error) {
      console.error('Error assigning role:', error);
      res.status(500).json({ message: 'Error assigning role' });
    }
  };
  
  



module.exports = roleController;
