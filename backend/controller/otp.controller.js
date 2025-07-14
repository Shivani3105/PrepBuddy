const sendOtpEmail = require('../utils/mailer');

const otpMap = new Map(); // key: email, value: { otp, expiresAt }

function generateOTP() {
  return Math.floor(100000 + Math.random() * 900000).toString(); // 6-digit
}

async function sendOtp(req, res) {
  const { email } = req.body;

  const otp = generateOTP();
  const expiresAt = Date.now() + 60 * 1000; // 60 seconds

  otpMap.set(email, { otp, expiresAt });

  try {
    await sendOtpEmail(email, otp);
    res.status(200).json({ message: "OTP sent to email" });
  } catch (err) {
    res.status(500).json({ message: "Failed to send OTP", error: err });
  }
}

function verifyOtp(req, res) {
  const { email, otp } = req.body;

  const record = otpMap.get(email);
  if (!record) return res.status(400).json({ message: "OTP not requested" });

  if (Date.now() > record.expiresAt) {
    otpMap.delete(email);
    return res.status(400).json({ message: "OTP expired" });
  }

  if (record.otp !== otp) {
    return res.status(400).json({ message: "Invalid OTP" });
  }

  otpMap.delete(email);
  res.status(200).json({ message: "OTP verified successfully" });
}

module.exports = { sendOtp, verifyOtp };
