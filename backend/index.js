//const fs = require('fs');

// // Step 1: Raw .env check
// try {
//   const envFileContent = fs.readFileSync('./.env', 'utf8');
//   console.log("🧪 .env file content:\n" + envFileContent);
// } catch (err) {
//   console.error("❌ Couldn't read .env file:", err.message);
// }

// require('dotenv').config(); // Must come AFTER file is confirmed present

// // Step 2: Print environment values
// console.log("🔍 process.env.MONGO_URI:", process.env.MONGO_URI);
// console.log("🔍 process.env.JWT_SECRET:", process.env.JWT_SECRET);


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
  console.log(`✅ Server running on http://192.168.1.37:${port}`);
});