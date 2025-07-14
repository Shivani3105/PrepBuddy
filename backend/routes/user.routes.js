const router=require('express').Router();
const {register,login,getUser}=require("../controller/user.controller");
router.post('/registration',register);
router.post('/login',login);
router.post('/getUser',getUser);
module.exports=router;
