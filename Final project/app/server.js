// Minimal Express app with file + console logging and a health endpoint
const express = require('express');
const fs = require('fs');
const path = require('path');
const morgan = require('morgan');

const app = express();
const PORT = process.env.PORT || 3000;

// Ensure logs directory exists (mapped to host at /var/log/<APP_NAME>)
const logsDir = path.join(__dirname, 'logs');
if (!fs.existsSync(logsDir)) {
  fs.mkdirSync(logsDir, { recursive: true });
}
const accessLogStream = fs.createWriteStream(path.join(logsDir, 'app.log'), { flags: 'a' });

// HTTP logging to file AND console
app.use(morgan('combined', { stream: accessLogStream }));
app.use(morgan('dev'));

app.get('/', (req, res) => {
  res.send('🚀 DevOps demo app running (Node.js + Docker + Jenkins + EC2).');
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', ts: new Date().toISOString() });
});

app.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});