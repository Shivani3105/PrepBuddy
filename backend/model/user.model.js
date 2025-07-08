const mongoose = require('mongoose');
const bcrypt = require('bcrypt'); // ✅ Correct spelling
const db = require('../db');
const { Schema } = mongoose;

// 🔹 User Schema
const userSchema = new Schema({
  email: {
    type: String,
    lowercase: true,
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


// 🔐 Compare password method
userSchema.methods.comparePassword = async function (userPassword) {
  try {
console.log("Plain password:", userPassword);
  console.log("Hashed password:", this.password);
    return await bcrypt.compare(userPassword, this.password);
  } catch (error) {
    throw error;
  }
};

// 📦 Export model
const UserModel = db.model('user', userSchema);
module.exports = UserModel;
