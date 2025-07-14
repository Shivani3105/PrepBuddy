const qnaServices = require("../services/qna.services");

const createqna = async (req, res, next) => {
  try {
    const { useremail, subject, ques, companyname, count } = req.body;
    const qnaitem = await qnaServices.createqna(useremail, subject, ques, companyname, count);
    //qnaitem.upvotedby.push(useremail);
    await qnaitem.save();
    res.status(201).json({
      status: true,
      success: qnaitem,
    });
  } catch (error) {
    next(error);
  }
};

const addcomment = async (req, res, next) => {
  try {
    const { _id, username, comment } = req.body;
    const ques = await qnaServices.getQuesObj(_id);

    if (!ques) {
      return res.status(404).json({ message: "Question not found" });
    }

    ques.commentSection.push({ user: username, comment });
    await ques.save();

    res.status(201).json({
      status: true,
      success: ques.commentSection
    });
  } catch (error) {
    next(error);
  }
};

const getcomment = async (req, res, next) => {
  try {
    const { _id } = req.body;
    const ques = await qnaServices.getQuesObj(_id);

    if (!ques) {
      return res.status(404).json({ message: "Question not found" });
    }

    res.status(200).json({
      status: true,
      success: ques.commentSection,
    });
  } catch (error) {
    next(error);
  }
};

const getqna = async (req, res, next) => {
  try {
    const { subject } = req.body;
    const qnaitem = await qnaServices.getqna(subject);
    res.status(200).json({
      status: true,
      success: qnaitem,
    });
  } catch (error) {
    next(error);
  }
};

const getUserQnA = async (req, res, next) => {
  try {
    const { email } = req.body;
    const Userqnaitem = await qnaServices.getUserQnA(email);
    res.status(200).json({
      status: true,
      success: Userqnaitem,
    });
  } catch (error) {
    next(error);
  }
};

const editqna = async (req, res, next) => {
  try {
    const { _id, ques, companyname, count } = req.body;
    const edititem = await qnaServices.editqna(_id, ques, companyname, count);
    res.status(201).json({
      status: true,
      success: edititem,
    });
  } catch (error) {
    next(error);
  }
};

const upvoteuser = async (req, res, next) => {
  try {
    const { _id, userId } = req.body; // userId is the user's email or unique identifier

    const quesobj = await qnaServices.getQuesObj(_id);
    if (!quesobj) {
      return res.status(404).json({ message: "Question not found" });
    }

    if (!quesobj.upvotedby.includes(userId)) {
      quesobj.count += 1;
      quesobj.upvotedby.push(userId);
      await quesobj.save();
      return res.status(200).json({ status: true, message: "Upvoted" });
    } else {
      // Remove userId from upvotedby array
      const index = quesobj.upvotedby.indexOf(userId);
      if (index !== -1) {
        quesobj.upvotedby.splice(index, 1);
      }
      quesobj.count -= 1;
      await quesobj.save();
      return res.status(200).json({ status: false, message: "Upvote removed" });
    }
  } catch (error) {
    next(error);
  }
};


const deleteqna = async (req, res, next) => {
  try {
    const deleteitem = await qnaServices.deleteqna(req.params.id);
    res.status(200).json({
      status: true,
      success: deleteitem,
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  createqna,
  getqna,
  editqna,
  deleteqna,
  getUserQnA,
  upvoteuser,
  addcomment,
  getcomment,
};
