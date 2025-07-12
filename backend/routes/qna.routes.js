const router = require('express').Router();
const qnaController = require('../controller/qna.controller');

router.post('/createQnA', qnaController.createqna);
router.post('/getQnA', qnaController.getqna);
router.put('/editQnA', qnaController.editqna);
router.delete('/deleteQnA/:id', qnaController.deleteqna);
router.post('/getUserQnA', qnaController.getUserQnA);
router.post('/upvoteuser', qnaController.upvoteuser);

module.exports = router;
