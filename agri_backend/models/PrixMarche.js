const mongoose = require('mongoose');

const prixMarcheSchema = new mongoose.Schema({
  produit: {
    id: { type: mongoose.Schema.Types.ObjectId, ref: 'Produit' },
    nom: String
  },
  region: {
    id: { type: mongoose.Schema.Types.ObjectId, ref: 'Region' },
    nom: String
  },
  prix_moyen: { type: Number, required: true },
  date_releve: { type: Date, default: Date.now }
});

prixMarcheSchema.index({ 'produit.id': 1, 'region.id': 1, date_releve: -1 });

module.exports = mongoose.model('PrixMarche', prixMarcheSchema);