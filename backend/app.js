const express = require('express');
const cors = require('cors');
const app = express();

// ✅ Use CORS with correct frontend origin
app.use(cors({
  origin: [
    "https://prepbuddy-3.onrender.com", // 🔁 Replace with your actual frontend domain
    "http://localhost:3000"             // Optional for local testing
  ],
  methods: ["GET", "POST", "PUT", "DELETE"],
  credentials: true
}));

app.use(express.json());

// ✅ Routes
const userRoutes = require('./routes/user.routes');
const todoRoutes = require('./routes/todo.routes');
const qnaRoutes = require('./routes/qna.routes');

app.use('/', userRoutes);
app.use('/', todoRoutes);
app.use('/', qnaRoutes);

module.exports = app;
