// Local Server with Real OTP Email Sending
// Run this with: node local_server_with_otp.js

const express = require('express');
const nodemailer = require('nodemailer');
const cors = require('cors');
const app = express();

app.use(cors());
app.use(express.json());

// In-memory storage for demo (use database in production)
const users = {};
const otpStorage = {};

// Email configuration (replace with your Gmail credentials)
const transporter = nodemailer.createTransporter({
  service: 'gmail',
  auth: {
    user: 'your-email@gmail.com', // Replace with your Gmail
    pass: 'your-app-password'     // Replace with Gmail App Password
  }
});

// Generate random OTP
function generateOTP() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// Send OTP email
async function sendOTPEmail(email, otp) {
  const mailOptions = {
    from: 'your-email@gmail.com',
    to: email,
    subject: 'Smart Finance Tracker - OTP Verification',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #0D47A1;">Smart Finance Tracker</h2>
        <p>Your OTP verification code is:</p>
        <div style="background: #f5f5f5; padding: 20px; text-align: center; margin: 20px 0;">
          <h1 style="color: #0D47A1; font-size: 32px; margin: 0;">${otp}</h1>
        </div>
        <p>This code will expire in 10 minutes.</p>
        <p>If you didn't request this code, please ignore this email.</p>
      </div>
    `
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log('✅ OTP sent to:', email);
    return true;
  } catch (error) {
    console.error('❌ Email send failed:', error);
    return false;
  }
}

// API Routes

// Health check
app.get('/api', (req, res) => {
  res.json({ 
    message: 'Local Server with OTP is running!',
    timestamp: new Date().toISOString()
  });
});

// Signup endpoint
app.post('/auth/signup', async (req, res) => {
  const { firstName, lastName, email, password } = req.body;
  
  console.log('📝 Signup request:', { firstName, lastName, email });
  
  // Check if user already exists
  if (users[email]) {
    return res.status(400).json({
      success: false,
      message: 'User already exists',
      flag: true
    });
  }
  
  // Generate OTP
  const otp = generateOTP();
  
  // Store user data temporarily
  users[email] = {
    firstName,
    lastName,
    email,
    password,
    verified: false,
    createdAt: new Date()
  };
  
  // Store OTP with expiration
  otpStorage[email] = {
    otp,
    expiresAt: new Date(Date.now() + 10 * 60 * 1000) // 10 minutes
  };
  
  // Send OTP email
  const emailSent = await sendOTPEmail(email, otp);
  
  if (emailSent) {
    res.json({
      success: true,
      message: 'OTP sent to your email successfully!'
    });
  } else {
    res.status(500).json({
      success: false,
      message: 'Failed to send OTP. Please check email configuration.'
    });
  }
});

// OTP verification endpoint
app.post('/auth/signup/configurationOTP', (req, res) => {
  const { otp } = req.body;
  
  console.log('🔐 OTP verification request:', { otp });
  
  // Find user by OTP
  let userEmail = null;
  for (const [email, otpData] of Object.entries(otpStorage)) {
    if (otpData.otp === otp) {
      // Check if OTP is expired
      if (new Date() > otpData.expiresAt) {
        return res.status(400).json({
          success: false,
          message: 'OTP has expired. Please request a new one.'
        });
      }
      userEmail = email;
      break;
    }
  }
  
  if (!userEmail) {
    return res.status(400).json({
      success: false,
      message: 'Invalid OTP. Please try again.'
    });
  }
  
  // Mark user as verified
  users[userEmail].verified = true;
  
  // Clean up OTP
  delete otpStorage[userEmail];
  
  // Generate fake token (use JWT in production)
  const token = 'fake-jwt-token-' + Date.now();
  
  res.json({
    success: true,
    message: 'Account verified successfully!',
    token: token,
    user: {
      id: Date.now(),
      firstName: users[userEmail].firstName,
      lastName: users[userEmail].lastName,
      email: users[userEmail].email,
      verified: true
    }
  });
});

// Start server
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`🚀 Local server running on http://localhost:${PORT}`);
  console.log('📧 Make sure to configure Gmail credentials in the code!');
});

// Instructions for Gmail setup
console.log(`
📧 Gmail Setup Instructions:
1. Go to Google Account Settings
2. Enable 2-Factor Authentication
3. Generate App Password for this application
4. Replace 'your-email@gmail.com' and 'your-app-password' in the code
5. Restart the server

🔧 Install dependencies:
npm install express nodemailer cors
`);