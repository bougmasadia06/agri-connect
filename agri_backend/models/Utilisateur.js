const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const utilisateurSchema = new mongoose.Schema({
  nom: { type: String, required: true },
  telephone: { type: String, required: true, unique: true },
  type: { type: String, enum: ['agriculteur', 'acheteur'], required: true },
  mot_de_passe: { type: String, required: true },
  region: {
    id: { type: mongoose.Schema.Types.ObjectId, ref: 'Region' },
    nom: String
  }
}, { timestamps: true });

utilisateurSchema.pre('save', async function() {
  if (!this.isModified('mot_de_passe')) return;
  this.mot_de_passe = await bcrypt.hash(this.mot_de_passe, 10);
});

utilisateurSchema.methods.verifierMotDePasse = function(motDePasse) {
  return bcrypt.compare(motDePasse, this.mot_de_passe);
};

module.exports = mongoose.model('Utilisateur', utilisateurSchema);