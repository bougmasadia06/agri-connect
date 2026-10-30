const express = require('express');
const router = express.Router();
const PrixMarche = require('../models/PrixMarche');

router.get('/', async (req, res) => {
  const { produit, region } = req.query;
  const dernier = await PrixMarche.findOne({ 'produit.id': produit, 'region.id': region })
    .sort({ date_releve: -1 });
  res.json(dernier || { prix_moyen: null });
});

router.get('/historique', async (req, res) => {
  const { produit, region } = req.query;
  const historique = await PrixMarche.find({ 'produit.id': produit, 'region.id': region })
    .sort({ date_releve: 1 })
    .limit(30);
  res.json(historique);
});

router.post('/', async (req, res) => {
  const prix = new PrixMarche(req.body);
  await prix.save();
  res.status(201).json(prix);
});

module.exports = router;