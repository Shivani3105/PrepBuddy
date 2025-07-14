const { text } = require('express');
const nodemailer=require('nodemailer');
require('dotenv').config();
const transporter=nodemailer.createTransport(
    {
        service:'gmail',
        auth:{
            pass:process.env.GMAIL_PASS,
            gmailid:process.env.GMAIL_ID,
        },
    }
);
async function sendOtpEmail(email,otp){
    const mailOptions={
        from :process.env.GMAIL_ID,
        to:email,
        subject:'your OTP for PrepBuddy Login',
        text:'you OTP is :${otp}. It will expire in 60 seconds',
    };
    return transporter.sendMail(mailOptions);
}
module.exports=sendOtpEmail;