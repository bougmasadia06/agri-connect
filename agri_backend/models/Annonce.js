const mongoose = require('mongoose');

const annonceSchema = new mongoose.Schema({
  utilisateur: {
    id: { type: mongoose.Schema.Types.ObjectId, ref: 'Utilisateur' },
    nom: String,
    telephone: String
  },
  produit: {
    id: { type: mongoose.Schema.Types.ObjectId, ref: 'Produit' },
    nom: String,
    unite: String
  },
  region: {
    id: { type: mongoose.Schema.Types.ObjectId, ref: 'Region' },
    nom: String
  },
  quantite_disponible: { type: Number, required: true },
  prix_propose: { type: Number, required: true },
  statut: { type: String, enum: ['active', 'vendue'], default: 'active' },
  date_publication: { type: Date, default: Date.now },
  contacts: [{
    utilisateur_id: mongoose.Schema.Types.ObjectId,
    nom: String,
    telephone: String,
    date_contact: { type: Date, default: Date.now }
  }]
});

annonceSchema.index({ 'produit.id': 1, 'region.id': 1, statut: 1 });

module.exports = mongoose.model('Annonce', annonceSchema);