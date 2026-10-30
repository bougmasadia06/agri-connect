const mongoose = require('mongoose');

const regionSchema = new mongoose.Schema({ nom: { type: String, required: true } });
const produitSchema = new mongoose.Schema({
  nom: { type: String, required: true },
  unite: { type: String, required: true }
});

module.exports = {
  Region: mongoose.model('Region', regionSchema),
  Produit: mongoose.model('Produit', produitSchema)
};