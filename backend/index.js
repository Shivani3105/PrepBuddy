// server.js
const app = require('./app');
const port = 3000;
app.get('/', (req, res) => {
    res.send("connection setup");
});
app.listen(port, () => {
  console.log(`✅ Server running on http://192.168.1.36:${port}`);
});
