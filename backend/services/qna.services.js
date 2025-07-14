const qnaModel = require("../model/qna.model");

class QnAServices {
  static async createqna(useremail, subject, ques, companyname, count) {
    const createqnaitem = new qnaModel({ useremail, subject, ques, companyname, count });
    return await createqnaitem.save();
  }

  static async getqna(subject) {
    return await qnaModel.find({ subject });
  }

  static async getUserQnA(email) {
    return await qnaModel.find({ useremail: email });
  }

  static async getQuesObj(_id) {
    return await qnaModel.findById(_id);
  }

  static async editqna(_id, ques, companyname, count) {
    return await qnaModel.findByIdAndUpdate(_id, { ques, companyname, count });
  }

  static async deleteqna(id) {
    return await qnaModel.findByIdAndDelete(id);
  }
}

module.exports = QnAServices;
