const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { authMiddleware } = require('../middleware/auth');

const dossier = path.join(__dirname, '..', 'uploads');
if (!fs.existsSync(dossier)) fs.mkdirSync(dossier);

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, dossier),
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase();
    cb(null, `${Date.now()}-${Math.round(Math.random() * 1e6)}${ext}`);
  }
});

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5 Mo maximum
  fileFilter: (req, file, cb) => {
    if (!/\.(jpe?g|png|webp|gif)$/i.test(file.originalname)) {
      return cb(new Error('Seules les images (jpg, png, webp, gif) sont acceptées'));
    }
    cb(null, true);
  }
});

const router = express.Router();

router.post('/', authMiddleware, upload.single('image'), (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'Aucune image reçue' });
  res.status(201).json({ url: `/uploads/${req.file.filename}` });
});

module.exports = router;