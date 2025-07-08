const mongoose=require('mongoose');
const db=require('../db');
const UserModel=require('./user.model');
const {Schema}=mongoose;
const todoSchema=new Schema({
    userId:{
        type:Schema.Types.ObjectId,
        ref:UserModel.modelName,
    },
    title:{
        type:String,
        required:true,

    },
    desc:{
        required:true,
        type:String,
    }

});
const TodoModel=db.model('todo',todoSchema);
module.exports=TodoModel;