const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const db = require('../db');
const { Schema } = mongoose;

const userSchema = new Schema({
  email: {
    type: String,
    lowercase: true,
    required: true,
    unique: true
  },
  username: {
    type: String,
    required: true,
    unique: true
  },
  password: {
    type: String,
    required: true
  }
});

userSchema.pre('save', async function () {
  try {
    if (!this.isModified('password')) return;
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
  } catch (error) {
    throw error;
  }
});

userSchema.methods.comparePassword = async function (userPassword) {
  try {
    return await bcrypt.compare(userPassword, this.password);
  } catch (error) {
    throw error;
  }
};

const UserModel = db.model('user', userSchema);
module.exports = UserModel;
