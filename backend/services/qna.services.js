const qnaModel = require("../model/qna.model");

class QnAServices {
  static async createqna(useremail,subject, ques, companyname,count) {
    const createqnaitem = new qnaModel({useremail, subject, ques, companyname,count }); // ✅ updated field
    return await createqnaitem.save();
  }

  static async getqna(subject) {
    const qnadata = await qnaModel.find({ subject });
    return qnadata;
  }
    static async getUserQnA(useremail) {
    const qnadata = await qnaModel.find({useremail});
    return qnadata;
  }
  static async getQuesObj(_id)
  {
    return await qnaModel.findById(_id);
  }

  static async editqna(_id, ques, companyname,count) {
    return await qnaModel.findByIdAndUpdate(_id, { ques, companyname ,count}); // ✅ updated field
  }

  static async deleteqna(id) {
    return await qnaModel.findByIdAndDelete(id);
  }
}

module.exports = QnAServices;
