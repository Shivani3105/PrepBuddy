const mongoose=require('mongoose')
const connection=mongoose.createConnection('mongodb://localhost:27017/newtodo').on('open',()=>{
    console.log("connection with mongoDB setup");
    
}).on('error',()=>{
    console.log("connection not setup");
});
module.exports=connection;