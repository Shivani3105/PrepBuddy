


require('dotenv').config();
const app = require('./app');
const port = process.env.PORT;
//const app = require('./app');
//const port = 3000;
//console.log("mongouri : ",)
app.get('/', (req, res) => {
    res.send("connection setup");
});
app.listen(port, () => {
  console.log(`✅ Server running on ${port}`);
});
