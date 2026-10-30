const express = require('express');
const router = express.Router();
const { Region, Produit } = require('../models/Region');

router.get('/regions', async (req, res) => res.json(await Region.find()));
router.get('/produits', async (req, res) => res.json(await Produit.find()));

module.exports = router;