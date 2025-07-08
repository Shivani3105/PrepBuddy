const qnaServices = require("../services/qna.services");

exports.createqna = async (req, res, next) => {
    try {
        const {useremail, subject, ques, companyname,count } = req.body;
        const qnaitem = await qnaServices.createqna(useremail,subject, ques, companyname,count);

        res.status(201).json({
            status: true,
            success: qnaitem,
        });
    } catch (error) {
        next(error);
    }
};

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

exports.editqna=async (req,res) =>{

        const{_id,ques,companyname,count}=req.body;
        const edititem=await qnaServices.editqna(_id,ques,companyname,count);
        res.status(201).json({
            status:true,
            success:edititem,
        });
    
}
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
//updateCountQnA
module.exports = {
    createqna: exports.createqna,
    getqna: exports.getqna,
    editqna: exports.editqna,
    deleteqna: exports.deleteqna,

};
