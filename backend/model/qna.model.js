const mongoose=require('mongoose');
const db=require('../db');
const UserModel = require('./user.model');
const {Schema}=mongoose;
const qnaSchema=new Schema({
    useremail:{
     type:String,
        required:true,
     },
    subject:{
        type:String,
        required:true
    },
    ques:{
        type:String,
        required:true
    },
    companyname:{
        type:String,
        required:true
    },
    count:{
        type:Number,
        default:0
    },
    upvotedby:{
        type:[String],
        default:[]
    }
});
const qnaModel=db.model('qna',qnaSchema);
module.exports=qnaModel;