const router = require('express').Router();
const qnaController = require('../controller/qna.controller'); // ✅ CORRECT

router.post('/createQnA', qnaController.createqna); // ✅ Accepts (req, res)
router.post('/getQnA', qnaController.getqna);       // ✅ Accepts (req, res)
router.put('/editQnA', qnaController.editqna);  
router.delete('/deleteQnA/:id', qnaController.deleteqna);  
module.exports = router;
