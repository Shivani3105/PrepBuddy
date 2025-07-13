const qnaServices = require("../services/qna.services");

// ✅ Create new QnA
exports.createqna = async (req, res, next) => {
  try {
    const { useremail, subject, ques, companyname, count } = req.body;
    const qnaitem = await qnaServices.createqna(useremail, subject, ques, companyname, count);
    qnaitem.upvotedby.push(useremail);
    await qnaitem.save(); // ✅ important
    res.status(201).json({
      status: true,
      success: qnaitem,
    });
  } catch (error) {
    next(error);
  }
};

// ✅ Add comment using Map: useremail => comment
exports.addcomment = async (req, res, next) => {
  try {
    const { _id, useremail, comment } = req.body;
    const ques = await qnaServices.getQuesObj(_id);

    if (!ques) {
      return res.status(404).json({ message: "Question not found" });
    }

    // 🔥 Use Map.set() to store comment
    ques.commentSection.set(useremail, comment);
    await ques.save();

    res.status(201).json({
      status: true,
      success: Object.fromEntries(ques.commentSection),
    });
  } catch (error) {
    next(error);
  }
};

// ✅ Get all comments for a question
exports.getcomment = async (req, res, next) => {
  try {
    const { _id } = req.body;
    const ques = await qnaServices.getQuesObj(_id);

    if (!ques) {
      return res.status(404).json({ message: "Question not found" });
    }

    res.status(200).json({
      status: true,
      success: Object.fromEntries(ques.commentSection), // Map to plain object
    });
  } catch (error) {
    next(error);
  }
};

// ✅ Get QnAs by subject
exports.getqna = async (req, res, next) => {
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

// ✅ Get QnAs by user
exports.getUserQnA = async (req, res, next) => {
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

// ✅ Edit QnA
exports.editqna = async (req, res) => {
  const { _id, ques, companyname, count } = req.body;
  const edititem = await qnaServices.editqna(_id, ques, companyname, count);
  res.status(201).json({
    status: true,
    success: edititem,
  });
};

// ✅ Upvote QnA
exports.upvoteuser = async (req, res, next) => {
  try {
    const { _id, useremail } = req.body;
    const quesobj = await qnaServices.getQuesObj(_id);

    if (!quesobj) {
      return res.status(404).json({ message: "Question not found" });
    }

    if (!quesobj.upvotedby.includes(useremail)) {
      quesobj.count += 1;
      quesobj.upvotedby.push(useremail);
      await quesobj.save();
      return res.status(200).json({ message: "Successfully upvoted" });
    } else {
      return res.status(400).json({ message: "You have already upvoted this question" });
    }
  } catch (error) {
    next(error);
  }
};

// ✅ Delete QnA
exports.deleteqna = async (req, res, next) => {
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

// ✅ Export all
module.exports = {
  createqna: exports.createqna,
  getqna: exports.getqna,
  editqna: exports.editqna,
  deleteqna: exports.deleteqna,
  getUserQnA: exports.getUserQnA,
  upvoteuser: exports.upvoteuser,
  addcomment: exports.addcomment,
  getcomment: exports.getcomment,
};
