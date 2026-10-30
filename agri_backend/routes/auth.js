const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const Utilisateur = require('../models/Utilisateur');
const { authMiddleware } = require('../middleware/auth');

router.post('/register', async (req, res) => {
  try {
    const existant = await Utilisateur.findOne({ telephone: req.body.telephone });
    if (existant) return res.status(400).json({ error: 'Téléphone déjà utilisé' });

    const utilisateur = new Utilisateur(req.body);
    await utilisateur.save();

    const token = jwt.sign(
      { id: utilisateur._id, type: utilisateur.type, nom: utilisateur.nom, telephone: utilisateur.telephone },
      process.env.JWT_SECRET,
      { expiresIn: '30d' }
    );
    res.status(201).json({ token, utilisateur });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.post('/login', async (req, res) => {
  const { telephone, mot_de_passe } = req.body;
  const utilisateur = await Utilisateur.findOne({ telephone });
  if (!utilisateur || !(await utilisateur.verifierMotDePasse(mot_de_passe))) {
    return res.status(401).json({ error: 'Identifiants incorrects' });
  }

  const token = jwt.sign(
    { id: utilisateur._id, type: utilisateur.type, nom: utilisateur.nom, telephone: utilisateur.telephone },
    process.env.JWT_SECRET,
    { expiresIn: '30d' }
  );
  res.json({ token, utilisateur });
});

router.get('/me', authMiddleware, async (req, res) => {
  const utilisateur = await Utilisateur.findById(req.user.id).select('-mot_de_passe');
  res.json(utilisateur);
});

module.exports = router;