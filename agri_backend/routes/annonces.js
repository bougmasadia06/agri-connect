const express = require('express');
const router = express.Router();
const Annonce = require('../models/Annonce');
const { authMiddleware } = require('../middleware/auth');

router.get('/', async (req, res) => {
  const { produit, region, statut } = req.query;
  const filtre = { statut: statut || 'active' };
  if (produit) filtre['produit.id'] = produit;
  if (region) filtre['region.id'] = region;

  const annonces = await Annonce.find(filtre).sort({ date_publication: -1 }).limit(50);
  res.json(annonces);
});

router.get('/:id', async (req, res) => {
  const annonce = await Annonce.findById(req.params.id);
  if (!annonce) return res.status(404).json({ error: 'Annonce introuvable' });
  res.json(annonce);
});

router.post('/', authMiddleware, async (req, res) => {
  if (req.user.type !== 'agriculteur') {
    return res.status(403).json({ error: 'Réservé aux agriculteurs' });
  }
  const annonce = new Annonce({
    ...req.body,
    utilisateur: { id: req.user.id, nom: req.user.nom, telephone: req.user.telephone },
    statut: 'active'
  });
  await annonce.save();
  res.status(201).json(annonce);
});

router.patch('/:id/statut', authMiddleware, async (req, res) => {
  const annonce = await Annonce.findById(req.params.id);
  if (!annonce) return res.status(404).json({ error: 'Annonce introuvable' });
  if (String(annonce.utilisateur.id) !== req.user.id) {
    return res.status(403).json({ error: 'Non autorisé' });
  }
  annonce.statut = req.body.statut;
  await annonce.save();
  res.json(annonce);
});

router.post('/:id/contacter', authMiddleware, async (req, res) => {
  if (req.user.type !== 'acheteur') {
    return res.status(403).json({ error: 'Réservé aux acheteurs' });
  }
  const annonce = await Annonce.findByIdAndUpdate(
    req.params.id,
    { $push: { contacts: {
        utilisateur_id: req.user.id,
        nom: req.user.nom,
        telephone: req.user.telephone,
        date_contact: new Date()
      } } },
    { new: true }
  );
  res.json(annonce);
});

router.delete('/:id', authMiddleware, async (req, res) => {
  const annonce = await Annonce.findById(req.params.id);
  if (!annonce) return res.status(404).json({ error: 'Annonce introuvable' });
  if (String(annonce.utilisateur.id) !== req.user.id) {
    return res.status(403).json({ error: 'Non autorisé' });
  }
  await annonce.deleteOne();
  res.json({ message: 'Annonce supprimée' });
});

module.exports = router;