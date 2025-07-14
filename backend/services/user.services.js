const UserModel = require("../model/user.model");
const jwt = require("jsonwebtoken");

class UserService {
  static async registerUser(email, password, username) {
    try {
      const createUser = new UserModel({ email, password, username });
      return await createUser.save();
    } catch (err) {
      throw err;
    }
  }

  static async getUserById(_id) {
    try {
      return await UserModel.findOne({ _id });
    } catch (err) {
      throw err;
    }
  }

  static async checkuser(email) {
    try {
      return await UserModel.findOne({ email });
    } catch (error) {
      throw error;
    }
  }

  static generateToken(tokenData, secretKey, jwt_expire) {
    return jwt.sign(tokenData, secretKey, { expiresIn: jwt_expire });
  }
}

module.exports = UserService;
