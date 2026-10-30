require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const app = express();
const cors = require('cors');
app.use(cors());

app.use(express.json());
app.use('/api/auth', require('./routes/auth'));
app.use('/api/annonces', require('./routes/annonces'));
app.use('/api/prix', require('./routes/prix'));
app.use('/api', require('./routes/referentiels'));

mongoose.connect(process.env.MONGODB_URI)
  .then(() => app.listen(process.env.PORT || 5000, () => console.log('Serveur démarré')))
  .catch(err => console.error(err));