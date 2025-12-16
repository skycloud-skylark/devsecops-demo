const express = require('express');
const express = require('express');
const app = express();

app.get('/health', (req, res) => {
  res.send('App running successfully');
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
});
