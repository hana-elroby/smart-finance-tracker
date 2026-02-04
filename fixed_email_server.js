const express = require('express');
const nodemailer = require('nodemailer');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// ✅ FIXED Gmail Transporter Configuration
const gmailTransporter = nodemailer.createTransporter({
    host: "smtp.gmail.com",
    port: 465,
    secure: true, // Use SSL
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS, // Make sure NO SPACES!
    },
    tls: {
        rejectUnauthorized: false
    }
});

// Test connection on startup
gmailTransporter.verify((error, success) => {
    if (error) {
        console.error("❌ GMAIL SMTP CONNECTION FAILED:", error);
    } else {
        console.log("✅ GMAIL SMTP SERVER READY");
    }
});

// Store OTPs temporarily (use Redis in production)
const otpStore = new Map();

// ✅ Enhanced OTP Email Function
async function sendOTPEmail(email, otp) {
    try {
        const mailOptions = {
            from: `"Smart Finance Tracker" <${process.env.EMAIL_USER}>`,
            to: email,
            subject: "Your OTP Code - Smart Finance Tracker",
            html: `
                <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
                    <div style="text-align: center; margin-bottom: 30px;">
                        <h1 style="color: #0D47A1; margin: 0;">Smart Finance Tracker</h1>
                    </div>
                    
                    <div style="background: white; border-radius: 10px; padding: 30px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
                        <h2 style="color: #333; text-align: center; margin-bottom: 20px;">Email Verification</h2>
                        
                        <p style="color: #666; font-size: 16px; line-height: 1.5;">
                            Thank you for signing up! Please use the following verification code to complete your registration:
                        </p>
                        
                        <div style="background: #f8f9fa; border: 2px dashed #0D47A1; border-radius: 8px; padding: 25px; text-align: center; margin: 25px 0;">
                            <div style="font-size: 32px; font-weight: bold; color: #0D47A1; letter-spacing: 8px; font-family: 'Courier New', monospace;">
                                ${otp}
                            </div>
                        </div>
                        
                        <div style="background: #fff3cd; border: 1px solid #ffeaa7; border-radius: 5px; padding: 15px; margin: 20px 0;">
                            <p style="margin: 0; color: #856404; font-size: 14px;">
                                ⏰ <strong>Important:</strong> This code will expire in 10 minutes for security reasons.
                            </p>
                        </div>
                        
                        <p style="color: #666; font-size: 14px; margin-top: 30px;">
                            If you didn't request this verification code, please ignore this email or contact our support team.
                        </p>
                        
                        <div style="border-top: 1px solid #eee; margin-top: 30px; padding-top: 20px; text-align: center;">
                            <p style="color: #999; font-size: 12px; margin: 0;">
                                © 2024 Smart Finance Tracker. All rights reserved.
                            </p>
                        </div>
                    </div>
                </div>
            `
        };

        console.log("📧 ATTEMPTING TO SEND EMAIL:");
        console.log("- To:", email);
        console.log("- OTP:", otp);
        console.log("- From:", process.env.EMAIL_USER);
        
        const info = await gmailTransporter.sendMail(mailOptions);
        
        console.log("✅ EMAIL SENT SUCCESSFULLY:");
        console.log("- Message ID:", info.messageId);
        console.log("- Response:", info.response);
        console.log("- Accepted:", info.accepted);
        console.log("- Rejected:", info.rejected);
        console.log("- Envelope:", info.envelope);
        
        return { 
            success: true, 
            messageId: info.messageId,
            response: info.response 
        };
        
    } catch (error) {
        console.error("❌ EMAIL SEND FAILED:");
        console.error("- Error Message:", error.message);
        console.error("- Error Code:", error.code);
        console.error("- Error Response:", error.response);
        console.error("- Full Error:", error);
        
        return { 
            success: false, 
            error: error.message,
            code: error.code 
        };
    }
}

// ✅ Health Check Endpoint
app.get('/api', (req, res) => {
    res.json({ 
        message: 'Server is running!', 
        timestamp: new Date().toISOString(),
        emailConfigured: !!process.env.EMAIL_USER
    });
});

// ✅ Test Email Endpoint
app.post('/test-email', async (req, res) => {
    try {
        const { email } = req.body;
        
        if (!email) {
            return res.status(400).json({ 
                success: false, 
                message: 'Email is required' 
            });
        }

        const testOTP = '123456';
        const result = await sendOTPEmail(email, testOTP);
        
        if (result.success) {
            res.json({
                success: true,
                message: 'Test email sent successfully!',
                messageId: result.messageId,
                email: email,
                otp: testOTP // Remove in production
            });
        } else {
            res.status(500).json({
                success: false,
                message: 'Failed to send test email',
                error: result.error
            });
        }
    } catch (error) {
        console.error('Test email error:', error);
        res.status(500).json({ 
            success: false, 
            message: 'Server error',
            error: error.message 
        });
    }
});

// ✅ Signup Endpoint with Enhanced Error Handling
app.post('/auth/signup', async (req, res) => {
    try {
        console.log("📝 SIGNUP REQUEST:", req.body);
        
        const { name, fullName, firstName, lastName, email, password, phone, countryCode, country } = req.body;
        
        // Flexible name handling
        const userName = name || fullName || `${firstName || ''} ${lastName || ''}`.trim() || 'User';
        
        if (!userName || userName === 'User') {
            return res.status(400).json({
                success: false,
                message: 'Name is required',
                error: 'Please provide name, fullName, or firstName/lastName'
            });
        }
        
        if (!email) {
            return res.status(400).json({
                success: false,
                message: 'Email is required'
            });
        }
        
        if (!password) {
            return res.status(400).json({
                success: false,
                message: 'Password is required'
            });
        }
        
        // Generate 6-digit OTP
        const otp = Math.floor(100000 + Math.random() * 900000);
        
        console.log("🔐 GENERATED OTP:", otp, "for email:", email);
        
        // Send OTP email
        const emailResult = await sendOTPEmail(email, otp);
        
        if (emailResult.success) {
            // Store OTP with expiration (10 minutes)
            const otpData = {
                otp: otp,
                email: email,
                name: userName,
                password: password, // Hash this in production!
                phone: phone,
                countryCode: countryCode,
                country: country,
                createdAt: Date.now(),
                expiresAt: Date.now() + (10 * 60 * 1000) // 10 minutes
            };
            
            otpStore.set(email, otpData);
            
            console.log("✅ OTP STORED FOR:", email);
            
            res.status(200).json({
                success: true,
                message: "OTP sent successfully! Check your email.",
                data: {
                    email: email,
                    messageId: emailResult.messageId,
                    // Remove these in production:
                    debug_otp: otp,
                    debug_response: emailResult.response
                }
            });
        } else {
            console.error("❌ EMAIL SEND FAILED:", emailResult);
            
            res.status(500).json({
                success: false,
                message: "Failed to send OTP email. Please try again.",
                error: emailResult.error,
                details: "Check server logs for more information"
            });
        }
        
    } catch (error) {
        console.error("❌ SIGNUP ERROR:", error);
        res.status(500).json({ 
            success: false, 
            message: "Server error during signup",
            error: error.message 
        });
    }
});

// ✅ OTP Verification Endpoint
app.post('/auth/signup/configurationOTP', async (req, res) => {
    try {
        const { otp } = req.body;
        
        if (!otp) {
            return res.status(400).json({
                success: false,
                message: 'OTP is required'
            });
        }
        
        // Find OTP in store
        let foundEmail = null;
        let otpData = null;
        
        for (const [email, data] of otpStore.entries()) {
            if (data.otp.toString() === otp.toString()) {
                foundEmail = email;
                otpData = data;
                break;
            }
        }
        
        if (!otpData) {
            return res.status(400).json({
                success: false,
                message: 'Invalid OTP code'
            });
        }
        
        // Check expiration
        if (Date.now() > otpData.expiresAt) {
            otpStore.delete(foundEmail);
            return res.status(400).json({
                success: false,
                message: 'OTP has expired. Please request a new one.'
            });
        }
        
        // OTP is valid - create user account
        const user = {
            id: Date.now().toString(),
            email: otpData.email,
            name: otpData.name,
            phone: otpData.phone,
            verified: true,
            createdAt: new Date().toISOString()
        };
        
        // Generate simple token (use JWT in production)
        const token = `token_${user.id}_${Date.now()}`;
        
        // Remove OTP from store
        otpStore.delete(foundEmail);
        
        console.log("✅ USER VERIFIED:", user.email);
        
        res.status(200).json({
            success: true,
            message: 'Account verified successfully!',
            user: user,
            token: token
        });
        
    } catch (error) {
        console.error("❌ OTP VERIFICATION ERROR:", error);
        res.status(500).json({ 
            success: false, 
            message: "Server error during verification",
            error: error.message 
        });
    }
});

// ✅ Resend OTP Endpoint
app.post('/auth/resendOTP', async (req, res) => {
    try {
        const { email } = req.body;
        
        if (!email) {
            return res.status(400).json({
                success: false,
                message: 'Email is required'
            });
        }
        
        // Check if email exists in OTP store
        const existingData = otpStore.get(email);
        if (!existingData) {
            return res.status(400).json({
                success: false,
                message: 'No pending verification for this email'
            });
        }
        
        // Generate new OTP
        const newOTP = Math.floor(100000 + Math.random() * 900000);
        
        // Send new OTP
        const emailResult = await sendOTPEmail(email, newOTP);
        
        if (emailResult.success) {
            // Update stored data with new OTP
            existingData.otp = newOTP;
            existingData.createdAt = Date.now();
            existingData.expiresAt = Date.now() + (10 * 60 * 1000);
            otpStore.set(email, existingData);
            
            res.json({
                success: true,
                message: 'New OTP sent successfully!',
                data: {
                    email: email,
                    debug_otp: newOTP // Remove in production
                }
            });
        } else {
            res.status(500).json({
                success: false,
                message: 'Failed to resend OTP',
                error: emailResult.error
            });
        }
        
    } catch (error) {
        console.error("❌ RESEND OTP ERROR:", error);
        res.status(500).json({ 
            success: false, 
            message: "Server error",
            error: error.message 
        });
    }
});

// ✅ Debug Endpoint - Remove in production
app.get('/debug/otp-store', (req, res) => {
    const otps = Array.from(otpStore.entries()).map(([email, data]) => ({
        email,
        otp: data.otp,
        expiresAt: new Date(data.expiresAt).toISOString(),
        expired: Date.now() > data.expiresAt
    }));
    
    res.json({ otps });
});

// Clean up expired OTPs every minute
setInterval(() => {
    const now = Date.now();
    for (const [email, data] of otpStore.entries()) {
        if (now > data.expiresAt) {
            otpStore.delete(email);
            console.log("🧹 CLEANED EXPIRED OTP for:", email);
        }
    }
}, 60000);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`🚀 Server running on port ${PORT}`);
    console.log(`📧 Email configured: ${!!process.env.EMAIL_USER}`);
    console.log(`📧 Email user: ${process.env.EMAIL_USER}`);
    console.log(`🔑 Email pass configured: ${!!process.env.EMAIL_PASS}`);
});

module.exports = app;