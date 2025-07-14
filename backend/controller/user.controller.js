const UserService = require('../services/user.services');

const register = async (req, res) => {
  try {
    const { email, password, username } = req.body;
    const createUser = await UserService.registerUser(email, password, username);

    res.status(201).json({
      message: "User created successfully",
      user: {
        email: createUser.email,
        id: createUser._id,
        username: createUser.username
      }
    });
  } catch (error) {
    res.status(500).json({
      message: "User not created",
      error: error.message
    });
  }
};

const getUser = async (req, res) => {
  try {
    const { email } = req.body; // changed from _id to email
    const user = await UserService.getUser(email);

    if (!user) {
      return res.status(401).json({
        status: false,
        message: "User doesn't exist"
      });
    }

    return res.status(200).json({
      status: true,
      user
    });
  } catch (error) {
    res.status(500).json({
      status: false,
      message: "Internal Server Error",
      error: error.message
    });
  }
};

const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await UserService.checkuser(email);

    if (!user) {
      return res.status(401).json({
        status: false,
        message: "User doesn't exist"
      });
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({
        status: false,
        message: "Invalid password"
      });
    }

    const tokenData = { _id: user._id, email: user.email };
    const token = UserService.generateToken(tokenData, process.env.JWT_SECRET, "1h");

    res.status(200).json({ status: true, token });
  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({ status: false, message: "Internal Server Error" });
  }
};

module.exports = { register, login, getUser };
