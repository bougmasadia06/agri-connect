require('dotenv').config();
const mongoose = require('mongoose');
const { Region, Produit } = require('./models/Region');
const PrixMarche = require('./models/PrixMarche');

async function seed() {
  await mongoose.connect(process.env.MONGODB_URI);

  await Region.deleteMany({});
  await Produit.deleteMany({});
  await PrixMarche.deleteMany({});

  const regions = await Region.insertMany([
    { nom: 'Koudougou' },
    { nom: 'Ouagadougou' },
    { nom: 'Bobo-Dioulasso' },
  ]);

  const produits = await Produit.insertMany([
    { nom: 'Mil', unite: 'kg' },
    { nom: 'Tomates', unite: 'kg' },
    { nom: 'Maïs', unite: 'kg' },
  ]);

  // Prix d'exemple pour la démo : un relevé par semaine sur 6 semaines
  const prixBase = { Mil: 210, Tomates: 330, 'Maïs': 190 };
  const releves = [];
  for (const p of produits) {
    for (const r of regions) {
      for (let i = 5; i >= 0; i--) {
        const date = new Date();
        date.setDate(date.getDate() - i * 7);
        releves.push({
          produit: { id: p._id, nom: p.nom },
          region: { id: r._id, nom: r.nom },
          prix_moyen: prixBase[p.nom] + Math.round((Math.random() - 0.5) * 30),
          date_releve: date,
        });
      }
    }
  }
  await PrixMarche.insertMany(releves);

  console.log(`${regions.length} régions, ${produits.length} produits, ${releves.length} relevés de prix ajoutés`);
  await mongoose.disconnect();
}

seed().catch((err) => {
  console.error(err);
  process.exit(1);
});