const router = require('express').Router();
const qnaController = require('../controller/qna.controller');

router.post('/createQnA', qnaController.createqna);
router.post('/getQnA', qnaController.getqna);
router.put('/editQnA', qnaController.editqna);
router.delete('/deleteQnA/:id', qnaController.deleteqna);
router.post('/getUserQnA', qnaController.getUserQnA);
router.post('/upvoteuser', qnaController.upvoteuser);
router.post('/addComment', qnaController.addcomment);
router.post('/getComment', qnaController.getcomment);

module.exports = router;
