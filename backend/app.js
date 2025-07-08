const express=require('express');
const cors = require('cors');
const app = express();

app.use(cors());  
const userRoutes=require('./routes/user.routes');
const todoRoutes=require('./routes/todo.routes');
const qnaRoutes=require('./routes/qna.routes');
app.use(express.json());
app.use('/',userRoutes);
app.use('/',todoRoutes);
app.use('/',qnaRoutes);
module.exports=app;