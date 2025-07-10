const mongoose=require('mongoose')
const connection=mongoose.createConnection(process.env.MONGO_URI).on('open',()=>{
    console.log("connection with mongoDB setup");
    
}).on('error',()=>{
    console.log("connection not setup");
});
module.exports=connection;