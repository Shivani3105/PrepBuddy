const router=require('express').Router();
const {createTodo,getUserTodo}=require('../controller/todo.controller');

router.post('/storeTodo',createTodo);
router.post('/getTodo',getUserTodo);
//router.delete('/delete',deletetodo);
module.exports=router;